import { generateStructuredCatalogue } from '../services/llmService.js';
import { transcribeAudioFile } from '../services/speechToTextService.js';
import fs from 'fs';

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
