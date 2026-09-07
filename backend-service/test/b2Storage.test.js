import { describe, it, before, beforeEach, afterEach, mock } from 'node:test';
import assert from 'node:assert';
// Ensure test environment variables exist before importing b2Client / b2StorageService
process.env.B2_ENDPOINT = process.env.B2_ENDPOINT || 'https://s3.us-east-005.backblazeb2.com';
process.env.B2_REGION = process.env.B2_REGION || 'us-east-005';
process.env.B2_BUCKET_NAME = process.env.B2_BUCKET_NAME || 'sihartisanmedia';
process.env.B2_KEY_ID = process.env.B2_KEY_ID || 'dummy-ci-key-id';
process.env.B2_APPLICATION_KEY = process.env.B2_APPLICATION_KEY || 'dummy-ci-application-key';

const { b2StorageService, sanitizeFilename } = await import('../src/services/b2Storage.js');
const { b2Client } = await import('../src/config/b2.js');

describe('B2 Storage Service Unit Tests', () => {
  let sentCommands = [];
  const originalEnvExpires = process.env.B2_SIGNED_URL_EXPIRES_SECONDS;

  before(() => {
    process.env.B2_ENDPOINT = process.env.B2_ENDPOINT || 'https://s3.us-east-005.backblazeb2.com';
    process.env.B2_REGION = process.env.B2_REGION || 'us-east-005';
    process.env.B2_BUCKET_NAME = process.env.B2_BUCKET_NAME || 'sihartisanmedia';

    if (b2Client && b2Client.config) {
      b2Client.config.region = async () => process.env.B2_REGION || 'us-east-005';
    }
  });

  beforeEach(() => {
    sentCommands = [];
    mock.method(b2Client, 'send', async (command) => {
      sentCommands.push(command);
      return { $metadata: { httpStatusCode: 200 } };
    });
  });

  afterEach(() => {
    mock.restoreAll();
    process.env.B2_SIGNED_URL_EXPIRES_SECONDS = originalEnvExpires;
  });

  describe('Filename Sanitization & Path Traversal Prevention', () => {
    it('1. should strip directory traversal sequences', () => {
      assert.strictEqual(sanitizeFilename('../../calc.exe'), 'calc.exe');
      assert.strictEqual(sanitizeFilename('../../evil.jpg'), 'evil.jpg');
      assert.strictEqual(sanitizeFilename('../../../secret/photo.png'), 'photo.png');
      assert.strictEqual(sanitizeFilename('C:\\Windows\\System32\\calc.exe'), 'calc.exe');
    });

    it('2. should replace special/unsafe characters with underscores', () => {
      assert.strictEqual(sanitizeFilename('artisan craft (1) @ #.jpg'), 'artisan_craft__1_____.jpg');
    });

    it('3. should strip leading dots and fallback safely for dotfiles or empty input', () => {
      assert.strictEqual(sanitizeFilename('...'), 'media');
      assert.strictEqual(sanitizeFilename('.hidden'), 'hidden');
      assert.strictEqual(sanitizeFilename(''), 'media');
      assert.strictEqual(sanitizeFilename(null), 'media');
      assert.strictEqual(sanitizeFilename(undefined), 'media');
    });
  });

  describe('Image Upload', () => {
    it('4. should upload image using PutObjectCommand and return signed URL and key', async () => {
      const buffer = Buffer.from('fake image data');
      const result = await b2StorageService.uploadImage(
        buffer,
        '../../my craft photo.jpg',
        'image/jpeg',
        'artisan-123'
      );

      assert.strictEqual(sentCommands.length, 1);
      const cmd = sentCommands[0];

      // Verify PutObjectCommand parameters
      assert.strictEqual(cmd.input.Bucket, process.env.B2_BUCKET_NAME || 'sihartisanmedia');
      assert.strictEqual(cmd.input.ContentType, 'image/jpeg');
      assert.deepStrictEqual(cmd.input.Body, buffer);

      // Verify Key format: catalogue/{artisanId}/{uuid}/image-{sanitizedName}
      const keyPattern = /^catalogue\/artisan-123\/[0-9a-fA-F-]+\/image-my_craft_photo\.jpg$/;
      assert.match(cmd.input.Key, keyPattern);

      // Verify return object structure
      assert.strictEqual(result.key, cmd.input.Key);
      assert.strictEqual(result.path, cmd.input.Key);
      assert.strictEqual(result.contentType, 'image/jpeg');
      assert.ok(typeof result.url === 'string');
      assert.ok(result.url.includes(cmd.input.Key));
    });
  });

  describe('Audio Upload', () => {
    it('5. should upload audio using PutObjectCommand with audio prefix', async () => {
      const buffer = Buffer.from('fake audio data');
      const result = await b2StorageService.uploadAudio(
        buffer,
        'recording.m4a',
        'audio/x-m4a',
        'artisan-456'
      );

      assert.strictEqual(sentCommands.length, 1);
      const cmd = sentCommands[0];

      assert.strictEqual(cmd.input.Bucket, process.env.B2_BUCKET_NAME || 'sihartisanmedia');
      assert.strictEqual(cmd.input.ContentType, 'audio/x-m4a');

      // Verify Key format: catalogue/{artisanId}/{uuid}/audio-{sanitizedName}
      const keyPattern = /^catalogue\/artisan-456\/[0-9a-fA-F-]+\/audio-recording\.m4a$/;
      assert.match(cmd.input.Key, keyPattern);

      assert.strictEqual(result.key, cmd.input.Key);
      assert.strictEqual(result.path, cmd.input.Key);
      assert.strictEqual(result.contentType, 'audio/x-m4a');
      assert.ok(result.url.includes(cmd.input.Key));
    });
  });

  describe('Signed URL Generation & Expiration', () => {
    it('6. should respect configured B2_SIGNED_URL_EXPIRES_SECONDS', async () => {
      process.env.B2_SIGNED_URL_EXPIRES_SECONDS = '1800';
      const key = 'catalogue/artisan-123/uuid-test/image-test.jpg';
      const url = await b2StorageService.getSignedUrl(key);

      assert.ok(url.includes('X-Amz-Expires=1800'));
      assert.ok(url.includes('catalogue/artisan-123/uuid-test/image-test.jpg'));
    });

    it('7. should default to 3600 seconds when env var is missing or invalid', async () => {
      delete process.env.B2_SIGNED_URL_EXPIRES_SECONDS;
      const key = 'catalogue/artisan-123/uuid-test/audio-test.mp3';
      const url = await b2StorageService.getSignedUrl(key);

      assert.ok(url.includes('X-Amz-Expires=3600'));
    });
  });

  describe('Error Handling', () => {
    it('8. should cleanly bubble B2 upload errors', async () => {
      mock.restoreAll();
      mock.method(b2Client, 'send', async () => {
        const err = new Error('B2 Service Unavailable');
        err.name = 'ServiceUnavailable';
        throw err;
      });

      await assert.rejects(
        async () => {
          await b2StorageService.uploadImage(
            Buffer.from('data'),
            'test.png',
            'image/png',
            'artisan-999'
          );
        },
        /B2 Service Unavailable/
      );
    });
  });

  describe('Legacy uploadCatalogueMedia Adapter', () => {
    it('9. should delegate correctly for image and audio types', async () => {
      const buffer = Buffer.from('data');
      const imgRes = await b2StorageService.uploadCatalogueMedia(buffer, 'art-1', 'image', 'pic.jpg', 'image/jpeg');
      assert.match(imgRes.key, /image-pic\.jpg$/);

      const audRes = await b2StorageService.uploadCatalogueMedia(buffer, 'art-1', 'audio', 'rec.mp3', 'audio/mpeg');
      assert.match(audRes.key, /audio-rec\.mp3$/);
    });
  });
});
