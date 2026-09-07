import { generateStructuredCatalogue } from '../services/llmService.js';
import { transcribeAudioFile } from '../services/speechToTextService.js';
import fs from 'fs';
import * as mlClient from '../services/mlClient.js';
import prisma from '../config/db.js';
import crypto from 'crypto';

export const generateCatalogue = async (req, res, next) => {
  try {
    const { text } = req.body;

    if (!text || typeof text !== 'string' || text.trim().length === 0) {
      res.status(400);
      throw new Error('Please provide valid text for catalogue generation');
    }

    const catalogue = await generateStructuredCatalogue(text);

    res.status(200).json(catalogue);
  } catch (error) {
    next(error);
  }
};

export const transcribeAudio = async (req, res, next) => {
  try {
    if (!req.file) {
      res.status(400);
      throw new Error('No audio file provided');
    }

    // Add extension to the multer file so Groq SDK can infer the file type
    const originalExt = req.file.originalname.split('.').pop();
    const newPath = `${req.file.path}.${originalExt}`;
    fs.renameSync(req.file.path, newPath);
    req.file.path = newPath; // update path for cleanup later

    const result = await transcribeAudioFile(req.file.path);

    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  } finally {
    if (req.file && fs.existsSync(req.file.path)) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (cleanupError) {
        console.error('Error cleaning up audio file:', cleanupError);
      }
    }
  }
};

export const generateCatalogueFromAudio = async (req, res, next) => {
  try {
    if (!req.file) {
      res.status(400);
      throw new Error('No audio file provided');
    }

    // Add extension to the multer file so Groq SDK can infer the file type
    const originalExt = req.file.originalname.split('.').pop();
    const newPath = `${req.file.path}.${originalExt}`;
    fs.renameSync(req.file.path, newPath);
    req.file.path = newPath; // update path for cleanup later

    // Step 1: Transcribe the audio
    const transcriptionResult = await transcribeAudioFile(req.file.path);
    const transcript = transcriptionResult.text;

    if (!transcript || transcript.trim().length === 0) {
      res.status(422);
      throw new Error('Transcription resulted in empty text');
    }

    // Step 2: Generate catalogue from transcript
    const catalogue = await generateStructuredCatalogue(transcript);

    // Step 3: Return combined result
    res.status(200).json({
      success: true,
      data: {
        transcript,
        language: transcriptionResult.language,
        catalogue
      }
    });
  } catch (error) {
    next(error);
  } finally {
    if (req.file && fs.existsSync(req.file.path)) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (cleanupError) {
        console.error('Error cleaning up audio file:', cleanupError);
      }
    }
  }
};

export const getMlHealth = async (req, res, next) => {
  try {
    const data = await mlClient.checkHealth();
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const testMlImage = async (req, res, next) => {
  try {
    const { imageUrl } = req.body;
    if (!imageUrl) {
      res.status(400);
      throw new Error('Missing imageUrl in request body');
    }

    const { jobId } = await mlClient.startImageEnhancement(imageUrl);
    const finalResult = await mlClient.pollJobStatus(mlClient.getImageEnhancementStatus, jobId);
    
    res.status(200).json({ success: true, data: finalResult });
  } catch (error) {
    next(error);
  }
};

export const testMlAudio = async (req, res, next) => {
  try {
    const { audioUrl, hintLanguage } = req.body;
    if (!audioUrl) {
      res.status(400);
      throw new Error('Missing audioUrl in request body');
    }

    const { jobId } = await mlClient.startAudioTranscription(audioUrl, null, hintLanguage);
    const finalResult = await mlClient.pollJobStatus(mlClient.getAudioTranscriptionStatus, jobId);
    
    res.status(200).json({ success: true, data: finalResult });
  } catch (error) {
    next(error);
  }
};

import { firebaseStorageService } from '../services/firebaseStorage.js';

export const uploadMediaImage = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can upload media');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const { url, path } = await firebaseStorageService.uploadCatalogueMedia(
      req.file.buffer,
      artisanProfile.id,
      'image',
      req.file.originalname,
      req.file.mimetype
    );

    res.status(201).json({
      success: true,
      data: { url, path, contentType: req.file.mimetype }
    });
  } catch (error) {
    next(error);
  }
};

export const uploadMediaAudio = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can upload media');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const { url, path } = await firebaseStorageService.uploadCatalogueMedia(
      req.file.buffer,
      artisanProfile.id,
      'audio',
      req.file.originalname,
      req.file.mimetype
    );

    res.status(201).json({
      success: true,
      data: { url, path, contentType: req.file.mimetype }
    });
  } catch (error) {
    next(error);
  }
};

