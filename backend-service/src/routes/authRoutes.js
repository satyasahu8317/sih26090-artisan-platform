import express from 'express';
import rateLimit from 'express-rate-limit';
import { requestOtp, verifyOtp, verifyMsg91, register, getMe } from '../controllers/authController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, 
  max: 5, 
  message: 'Too many OTP requests from this IP, please try again after 10 minutes',
});

router.post('/mobile', otpLimiter, requestOtp);
router.post('/verify-otp', verifyOtp);
router.post('/msg91/verify', verifyMsg91);
router.post('/register/:role', protect, register);
router.get('/me', protect, getMe);

export default router;
