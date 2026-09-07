/**
 * buyer.test.js
 * Tests for all buyer-side APIs:
 *   - PATCH /api/v1/buyers/me
 *   - GET  /api/v1/products  (public listing + search + filter)
 *   - GET  /api/v1/products/:id  (buyer view of published products)
 *   - GET  /api/v1/artisans/:id  (public artisan profile)
 *   - GET  /api/v1/enquiries/my  (buyer enquiry list)
 *   - GET  /api/v1/orders/my     (buyer order list)
 *   - GET  /api/auth/me          (no OTP fields in response)
 */

import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import jwt from 'jsonwebtoken';
import app from '../src/app.js';
import prisma from '../src/config/db.js';

// ─── Test helpers ─────────────────────────────────────────────────────────────

const BASE = 'http://localhost:0';
let server;
let baseUrl;

const api = async (method, path, { body, token } = {}) => {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;
  const res = await fetch(`${baseUrl}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  let json;
  try { json = await res.json(); } catch { json = null; }
  return { status: res.status, body: json };
};

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const TEST_PHONES = ['+91-BUYER-BUYERSIDE', '+91-ARTISAN-BUYERSIDE'];

let buyerUserId, buyerProfileId, buyerToken;
let artisanUserId, artisanProfileId, artisanToken;
let publishedProductId, draftProductId;
let enquiryId, orderId;

before(async () => {
  // Start server
  await new Promise((resolve) => {
    server = app.listen(0, '127.0.0.1', resolve);
  });
  baseUrl = `http://127.0.0.1:${server.address().port}`;

  // Cleanup any leftovers
  await prisma.enquiryMessage.deleteMany({ where: { enquiry: { buyer: { user: { mobileNumber: { in: TEST_PHONES } } } } } });
  await prisma.enquiry.deleteMany({ where: { buyer: { user: { mobileNumber: { in: TEST_PHONES } } } } });
  await prisma.order.deleteMany({ where: { buyer: { user: { mobileNumber: { in: TEST_PHONES } } } } });
  await prisma.notification.deleteMany({ where: { user: { mobileNumber: { in: TEST_PHONES } } } });
  await prisma.product.deleteMany({ where: { artisan: { user: { mobileNumber: TEST_PHONES[1] } } } });
  await prisma.buyerProfile.deleteMany({ where: { user: { mobileNumber: TEST_PHONES[0] } } });
  await prisma.artisanProfile.deleteMany({ where: { user: { mobileNumber: TEST_PHONES[1] } } });
  await prisma.user.deleteMany({ where: { mobileNumber: { in: TEST_PHONES } } });

  // Create buyer user + profile
  const buyerUser = await prisma.user.create({
    data: {
      mobileNumber: TEST_PHONES[0],
      role: 'BUYER',
      status: 'ACTIVE',
      buyerProfile: {
        create: {
          name: 'Test Buyer',
          businessName: 'Test Biz',
          businessType: 'Retailer',
          state: 'Maharashtra',
          district: 'Mumbai',
        },
      },
    },
    include: { buyerProfile: true },
  });
  buyerUserId = buyerUser.id;
  buyerProfileId = buyerUser.buyerProfile.id;
  buyerToken = jwt.sign({ id: buyerUserId }, process.env.JWT_SECRET);

  // Create artisan user + profile
  const artisanUser = await prisma.user.create({
    data: {
      mobileNumber: TEST_PHONES[1],
      role: 'ARTISAN',
      status: 'ACTIVE',
      artisanProfile: {
        create: {
          name: 'Test Artisan',
          craftType: 'Pottery',
          state: 'Rajasthan',
          district: 'Jaipur',
          preferredLanguage: 'Hindi',
        },
      },
    },
    include: { artisanProfile: true },
  });
  artisanUserId = artisanUser.id;
  artisanProfileId = artisanUser.artisanProfile.id;
  artisanToken = jwt.sign({ id: artisanUserId }, process.env.JWT_SECRET);

  // Create published product
  const published = await prisma.product.create({
    data: {
      artisanId: artisanProfileId,
      productName: { en: 'Blue Pottery Bowl', hi: 'नीली मिट्टी का कटोरा' },
      category: 'Pottery',
      material: 'Clay',
      description: { en: 'Handcrafted bowl', hi: 'हाथ से बना कटोरा' },
      tags: ['blue', 'handmade', 'pottery'],
      status: 'PUBLISHED',
      suggestedPriceMin: 500,
      suggestedPriceMax: 1200,
      currency: 'INR',
    },
  });
  publishedProductId = published.id;

  // Create draft product
  const draft = await prisma.product.create({
    data: {
      artisanId: artisanProfileId,
      productName: { en: 'Draft Item', hi: 'मसौदा' },
      category: 'Textile',
      material: 'Silk',
      description: { en: 'Not yet published', hi: 'अभी प्रकाशित नहीं' },
      tags: ['draft'],
      status: 'DRAFT',
    },
  });
  draftProductId = draft.id;

  // Create an enquiry from buyer → artisan
  const enquiry = await prisma.enquiry.create({
    data: {
      buyerId: buyerProfileId,
      artisanId: artisanProfileId,
      productId: publishedProductId,
      message: 'Interested in bulk order',
      status: 'NEW',
    },
  });
  enquiryId = enquiry.id;

  // Create an order from buyer
  const order = await prisma.order.create({
    data: {
      buyerId: buyerProfileId,
      artisanId: artisanProfileId,
      productId: publishedProductId,
      requestedQty: 10,
      unitPrice: 800,
      status: 'PENDING',
    },
  });
  orderId = order.id;
});

