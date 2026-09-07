import { getFirebaseApp } from '../config/firebase.js';
import crypto from 'crypto';

/**
 * Uploads media (image/audio) to Firebase Storage for the catalogue ML flow.
 * @param {Buffer} fileBuffer - The file buffer in memory
 * @param {string} artisanId - The ID of the artisan uploading the file
 * @param {string} type - 'image' or 'audio'
 * @param {string} originalName - Original filename
 * @param {string} mimeType - MIME type of the file
 * @returns {Promise<{url: string, path: string}>} - The public URL and storage path
 */
export const firebaseStorageService = {
  uploadCatalogueMedia: async (fileBuffer, artisanId, type, originalName, mimeType) => {
    const app = getFirebaseApp();
    if (!app) {
      throw new Error('Firebase is not configured on the server');
    }

    const bucket = app.storage().bucket();
    const uuid = crypto.randomUUID();
    const extension = originalName.split('.').pop();
    
    const basePath = `catalogue/${artisanId}/${uuid}`;
    const fileName = type === 'image' ? `original-image.${extension}` : `audio.${extension}`;
    const storagePath = `${basePath}/${fileName}`;

    const file = bucket.file(storagePath);
    
    await file.save(fileBuffer, {
      metadata: {
        contentType: mimeType,
        metadata: {
          artisanId,
          type
        }
      }
    });

    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 60 * 24 * 7 // 7 days
    });

    return { url, path: storagePath };
  }
};
