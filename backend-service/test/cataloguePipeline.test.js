import { describe, it, beforeEach, afterEach, mock } from 'node:test';
import assert from 'node:assert';
import request from 'supertest';
import express from 'express';
import aiRoutes from '../src/routes/aiRoutes.js';
import * as mlClient from '../src/services/mlClient.js';
import prisma from '../src/config/db.js';

import jwt from 'jsonwebtoken';

const app = express();
app.use(express.json());

// Protect all routes with real middleware
app.use('/api/v1/ai', aiRoutes);

app.use((err, req, res, next) => {
  let statusCode = err.status || res.statusCode;
  if (statusCode === 200) statusCode = 500;
  res.status(statusCode).json({
    success: false,
    message: err.message,
    details: err.details || null
  });
});

describe('Catalogue Pipeline API', () => {
  let createdProductId = null;
  let artisanProfile = null;
  let artisanToken = null;
  let buyerToken = null;

  beforeEach(async () => {
    // Setup test DB data
    const user = await prisma.user.create({
      data: {
        id: 'user-artisan',
        mobileNumber: '9999999999',
        role: 'ARTISAN',
        status: 'ACTIVE'
      }
    });

    const buyer = await prisma.user.create({
      data: {
        id: 'user-buyer',
        mobileNumber: '8888888888',
        role: 'BUYER',
        status: 'ACTIVE'
      }
    });

    artisanToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only', { expiresIn: '1d' });
    buyerToken = jwt.sign({ id: buyer.id }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only', { expiresIn: '1d' });

    artisanProfile = await prisma.artisanProfile.create({
      data: {
        userId: user.id,
        name: 'Test Artisan',
        craftType: 'Wood',
        state: 'Kerala',
        district: 'Ernakulam',
        preferredLanguage: 'en'
      }
    });

    mock.method(global, 'fetch', async (url, options) => {
      if (url.includes('/image/enhance') && options.method === 'POST') {
        return { ok: true, json: async () => ({ jobId: 'img-123' }) };
      }
      if (url.includes('/image/enhance/img-123') && options.method === 'GET') {
        return { ok: true, json: async () => ({ status: 'SUCCESS', result: { enhancedImageUrl: 'https://enhanced.com/img.jpg' } }) };
      }
      if (url.includes('/audio/transcribe') && options.method === 'POST') {
        return { ok: true, json: async () => ({ jobId: 'aud-123' }) };
      }
      if (url.includes('/audio/transcribe/aud-123') && options.method === 'GET') {
        return { ok: true, json: async () => ({ status: 'SUCCESS', result: { transcript: 'Wooden toy', detectedLanguage: 'en', confidence: 0.99 } }) };
      }
      if (url.includes('/text/translate') && options.method === 'POST') {
        return { ok: true, json: async () => ({ translations: { 'en': 'Wooden toy translated' } }) };
      }
      if (url.includes('/text/generate-description') && options.method === 'POST') {
        return { ok: true, json: async () => ({
          descriptionEn: 'A beautiful wooden toy.',
          descriptionHi: 'एक सुंदर लकड़ी का खिलौना।',
          seoKeywords: ['wood', 'toy']
        }) };
      }
      if (url.includes('/price/suggest') && options.method === 'POST') {
        return { ok: true, json: async () => ({
          suggestedPriceMin: 100,
          suggestedPriceMax: 200,
          currency: 'INR',
          explanation: 'Based on materials.',
          featuresUsed: ['category']
        }) };
      }
      return { ok: false, status: 404, json: async () => ({ detail: 'Not found' }) };
    });
  });

  afterEach(async () => {
    mock.restoreAll();

    if (createdProductId) {
      await prisma.product.deleteMany({ where: { id: createdProductId } });
      createdProductId = null;
    }
    
    await prisma.artisanProfile.deleteMany({ where: { userId: 'user-artisan' } });
    await prisma.user.deleteMany({ where: { id: 'user-artisan' } });
    await prisma.user.deleteMany({ where: { id: 'user-buyer' } });
  });

  it('1. should reject unauthenticated requests', async () => {
    const res = await request(app)
      .post('/api/v1/ai/catalogue/ml-generate')
      .send({ productName: { en: 'test', hi: 'test' }, category: 'wood' });
    
    assert.strictEqual(res.statusCode, 401);
  });

  it('2. should reject non-artisan users (buyer)', async () => {
    const res = await request(app)
      .post('/api/v1/ai/catalogue/ml-generate')
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({ productName: { en: 'test', hi: 'test' }, category: 'wood' });
    
    assert.strictEqual(res.statusCode, 403);
    assert.match(res.body.message, /Only artisans/);
  });

  it('3. should succeed with complete pipeline and save pricing/product fields', async () => {
    const payload = {
      productName: { en: 'Handmade Wooden Elephant', hi: 'हाथ से बना लकड़ी का हाथी' },
      imageUrl: 'https://raw.com/img.jpg',
      audioUrl: 'https://raw.com/aud.mp3',
      category: 'Wood Craft',
      material: 'Rosewood',
      region: 'Kerala',
      materialCost: 50
    };

    const res = await request(app)
      .post('/api/v1/ai/catalogue/ml-generate')
      .set('Authorization', `Bearer ${artisanToken}`)
      .send(payload);
    
    assert.strictEqual(res.statusCode, 201);
    assert.strictEqual(res.body.success, true);
    
    const data = res.body.data;
    createdProductId = data.id;

    assert.ok(createdProductId);
    assert.strictEqual(data.status, 'DRAFT');
    assert.strictEqual(data.artisanId, artisanProfile.id);
    assert.strictEqual(data.imageUrl, 'https://enhanced.com/img.jpg');
    assert.deepStrictEqual(data.description, {
      en: 'A beautiful wooden toy.',
      hi: 'एक सुंदर लकड़ी का खिलौना।'
    });
    assert.deepStrictEqual(data.tags, ['wood', 'toy']);
    
    // Check pricing object mapped out to response
    assert.strictEqual(data.pricing.suggestedPriceMin, 100);
    assert.strictEqual(data.pricing.suggestedPriceMax, 200);

    // Verify DB persistence exactly matches
    const dbProduct = await prisma.product.findUnique({ where: { id: createdProductId } });
    assert.ok(dbProduct);
    assert.strictEqual(dbProduct.suggestedPriceMin, 100);
    assert.strictEqual(dbProduct.suggestedPriceMax, 200);
    assert.strictEqual(dbProduct.currency, 'INR');
    assert.strictEqual(dbProduct.pricingExplanation, 'Based on materials.');
  });

  it('4. should fail safely if ML pipeline throws, not persisting product', async () => {
    // Force translation to fail
    mock.method(global, 'fetch', async (url, options) => {
      if (url.includes('/image/enhance') && options.method === 'POST') {
        return { ok: true, json: async () => ({ jobId: 'img-123' }) };
      }
      if (url.includes('/image/enhance/img-123') && options.method === 'GET') {
        return { ok: true, json: async () => ({ status: 'SUCCESS', result: { enhancedImageUrl: 'https://enhanced.com/img.jpg' } }) };
      }
      if (url.includes('/audio/transcribe') && options.method === 'POST') {
        return { ok: true, json: async () => ({ jobId: 'aud-123' }) };
      }
      if (url.includes('/audio/transcribe/aud-123') && options.method === 'GET') {
        return { ok: true, json: async () => ({ status: 'SUCCESS', result: { transcript: 'Wooden toy', detectedLanguage: 'en', confidence: 0.99 } }) };
      }
      if (url.includes('/text/translate') && options.method === 'POST') {
        return { ok: false, status: 502, json: async () => ({ detail: 'Translation failed upstream' }) };
      }
      return { ok: false, status: 404, json: async () => ({ detail: 'Not found' }) };
    });

    const payload = {
      productName: { en: 'test', hi: 'test' },
      category: 'Wood Craft',
      audioUrl: 'https://raw.com/aud.mp3'
    };

    const res = await request(app)
      .post('/api/v1/ai/catalogue/ml-generate')
      .set('Authorization', `Bearer ${artisanToken}`)
      .send(payload);
    
    assert.strictEqual(res.statusCode, 502);
    assert.strictEqual(res.body.success, false);
    
    // Assert DB is empty for this artisan
    const products = await prisma.product.findMany({ where: { artisanId: artisanProfile.id } });
    assert.strictEqual(products.length, 0);
  });
});
