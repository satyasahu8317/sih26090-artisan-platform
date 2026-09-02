import express from 'express';
import multer from 'multer';
import { generateCatalogue, transcribeAudio, generateCatalogueFromAudio } from '../controllers/aiController.js';
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

router.post('/catalogue/generate', protect, generateCatalogue);
router.post('/speech-to-text', protect, uploadMiddleware, transcribeAudio);
router.post('/catalogue/generate-from-audio', protect, uploadMiddleware, generateCatalogueFromAudio);

export default router;
