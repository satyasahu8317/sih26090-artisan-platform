import { S3Client } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';
dotenv.config();

/**
 * Ensures endpoint is a fully qualified URL with protocol for AWS S3 SDK.
 * Reads strictly from environment without hardcoded endpoint fallbacks.
 */
const resolveEndpoint = (endpoint) => {
  if (!endpoint) return undefined;
  return endpoint.startsWith('http://') || endpoint.startsWith('https://')
    ? endpoint
    : `https://${endpoint}`;
};

export const b2Client = new S3Client({
  endpoint: resolveEndpoint(process.env.B2_ENDPOINT),
  region: process.env.B2_REGION,
  credentials: {
    accessKeyId: process.env.B2_KEY_ID || '',
    secretAccessKey: process.env.B2_APPLICATION_KEY || ''
  }
});

export const B2_BUCKET_NAME = process.env.B2_BUCKET_NAME;
