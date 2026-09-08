import { describe, it, before, after, mock } from 'node:test';
import assert from 'node:assert';
import request from 'supertest';
import app from '../src/app.js';
import prisma from '../src/config/db.js';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

describe('Payment API Tests', () => {
  let buyerToken, artisanToken, buyer2Token, buyerId, artisanId, buyer2Id;
  let buyerProfileId, buyer2ProfileId;
  let acceptedOrder, pendingOrder, rejectedOrder, partiallyAcceptedOrder;
  const originalEnv = process.env;

  before(async () => {
    process.env = { ...originalEnv, RAZORPAY_KEY_ID: 'test_key', RAZORPAY_KEY_SECRET: 'test_secret', JWT_SECRET: 'testsecret' };

    // Create users
    const buyer = await prisma.user.create({ data: { mobileNumber: '1111111111', role: 'BUYER', status: 'ACTIVE' } });
    buyerId = buyer.id;
    const buyer2 = await prisma.user.create({ data: { mobileNumber: '3333333333', role: 'BUYER', status: 'ACTIVE' } });
    buyer2Id = buyer2.id;
    const artisan = await prisma.user.create({ data: { mobileNumber: '2222222222', role: 'ARTISAN', status: 'ACTIVE' } });
    artisanId = artisan.id;

    const b1Profile = await prisma.buyerProfile.create({ data: { userId: buyerId, name: 'B1', businessName: 'B1', businessType: 'B', state: 'S', district: 'D' } });
    buyerProfileId = b1Profile.id;
    const b2Profile = await prisma.buyerProfile.create({ data: { userId: buyer2Id, name: 'B2', businessName: 'B2', businessType: 'B', state: 'S', district: 'D' } });
    buyer2ProfileId = b2Profile.id;
    const aProfile = await prisma.artisanProfile.create({ data: { userId: artisanId, name: 'A', craftType: 'C', state: 'S', district: 'D', preferredLanguage: 'EN' } });

    buyerToken = jwt.sign({ id: buyerId, role: 'BUYER' }, process.env.JWT_SECRET);
    buyer2Token = jwt.sign({ id: buyer2Id, role: 'BUYER' }, process.env.JWT_SECRET);
    artisanToken = jwt.sign({ id: artisanId, role: 'ARTISAN' }, process.env.JWT_SECRET);

    // Create orders
    acceptedOrder = await prisma.order.create({
      data: { buyerId: buyerProfileId, artisanId: aProfile.id, totalAmount: 500, status: 'ACCEPTED' }
    });
    pendingOrder = await prisma.order.create({
      data: { buyerId: buyerProfileId, artisanId: aProfile.id, totalAmount: 500, status: 'PENDING' }
    });
    rejectedOrder = await prisma.order.create({
      data: { buyerId: buyerProfileId, artisanId: aProfile.id, totalAmount: 500, status: 'REJECTED' }
    });
    partiallyAcceptedOrder = await prisma.order.create({
      data: { buyerId: buyerProfileId, artisanId: aProfile.id, totalAmount: 300, status: 'PARTIALLY_ACCEPTED' }
    });

    // Mock Razorpay
    mock.module('razorpay', () => {
      return class RazorpayMock {
        constructor() {
          this.orders = {
            create: async (opts) => {
              return { id: 'order_test_123', amount: opts.amount, currency: opts.currency };
            }
          };
        }
      };
    });
  });

  after(async () => {
    process.env = originalEnv;
    await prisma.order.deleteMany({});
    await prisma.buyerProfile.deleteMany({});
    await prisma.artisanProfile.deleteMany({});
    await prisma.user.deleteMany({});
  });

  it('should reject unauthenticated request', async () => {
    const res = await request(app).post(`/api/v1/orders/${acceptedOrder.id}/payment`);
    assert.strictEqual(res.statusCode, 401);
  });

  it('should reject non-buyer request', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment`)
      .set('Authorization', `Bearer ${artisanToken}`);
    assert.strictEqual(res.statusCode, 403);
  });

  it('should reject payment for PENDING order', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${pendingOrder.id}/payment`)
      .set('Authorization', `Bearer ${buyerToken}`);
    assert.strictEqual(res.statusCode, 400);
    assert.match(res.body.message, /accepted/i);
  });

  it('should reject payment for REJECTED order', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${rejectedOrder.id}/payment`)
      .set('Authorization', `Bearer ${buyerToken}`);
    assert.strictEqual(res.statusCode, 400);
  });

  it('should reject payment for order owned by another buyer', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment`)
      .set('Authorization', `Bearer ${buyer2Token}`);
    assert.strictEqual(res.statusCode, 403);
  });

  it('should create razorpay order successfully for ACCEPTED order', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment`)
      .set('Authorization', `Bearer ${buyerToken}`);
    
    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(res.body.data.amount, 50000);
    assert.strictEqual(res.body.data.razorpayOrderId, 'order_test_123');
    assert.ok(!res.body.data.key_secret);
  });

  it('should be idempotent and reuse PENDING order', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment`)
      .set('Authorization', `Bearer ${buyerToken}`);
    
    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.data.razorpayOrderId, 'order_test_123');
  });

  it('should create razorpay order successfully for PARTIALLY_ACCEPTED order', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${partiallyAcceptedOrder.id}/payment`)
      .set('Authorization', `Bearer ${buyerToken}`);
    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.data.amount, 30000);
  });

  it('should reject verify with missing fields', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({});
    assert.strictEqual(res.statusCode, 400);
  });

  it('should reject invalid signature', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        razorpay_payment_id: 'pay_test',
        razorpay_order_id: 'order_test_123',
        razorpay_signature: 'invalid'
      });
    
    assert.strictEqual(res.statusCode, 400);
  });

  it('should reject mismatched razorpay order ID', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        razorpay_payment_id: 'pay_test',
        razorpay_order_id: 'order_wrong',
        razorpay_signature: 'invalid'
      });
    
    assert.strictEqual(res.statusCode, 400);
  });

  it('should verify signature successfully', async () => {
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    hmac.update('order_test_123|pay_test');
    const validSignature = hmac.digest('hex');

    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        razorpay_payment_id: 'pay_test',
        razorpay_order_id: 'order_test_123',
        razorpay_signature: validSignature
      });
    
    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    
    const order = await prisma.order.findUnique({ where: { id: acceptedOrder.id } });
    assert.strictEqual(order.paymentStatus, 'SUCCESS');
    assert.strictEqual(order.status, 'ACCEPTED'); // ensure business status is unchanged
  });

  it('should handle duplicate successful verification idempotently', async () => {
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    hmac.update('order_test_123|pay_test');
    const validSignature = hmac.digest('hex');

    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        razorpay_payment_id: 'pay_test',
        razorpay_order_id: 'order_test_123',
        razorpay_signature: validSignature
      });
    
    assert.strictEqual(res.statusCode, 200);
  });

  it('should reject duplicate successful verification with mismatched payment ID', async () => {
    const res = await request(app)
      .post(`/api/v1/orders/${acceptedOrder.id}/payment/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        razorpay_payment_id: 'pay_wrong',
        razorpay_order_id: 'order_test_123',
        razorpay_signature: 'random'
      });
    
    assert.strictEqual(res.statusCode, 400);
  });
});
