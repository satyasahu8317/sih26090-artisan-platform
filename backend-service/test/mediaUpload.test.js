import { describe, it, before, beforeEach, afterEach, mock } from 'node:test';
import assert from 'node:assert';
import request from 'supertest';
import express from 'express';
import aiRoutes from '../src/routes/aiRoutes.js';
import { firebaseStorageService } from '../src/services/firebaseStorage.js';
import prisma from '../src/config/db.js';
import jwt from 'jsonwebtoken';
import fs from 'fs';
import path from 'path';
import os from 'os';

const app = express();
app.use(express.json());
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

describe('Media Upload API', () => {
  let artisanToken = null;
  let buyerToken = null;
  let testImageFile = path.join(os.tmpdir(), 'test-image.jpg');
  let testAudioFile = path.join(os.tmpdir(), 'test-audio.mp3');

  before(async () => {
    mock.method(firebaseStorageService, 'uploadCatalogueMedia', async (fileBuffer, artisanId, type, originalName, mimeType) => {
      if (originalName.includes('fail')) throw new Error('Firebase mock error');
      return {
        url: `https://storage.googleapis.com/mock-bucket/catalogue/${artisanId}/uuid-123/${type}.ext`,
        path: `catalogue/${artisanId}/uuid-123/${type}.ext`
      };
    });
  });

  beforeEach(async () => {
    fs.writeFileSync(testImageFile, Buffer.from('fake image content'));
    fs.writeFileSync(testAudioFile, Buffer.from('fake audio content'));

    await prisma.artisanProfile.deleteMany({ where: { userId: 'user-artisan-media' } });
    await prisma.user.deleteMany({ where: { id: 'user-artisan-media' } });
    await prisma.user.deleteMany({ where: { id: 'user-buyer-media' } });

    const user = await prisma.user.create({
      data: {
        id: 'user-artisan-media',
        mobileNumber: '9999999998',
        role: 'ARTISAN',
        status: 'ACTIVE'
      }
    });

    const buyer = await prisma.user.create({
      data: {
        id: 'user-buyer-media',
        mobileNumber: '8888888887',
        role: 'BUYER',
        status: 'ACTIVE'
      }
    });

    artisanToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only', { expiresIn: '1d' });
    buyerToken = jwt.sign({ id: buyer.id }, process.env.JWT_SECRET || 'super_secret_jwt_key_for_dev_only', { expiresIn: '1d' });

    await prisma.artisanProfile.create({
      data: {
        userId: user.id,
        name: 'Test Artisan Media',
        craftType: 'Wood',
        state: 'Kerala',
        district: 'Ernakulam',
        preferredLanguage: 'en'
      }
    });
  });

  afterEach(async () => {
    if (fs.existsSync(testImageFile)) fs.unlinkSync(testImageFile);
    if (fs.existsSync(testAudioFile)) fs.unlinkSync(testAudioFile);
    
    await prisma.artisanProfile.deleteMany({ where: { userId: 'user-artisan-media' } });
    await prisma.user.deleteMany({ where: { id: 'user-artisan-media' } });
    await prisma.user.deleteMany({ where: { id: 'user-buyer-media' } });
  });

  it('1. should reject unauthenticated requests', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/image')
      .attach('file', testImageFile);
    assert.strictEqual(res.statusCode, 401);
  });

  it('2. should reject buyer uploads', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/image')
      .set('Authorization', `Bearer ${buyerToken}`)
      .attach('file', testImageFile);
    assert.strictEqual(res.statusCode, 403);
  });

  it('3. should reject missing file', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/image')
      .set('Authorization', `Bearer ${artisanToken}`);
    assert.strictEqual(res.statusCode, 400);
    assert.match(res.body.message, /Missing image file/);
  });

  it('4. should reject unsupported mime type for image', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/image')
      .set('Authorization', `Bearer ${artisanToken}`)
      .attach('file', testImageFile, { filename: 'test.txt', contentType: 'text/plain' });
    assert.strictEqual(res.statusCode, 400);
    assert.match(res.body.message, /Unsupported image format/);
  });

  it('5. should upload image successfully', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/image')
      .set('Authorization', `Bearer ${artisanToken}`)
      .attach('file', testImageFile);
    
    assert.strictEqual(res.statusCode, 201);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.data.url.includes('mock-bucket'));
  });

  it('6. should upload audio successfully', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/audio')
      .set('Authorization', `Bearer ${artisanToken}`)
      .attach('file', testAudioFile);
    
    assert.strictEqual(res.statusCode, 201);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.data.url.includes('audio'));
  });

  it('7. should handle firebase errors properly', async () => {
    const res = await request(app)
      .post('/api/v1/ai/media/image')
      .set('Authorization', `Bearer ${artisanToken}`)
      .attach('file', testImageFile, { filename: 'fail.jpg', contentType: 'image/jpeg' });
    
    assert.strictEqual(res.statusCode, 500);
    assert.match(res.body.message, /Firebase mock error/);
  });
});