export const generateFullCatalogue = async (req, res, next) => {
  try {
    const user = req.user;
    if (user.role !== 'ARTISAN') {
      res.status(403);
      throw new Error('Only artisans can generate catalogues');
    }

    const artisanProfile = await prisma.artisanProfile.findUnique({
      where: { userId: user.id },
    });

    if (!artisanProfile) {
      res.status(404);
      throw new Error('Artisan profile not found');
    }

    const {
      productName,
      imageUrl,
      audioUrl,
      category,
      material,
      region,
      materialCost,
      hintLanguage,
      keywords
    } = req.body;

    if (!productName || !category) {
      res.status(400);
      throw new Error('Missing required fields: productName and category');
    }

    if (!imageUrl && !audioUrl) {
      res.status(400);
      throw new Error('At least one of imageUrl or audioUrl must be provided');
    }

    // 1. Generate listingId early for correlation and persistence
    const listingId = crypto.randomUUID();

    // 2. Start independent jobs in parallel
    const startJobs = [];
    if (imageUrl) {
      startJobs.push(
        (async () => {
          const { jobId } = await mlClient.startImageEnhancement(imageUrl, listingId);
          return { type: 'image', jobId };
        })()
      );
    }
    
    if (audioUrl) {
      startJobs.push(
        (async () => {
          const { jobId } = await mlClient.startAudioTranscription(audioUrl, listingId, hintLanguage);
          return { type: 'audio', jobId };
        })()
      );
    }

    const startedJobs = await Promise.all(startJobs);

    // 3. Poll jobs in parallel
    const pollPromises = startedJobs.map(async (job) => {
      if (job.type === 'image') {
        const result = await mlClient.pollJobStatus(mlClient.getImageEnhancementStatus, job.jobId);
        return { type: 'image', result };
      } else {
        const result = await mlClient.pollJobStatus(mlClient.getAudioTranscriptionStatus, job.jobId);
        return { type: 'audio', result };
      }
    });

    const completedJobs = await Promise.all(pollPromises);

    let enhancedImageUrl = null;
    let transcript = null;
    let transcriptionData = null;

    completedJobs.forEach(job => {
      if (job.type === 'image') enhancedImageUrl = job.result.enhancedImageUrl;
      if (job.type === 'audio') {
        transcript = job.result.transcript;
        transcriptionData = job.result;
      }
    });

    // If there is no audio, we can't generate a description this way yet, but we'll try with what we have
    let descriptionEn = "";
    let descriptionHi = "";
    let seoKeywords = keywords || [];

    // 4. Translate and Describe
    if (transcript) {
      const translateRes = await mlClient.translateText(transcript, transcriptionData.detectedLanguage, ['en', 'hi']);
      
      const translatedEn = translateRes.translations['en'];
      const descRes = await mlClient.generateDescription(translatedEn, category, keywords);
      
      descriptionEn = descRes.descriptionEn;
      descriptionHi = descRes.descriptionHi;
      seoKeywords = descRes.seoKeywords;
    } else {
      // Fallback if no audio was provided
      descriptionEn = "No description provided.";
      descriptionHi = "कोई विवरण नहीं दिया गया है।";
    }

    // 5. Pricing
    const pricingRes = await mlClient.suggestPrice(
      listingId,
      category,
      enhancedImageUrl,
      descriptionEn,
      materialCost,
      region
    );

    // 6. Prisma Persistence
    const newProduct = await prisma.product.create({
      data: {
        id: listingId,
        productName: productName,
        category: category,
        material: material || null,
        description: { en: descriptionEn, hi: descriptionHi },
        tags: seoKeywords,
        imageUrl: enhancedImageUrl || imageUrl || null,
        suggestedPriceMin: pricingRes.suggestedPriceMin,
        suggestedPriceMax: pricingRes.suggestedPriceMax,
        currency: pricingRes.currency,
        pricingExplanation: pricingRes.explanation,
        status: 'DRAFT',
        artisanId: artisanProfile.id
      }
    });

    res.status(201).json({
      success: true,
      data: {
        ...newProduct,
        transcription: transcriptionData ? {
          detectedLanguage: transcriptionData.detectedLanguage,
          confidence: transcriptionData.confidence
        } : null,
        pricing: {
          suggestedPriceMin: pricingRes.suggestedPriceMin,
          suggestedPriceMax: pricingRes.suggestedPriceMax,
          currency: pricingRes.currency,
          explanation: pricingRes.explanation,
          featuresUsed: pricingRes.featuresUsed
        }
      }
    });
  } catch (error) {
    next(error);
  }
};
