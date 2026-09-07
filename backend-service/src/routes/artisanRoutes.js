import express from 'express';
import { getArtisanDashboard, getArtisanProfile, getArtisanOrders, getArtisanEnquiries } from '../controllers/artisanController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Apply auth middleware to all routes in this file
router.use(protect);

router.get('/me/dashboard', getArtisanDashboard);
router.get('/me', getArtisanProfile);
router.get('/orders', getArtisanOrders);
router.get('/enquiries', getArtisanEnquiries);

export default router;
