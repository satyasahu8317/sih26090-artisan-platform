import express from 'express';
import { protect } from '../middleware/auth.js';
import { createEnquiry, getEnquiry, updateEnquiryStatus, getEnquiryMessages, addEnquiryMessage, getMyEnquiries } from '../controllers/enquiryController.js';

const router = express.Router();

router.use(protect);

router.post('/', createEnquiry);
router.get('/my', getMyEnquiries);   // Must be before /:id to avoid matching 'my' as an id
router.get('/:id', getEnquiry);
router.patch('/:id', updateEnquiryStatus);

router.get('/:id/messages', getEnquiryMessages);
router.post('/:id/messages', addEnquiryMessage);

export default router;

