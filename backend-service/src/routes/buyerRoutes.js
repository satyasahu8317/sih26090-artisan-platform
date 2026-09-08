import express from 'express';
import { protect } from '../middleware/auth.js';
import { updateBuyerProfile } from '../controllers/buyerController.js';

const router = express.Router();

router.use(protect);

router.patch('/me', updateBuyerProfile);

export default router;
