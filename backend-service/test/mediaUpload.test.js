import { describe, it, before, after, beforeEach, afterEach, mock } from 'node:test';
import assert from 'node:assert';
import request from 'supertest';
import express from 'express';
import aiRoutes from '../src/routes/aiRoutes.js';
import { b2StorageService } from '../src/services/b2Storage.js';
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

describe('Media Upload API (Backblaze B2)', () => {
  let artisanToken = null;
  let buyerToken = null;
  let testImageFile = path.join(os.tmpdir(), 'test-image.jpg');
  let testAudioFile = path.join(os.tmpdir(), 'test-audio.mp3');

  before(async () => {
    mock.method(b2StorageService, 'uploadImage', async (buffer, originalName, mimeType, artisanId) => {
      if (originalName.includes('fail')) throw new Error('B2 storage mock error');
      const key = `catalogue/${artisanId}/uuid-img-123/image-${originalName}`;
      return {
        url: `https://s3.us-east-005.backblazeb2.com/sihartisanmedia/${key}?X-Amz-Expires=3600`,
        key,
        path: key,
        contentType: mimeType
      };
    });

    mock.method(b2StorageService, 'uploadAudio', async (buffer, originalName, mimeType, artisanId) => {
      if (originalName.includes('fail')) throw new Error('B2 storage mock error');
      const key = `catalogue/${artisanId}/uuid-aud-123/audio-${originalName}`;
      return {
        url: `https://s3.us-east-005.backblazeb2.com/sihartisanmedia/${key}?X-Amz-Expires=3600`,
        key,
        path: key,
        contentType: mimeType
      };
    });

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

  beforeEach(() => {
    fs.writeFileSync(testImageFile, Buffer.from('fake image content'));
    fs.writeFileSync(testAudioFile, Buffer.from('fake audio content'));
  });

  afterEach(() => {
    if (fs.existsSync(testImageFile)) fs.unlinkSync(testImageFile);
    if (fs.existsSync(testAudioFile)) fs.unlinkSync(testAudioFile);
  });

  after(async () => {
    await prisma.artisanProfile.deleteMany({ where: { userId: 'user-artisan-media' } });
    await prisma.user.deleteMany({ where: { id: 'user-artisan-media' } });
    await prisma.user.deleteMany({ where: { id: 'user-buyer-media' } });
  });

  describe('Image Upload Tests', () => {
    it('1. should reject unauthenticated requests', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/image');
      assert.strictEqual(res.statusCode, 401);
    });

    it('2. should reject non-artisan (buyer) uploads', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/image')
        .set('Authorization', `Bearer ${buyerToken}`)
        .attach('file', testImageFile);
      assert.strictEqual(res.statusCode, 403);
      assert.match(res.body.message, /Only artisans/);
    });

    it('3. should reject missing image file', async () => {
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

    it('5. should reject image exceeding 10 MB', async () => {
      const largeBuffer = Buffer.alloc(11 * 1024 * 1024);
      const res = await request(app)
        .post('/api/v1/ai/media/image')
        .set('Authorization', `Bearer ${artisanToken}`)
        .attach('file', largeBuffer, { filename: 'large.jpg', contentType: 'image/jpeg' });
      assert.strictEqual(res.statusCode, 413);
      assert.match(res.body.message, /exceeds/);
    });

    it('6. should upload image successfully to B2 and return signed URL', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/image')
        .set('Authorization', `Bearer ${artisanToken}`)
        .attach('file', testImageFile, { filename: 'pottery.jpg', contentType: 'image/jpeg' });

      assert.strictEqual(res.statusCode, 201);
      assert.strictEqual(res.body.success, true);
      assert.ok(res.body.data.url.includes('sihartisanmedia'));
      assert.ok(res.body.data.url.includes('X-Amz-Expires=3600'));
      assert.ok(res.body.data.path.startsWith('catalogue/'));
      assert.ok(res.body.data.path.includes('image-pottery.jpg'));
      assert.strictEqual(res.body.data.contentType, 'image/jpeg');
    });

    it('7. should handle B2 upload errors cleanly', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/image')
        .set('Authorization', `Bearer ${artisanToken}`)
        .attach('file', testImageFile, { filename: 'fail.jpg', contentType: 'image/jpeg' });

      assert.strictEqual(res.statusCode, 500);
      assert.match(res.body.message, /B2 storage mock error/);
    });
  });

  describe('Audio Upload Tests', () => {
    it('8. should reject unauthenticated audio requests', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/audio');
      assert.strictEqual(res.statusCode, 401);
    });

    it('9. should reject non-artisan (buyer) audio uploads', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/audio')
        .set('Authorization', `Bearer ${buyerToken}`)
        .attach('file', testAudioFile);
      assert.strictEqual(res.statusCode, 403);
      assert.match(res.body.message, /Only artisans/);
    });

    it('10. should reject missing audio file', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/audio')
        .set('Authorization', `Bearer ${artisanToken}`);
      assert.strictEqual(res.statusCode, 400);
      assert.match(res.body.message, /Missing audio file/);
    });

    it('11. should reject unsupported mime type for audio', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/audio')
        .set('Authorization', `Bearer ${artisanToken}`)
        .attach('file', testAudioFile, { filename: 'test.pdf', contentType: 'application/pdf' });
      assert.strictEqual(res.statusCode, 400);
      assert.match(res.body.message, /Unsupported audio format/);
    });

    it('12. should upload audio successfully to B2 and return signed URL', async () => {
      const res = await request(app)
        .post('/api/v1/ai/media/audio')
        .set('Authorization', `Bearer ${artisanToken}`)
        .attach('file', testAudioFile, { filename: 'description.mp3', contentType: 'audio/mpeg' });

      assert.strictEqual(res.statusCode, 201);
      assert.strictEqual(res.body.success, true);
      assert.ok(res.body.data.url.includes('sihartisanmedia'));
      assert.ok(res.body.data.url.includes('X-Amz-Expires=3600'));
      assert.ok(res.body.data.path.startsWith('catalogue/'));
      assert.ok(res.body.data.path.includes('audio-description.mp3'));
      assert.strictEqual(res.body.data.contentType, 'audio/mpeg');
    });
  });
});
