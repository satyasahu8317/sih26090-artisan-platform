import path from 'path';
import crypto from 'crypto';
import { PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { b2Client, B2_BUCKET_NAME } from '../config/b2.js';

/**
 * Sanitizes original filename to prevent path traversal and ensure safe object keys.
 * @param {string} originalName
 * @returns {string} Safe filename
 */
export const sanitizeFilename = (originalName) => {
  if (!originalName || typeof originalName !== 'string') {
    return 'media';
  }
  // Strip directory paths (e.g., ../../../evil.jpg -> evil.jpg)
  const baseName = path.basename(originalName);
  // Replace all non-alphanumeric, non-period, non-hyphen, non-underscore chars
  const sanitized = baseName.replace(/[^a-zA-Z0-9._-]/g, '_').replace(/^\.+/, '');
  return sanitized || 'media';
};

/**
 * Resolves signed URL expiration in seconds from environment variable or default (3600s).
 * @returns {number}
 */
const getExpirationSeconds = () => {
  const envVal = parseInt(process.env.B2_SIGNED_URL_EXPIRES_SECONDS, 10);
  return (!isNaN(envVal) && envVal > 0) ? envVal : 3600;
};

/**
 * Backblaze B2 Storage Service for Catalogue Media.
 * Interacts with private B2 bucket using S3-compatible API and generates temporary presigned GET URLs.
 */
export const b2StorageService = {
  /**
   * Generates a temporary presigned GET URL for a private B2 object key.
   * @param {string} key - Object key in the bucket
   * @param {number} [expiresInSeconds] - Optional expiration in seconds
   * @returns {Promise<string>} - Temporary signed GET URL
   */
  getSignedUrl: async (key, expiresInSeconds) => {
    const bucket = process.env.B2_BUCKET_NAME || B2_BUCKET_NAME;
    const expiresIn = expiresInSeconds || getExpirationSeconds();

    const command = new GetObjectCommand({
      Bucket: bucket,
      Key: key
    });

    return await getSignedUrl(b2Client, command, { expiresIn });
  },

  /**
   * Uploads an image to Backblaze B2 and returns a temporary signed URL.
   * @param {Buffer} buffer - Image file buffer
   * @param {string} originalName - Original filename
   * @param {string} mimeType - MIME type of the image
   * @param {string} artisanId - Unique artisan ID
   * @returns {Promise<{url: string, key: string, path: string, contentType: string}>}
   */
  uploadImage: async (buffer, originalName, mimeType, artisanId) => {
    const bucket = process.env.B2_BUCKET_NAME || B2_BUCKET_NAME;
    const uuid = crypto.randomUUID();
    const cleanName = sanitizeFilename(originalName);
    const key = `catalogue/${artisanId}/${uuid}/image-${cleanName}`;

    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: buffer,
      ContentType: mimeType
    });

    await b2Client.send(command);

    const signedUrl = await b2StorageService.getSignedUrl(key);

    return {
      url: signedUrl,
      key,
      path: key,
      contentType: mimeType
    };
  },

  /**
   * Uploads an audio file to Backblaze B2 and returns a temporary signed URL.
   * @param {Buffer} buffer - Audio file buffer
   * @param {string} originalName - Original filename
   * @param {string} mimeType - MIME type of the audio
   * @param {string} artisanId - Unique artisan ID
   * @returns {Promise<{url: string, key: string, path: string, contentType: string}>}
   */
  uploadAudio: async (buffer, originalName, mimeType, artisanId) => {
    const bucket = process.env.B2_BUCKET_NAME || B2_BUCKET_NAME;
    const uuid = crypto.randomUUID();
    const cleanName = sanitizeFilename(originalName);
    const key = `catalogue/${artisanId}/${uuid}/audio-${cleanName}`;

    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: buffer,
      ContentType: mimeType
    });

    await b2Client.send(command);

    const signedUrl = await b2StorageService.getSignedUrl(key);

    return {
      url: signedUrl,
      key,
      path: key,
      contentType: mimeType
    };
  },

  /**
   * Compatibility adapter for legacy call pattern.
   */
  uploadCatalogueMedia: async (buffer, artisanId, type, originalName, mimeType) => {
    if (type === 'image') {
      return b2StorageService.uploadImage(buffer, originalName, mimeType, artisanId);
    } else {
      return b2StorageService.uploadAudio(buffer, originalName, mimeType, artisanId);
    }
  }
};
