import admin from 'firebase-admin';
import dotenv from 'dotenv';
dotenv.config();

let firebaseApp = null;

export const getFirebaseApp = () => {
  if (firebaseApp) return firebaseApp;

  // Use base64 encoded service account to avoid multi-line .env issues
  const base64ServiceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

  if (!base64ServiceAccount) {
    console.warn('FIREBASE_SERVICE_ACCOUNT_BASE64 is not set. Firebase Admin not initialized.');
    return null;
  }

  try {
    const serviceAccountJson = Buffer.from(base64ServiceAccount, 'base64').toString('ascii');
    const serviceAccount = JSON.parse(serviceAccountJson);

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: storageBucket || `${serviceAccount.project_id}.appspot.com`
    });

    return firebaseApp;
  } catch (error) {
    console.error('Failed to initialize Firebase Admin:', error);
    return null;
  }
};
