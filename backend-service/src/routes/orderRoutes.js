import express from 'express';
import { protect } from '../middleware/auth.js';
import {
  createOrder,
  getOrder,
  getMyOrders,
  acceptOrder,
  partialAcceptOrder,
  rejectOrder,
  markFulfilling,
  markCompleted
} from '../controllers/orderController.js';
import { createPayment, verifyPayment } from '../controllers/paymentController.js';

const router = express.Router();

router.use(protect);

router.post('/', createOrder);
router.get('/my', getMyOrders);   // Must be before /:id to avoid matching 'my' as an id
router.get('/:id', getOrder);
router.patch('/:id/accept', acceptOrder);
router.patch('/:id/partial', partialAcceptOrder);
router.patch('/:id/reject', rejectOrder);
router.patch('/:id/fulfilling', markFulfilling);
router.patch('/:id/complete', markCompleted);

router.post('/:id/payment', createPayment);
router.post('/:id/payment/verify', verifyPayment);

export default router;
