import express from 'express';
import { getArtisanDashboard, getArtisanProfile, getArtisanOrders, getArtisanEnquiries, getPublicArtisanProfile } from '../controllers/artisanController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Protected artisan-only routes — defined BEFORE /:id so they match first
router.use(protect);
router.get('/me/dashboard', getArtisanDashboard);
router.get('/me', getArtisanProfile);
router.get('/orders', getArtisanOrders);
router.get('/enquiries', getArtisanEnquiries);

// Public artisan profile — must be defined AFTER named routes
// Any authenticated user (buyer or artisan) can look up an artisan by profile ID
router.get('/:id', getPublicArtisanProfile);

export default router;

