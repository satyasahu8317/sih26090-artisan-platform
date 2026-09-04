import express from 'express';
import { protect } from '../middleware/auth.js';
import { createEnquiry, getEnquiry, updateEnquiryStatus, getEnquiryMessages, addEnquiryMessage } from '../controllers/enquiryController.js';

const router = express.Router();

router.use(protect);

router.post('/', createEnquiry);
router.get('/:id', getEnquiry);
router.patch('/:id', updateEnquiryStatus);

router.get('/:id/messages', getEnquiryMessages);
router.post('/:id/messages', addEnquiryMessage);

export default router;
