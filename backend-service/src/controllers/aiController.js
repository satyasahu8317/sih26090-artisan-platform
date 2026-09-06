import { generateStructuredCatalogue } from '../services/llmService.js';
import { transcribeAudioFile } from '../services/speechToTextService.js';
import fs from 'fs';
import * as mlClient from '../services/mlClient.js';

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