after(async () => {
  // Cleanup in dependency order
  await prisma.enquiryMessage.deleteMany({ where: { enquiry: { buyer: { user: { mobileNumber: { in: TEST_PHONES } } } } } });
  await prisma.enquiry.deleteMany({ where: { buyer: { user: { mobileNumber: { in: TEST_PHONES } } } } });
  await prisma.order.deleteMany({ where: { buyer: { user: { mobileNumber: { in: TEST_PHONES } } } } });
  await prisma.notification.deleteMany({ where: { user: { mobileNumber: { in: TEST_PHONES } } } });
  await prisma.product.deleteMany({ where: { artisan: { user: { mobileNumber: TEST_PHONES[1] } } } });
  await prisma.buyerProfile.deleteMany({ where: { user: { mobileNumber: TEST_PHONES[0] } } });
  await prisma.artisanProfile.deleteMany({ where: { user: { mobileNumber: TEST_PHONES[1] } } });
  await prisma.user.deleteMany({ where: { mobileNumber: { in: TEST_PHONES } } });
  await new Promise((resolve) => server.close(resolve));
});

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('Buyer API Tests', () => {

  // ── A. PATCH /api/v1/buyers/me ──────────────────────────────────────────────

  it('1. Buyer can update their profile', async () => {
    const { status, body } = await api('PATCH', '/api/v1/buyers/me', {
      token: buyerToken,
      body: { name: 'Updated Buyer', state: 'Karnataka', district: 'Bengaluru' },
    });
    assert.equal(status, 200);
    assert.equal(body.success, true);
    assert.equal(body.data.name, 'Updated Buyer');
    assert.equal(body.data.state, 'Karnataka');
    assert.equal(body.data.district, 'Bengaluru');
  });

  it('2. Artisan cannot update buyer profile (403)', async () => {
    const { status } = await api('PATCH', '/api/v1/buyers/me', {
      token: artisanToken,
      body: { name: 'Hacker' },
    });
    assert.equal(status, 403);
  });

  it('3. Unauthenticated buyer profile update is rejected (401)', async () => {
    const { status } = await api('PATCH', '/api/v1/buyers/me', {
      body: { name: 'No Auth' },
    });
    assert.equal(status, 401);
  });

  it('4. Invalid field rejected with 400', async () => {
    const { status, body } = await api('PATCH', '/api/v1/buyers/me', {
      token: buyerToken,
      body: { name: '' },  // empty string fails z.string().min(1)
    });
    assert.equal(status, 400);
  });

  it('5. Unknown fields rejected by strict schema (400)', async () => {
    const { status } = await api('PATCH', '/api/v1/buyers/me', {
      token: buyerToken,
      body: { interestedCategories: ['Pottery'] },  // not in schema
    });
    assert.equal(status, 400);
  });

  // ── B. GET /api/v1/products — public listing ────────────────────────────────

  it('6. Buyer can list published products', async () => {
    const { status, body } = await api('GET', '/api/v1/products', { token: buyerToken });
    assert.equal(status, 200);
    assert.equal(body.success, true);
    assert.ok(Array.isArray(body.data));
    // Must include pagination metadata
    assert.ok(typeof body.pagination.total === 'number');
    assert.ok(typeof body.pagination.pages === 'number');
    // Every returned product must be PUBLISHED
    for (const p of body.data) assert.equal(p.status, 'PUBLISHED');
    // Draft product must NOT appear
    assert.ok(!body.data.some((p) => p.id === draftProductId));
  });

  it('7. Product listing includes artisan summary', async () => {
    const { status, body } = await api('GET', '/api/v1/products', { token: buyerToken });
    assert.equal(status, 200);
    const product = body.data.find((p) => p.id === publishedProductId);
    assert.ok(product, 'Published product must appear in listing');
    assert.ok(product.artisan, 'Artisan summary must be included');
    assert.equal(product.artisan.name, 'Test Artisan');
    assert.equal(product.artisan.craftType, 'Pottery');
    // Must NOT expose userId or mobileNumber
    assert.ok(!product.artisan.userId);
    assert.ok(!product.artisan.user);
  });

  it('8. Category filter works (case-insensitive)', async () => {
    const { status, body } = await api('GET', '/api/v1/products?category=pottery', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(body.data.some((p) => p.id === publishedProductId));
    // Draft textile product must not appear (it's draft anyway, and wrong category)
    assert.ok(!body.data.some((p) => p.id === draftProductId));
  });

  it('9. Search query filters by category field (case-insensitive)', async () => {
    const { status, body } = await api('GET', '/api/v1/products?q=Pottery', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(body.data.some((p) => p.id === publishedProductId));
  });

  it('10. Search query filters by material', async () => {
    const { status, body } = await api('GET', '/api/v1/products?q=clay', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(body.data.some((p) => p.id === publishedProductId));
  });

  it('11. Pagination: page=1&limit=1 returns exactly 1 product', async () => {
    const { status, body } = await api('GET', '/api/v1/products?page=1&limit=1', { token: buyerToken });
    assert.equal(status, 200);
    assert.equal(body.data.length, 1);
    assert.equal(body.pagination.limit, 1);
    assert.equal(body.pagination.page, 1);
  });

  it('12. Artisan can also use product listing endpoint', async () => {
    const { status, body } = await api('GET', '/api/v1/products', { token: artisanToken });
    assert.equal(status, 200);
    assert.equal(body.success, true);
  });

  it('13. Unauthenticated product listing is rejected (401)', async () => {
    const { status } = await api('GET', '/api/v1/products');
    assert.equal(status, 401);
  });

  // ── C. GET /api/v1/products/:id — buyer product detail ─────────────────────

  it('14. Buyer can view a published product with artisan summary', async () => {
    const { status, body } = await api('GET', `/api/v1/products/${publishedProductId}`, {
      token: buyerToken,
    });
    assert.equal(status, 200);
    assert.equal(body.success, true);
    assert.equal(body.data.id, publishedProductId);
    assert.ok(body.data.artisan, 'Artisan summary must be present');
    assert.equal(body.data.artisan.name, 'Test Artisan');
    // Must not expose userId
    assert.ok(!body.data.artisan.userId);
  });

  it('15. Buyer cannot view a DRAFT product (404)', async () => {
    const { status } = await api('GET', `/api/v1/products/${draftProductId}`, {
      token: buyerToken,
    });
    assert.equal(status, 404);
  });

  it('16. Artisan can still view their own product (existing behavior)', async () => {
    const { status, body } = await api('GET', `/api/v1/products/${publishedProductId}`, {
      token: artisanToken,
    });
    assert.equal(status, 200);
    assert.equal(body.data.id, publishedProductId);
  });

  it('17. Unauthenticated product detail is rejected (401)', async () => {
    const { status } = await api('GET', `/api/v1/products/${publishedProductId}`);
    assert.equal(status, 401);
  });

  // ── D. GET /api/v1/artisans/:id — public artisan profile ───────────────────

  it('18. Buyer can get public artisan profile by id', async () => {
    const { status, body } = await api('GET', `/api/v1/artisans/${artisanProfileId}`, {
      token: buyerToken,
    });
    assert.equal(status, 200);
    assert.equal(body.success, true);
    assert.equal(body.data.id, artisanProfileId);
    assert.equal(body.data.name, 'Test Artisan');
    assert.equal(body.data.craftType, 'Pottery');
    assert.equal(body.data.state, 'Rajasthan');
    assert.equal(body.data.district, 'Jaipur');
    assert.equal(body.data.preferredLanguage, 'Hindi');
  });

  it('19. Public artisan profile does NOT expose userId or mobileNumber', async () => {
    const { status, body } = await api('GET', `/api/v1/artisans/${artisanProfileId}`, {
      token: buyerToken,
    });
    assert.equal(status, 200);
    assert.ok(!('userId' in body.data), 'userId must not be exposed');
    assert.ok(!('user' in body.data), 'user relation must not be exposed');
  });

  it('20. Non-existent artisan returns 404', async () => {
    const { status } = await api('GET', '/api/v1/artisans/00000000-0000-0000-0000-000000000000', {
      token: buyerToken,
    });
    assert.equal(status, 404);
  });

  it('21. Artisan can also look up another artisan profile', async () => {
    const { status, body } = await api('GET', `/api/v1/artisans/${artisanProfileId}`, {
      token: artisanToken,
    });
    assert.equal(status, 200);
    assert.equal(body.data.id, artisanProfileId);
  });

  it('22. Unauthenticated artisan profile lookup is rejected (401)', async () => {
    const { status } = await api('GET', `/api/v1/artisans/${artisanProfileId}`);
    assert.equal(status, 401);
  });

  // ── E. GET /api/v1/enquiries/my ────────────────────────────────────────────

  it('23. Buyer can list their own enquiries', async () => {
    const { status, body } = await api('GET', '/api/v1/enquiries/my', { token: buyerToken });
    assert.equal(status, 200);
    assert.equal(body.success, true);
    assert.ok(Array.isArray(body.data));
    assert.ok(body.data.some((e) => e.id === enquiryId));
  });

  it('24. Buyer enquiry list includes artisan and product summary', async () => {
    const { status, body } = await api('GET', '/api/v1/enquiries/my', { token: buyerToken });
    assert.equal(status, 200);
    const enq = body.data.find((e) => e.id === enquiryId);
    assert.ok(enq, 'Enquiry must appear in list');
    assert.ok(enq.artisan, 'Artisan summary must be present');
    assert.equal(enq.artisan.name, 'Test Artisan');
    assert.ok(enq.product, 'Product summary must be present');
  });

  it('25. Artisan cannot access buyer enquiry list (403)', async () => {
    const { status } = await api('GET', '/api/v1/enquiries/my', { token: artisanToken });
    assert.equal(status, 403);
  });

  it('26. Unauthenticated enquiry list is rejected (401)', async () => {
    const { status } = await api('GET', '/api/v1/enquiries/my');
    assert.equal(status, 401);
  });

  // ── F. GET /api/v1/orders/my ───────────────────────────────────────────────

  it('27. Buyer can list their own orders', async () => {
    const { status, body } = await api('GET', '/api/v1/orders/my', { token: buyerToken });
    assert.equal(status, 200);
    assert.equal(body.success, true);
    assert.ok(Array.isArray(body.data));
    assert.ok(body.data.some((o) => o.id === orderId));
  });

  it('28. Buyer order list includes artisan and product summary', async () => {
    const { status, body } = await api('GET', '/api/v1/orders/my', { token: buyerToken });
    assert.equal(status, 200);
    const order = body.data.find((o) => o.id === orderId);
    assert.ok(order, 'Order must appear in list');
    assert.ok(order.artisan, 'Artisan summary must be present');
    assert.equal(order.artisan.name, 'Test Artisan');
    assert.ok(order.product, 'Product summary must be present');
  });

  it('29. Order list includes pagination metadata', async () => {
    const { status, body } = await api('GET', '/api/v1/orders/my?page=1&limit=5', {
      token: buyerToken,
    });
    assert.equal(status, 200);
    assert.ok(typeof body.pagination.total === 'number');
    assert.equal(body.pagination.page, 1);
    assert.equal(body.pagination.limit, 5);
  });

  it('30. Artisan cannot access buyer order list (403)', async () => {
    const { status } = await api('GET', '/api/v1/orders/my', { token: artisanToken });
    assert.equal(status, 403);
  });

  it('31. Unauthenticated order list is rejected (401)', async () => {
    const { status } = await api('GET', '/api/v1/orders/my');
    assert.equal(status, 401);
  });

  // ── G. GET /api/auth/me — no OTP fields ───────────────────────────────────

  it('32. GET /auth/me does NOT expose otpHash', async () => {
    const { status, body } = await api('GET', '/api/auth/me', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(!('otpHash' in body.user), 'otpHash must not be present');
  });

  it('33. GET /auth/me does NOT expose otpExpiresAt', async () => {
    const { status, body } = await api('GET', '/api/auth/me', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(!('otpExpiresAt' in body.user), 'otpExpiresAt must not be present');
  });

  it('34. GET /auth/me does NOT expose otpAttempts', async () => {
    const { status, body } = await api('GET', '/api/auth/me', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(!('otpAttempts' in body.user), 'otpAttempts must not be present');
  });

  it('35. GET /auth/me returns buyerProfile for buyer', async () => {
    const { status, body } = await api('GET', '/api/auth/me', { token: buyerToken });
    assert.equal(status, 200);
    assert.ok(body.user.buyerProfile, 'buyerProfile must be present');
    assert.equal(body.user.role, 'BUYER');
  });

  it('36. GET /auth/me unauthenticated is rejected (401)', async () => {
    const { status } = await api('GET', '/api/auth/me');
    assert.equal(status, 401);
  });

});
