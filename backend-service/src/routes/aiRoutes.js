import express from 'express';
import multer from 'multer';
import { generateCatalogue, transcribeAudio, generateCatalogueFromAudio, getMlHealth, testMlImage, testMlAudio, generateFullCatalogue, uploadMediaImage, uploadMediaAudio } from '../controllers/aiController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 25 * 1024 * 1024 }, // 25 MB
  fileFilter: (req, file, cb) => {
    const ext = file.originalname.split('.').pop().toLowerCase();
    const allowedExts = ['m4a', 'mp3', 'wav', 'webm', 'ogg', 'mp4', 'mpeg', 'mpga', 'flac'];
    
    if (allowedExts.includes(ext)) {
      cb(null, true);
    } else {
      const err = new Error('Unsupported audio format');
      err.status = 400;
      cb(err, false);
    }
  }
});

const uploadMiddleware = (req, res, next) => {
  upload.single('audio')(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        res.status(413);
        return next(new Error('Audio file exceeds 25 MB'));
      }
      return next(err);
    }
    next();
  });
};

// New memory storage for Firebase uploads
const memoryUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 25 * 1024 * 1024 } // 25 MB max (we'll limit image to 10MB in filter)
});

const imageUploadMiddleware = (req, res, next) => {
  memoryUpload.single('file')(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        res.status(413);
        return next(new Error('Image file exceeds size limit'));
      }
      return next(err);
    }
    const file = req.file;
    if (!file) {
      res.status(400);
      return next(new Error('Missing image file'));
    }
    const ext = file.originalname.split('.').pop().toLowerCase();
    const allowed = ['jpeg', 'jpg', 'png', 'webp'];
    if (!allowed.includes(ext) || !file.mimetype.startsWith('image/')) {
      res.status(400);
      return next(new Error('Unsupported image format'));
    }
    if (file.size > 10 * 1024 * 1024) {
      res.status(413);
      return next(new Error('Image file exceeds 10 MB'));
    }
    next();
  });
};

const audioUploadMiddleware = (req, res, next) => {
  memoryUpload.single('file')(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        res.status(413);
        return next(new Error('Audio file exceeds 25 MB'));
      }
      return next(err);
    }
    const file = req.file;
    if (!file) {
      res.status(400);
      return next(new Error('Missing audio file'));
    }
    const ext = file.originalname.split('.').pop().toLowerCase();
    const allowed = ['m4a', 'mp3', 'wav', 'webm', 'ogg', 'mp4', 'mpeg', 'mpga', 'flac'];
    if (!allowed.includes(ext) || (!file.mimetype.startsWith('audio/') && !file.mimetype.startsWith('video/mp4'))) {
      res.status(400);
      return next(new Error('Unsupported audio format'));
    }
    next();
  });
};



router.post('/catalogue/generate', protect, generateCatalogue);
router.post('/speech-to-text', protect, uploadMiddleware, transcribeAudio);
router.post('/catalogue/generate-from-audio', protect, uploadMiddleware, generateCatalogueFromAudio);

// Temporary test endpoints for ML Integration Foundation
router.get('/ml-health', getMlHealth);
router.post('/ml-image-test', testMlImage);
router.post('/ml-audio-test', testMlAudio);

// New Firebase Storage Upload Endpoints
router.post('/media/image', protect, imageUploadMiddleware, uploadMediaImage);
router.post('/media/audio', protect, audioUploadMiddleware, uploadMediaAudio);

// New ML Orchestration endpoint
router.post('/catalogue/ml-generate', protect, generateFullCatalogue);

export default router;
