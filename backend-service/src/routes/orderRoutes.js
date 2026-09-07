import express from 'express';
import { protect } from '../middleware/auth.js';
import {
  createOrder,
  getOrder,
  acceptOrder,
  partialAcceptOrder,
  rejectOrder,
  markFulfilling,
  markCompleted
} from '../controllers/orderController.js';

const router = express.Router();

router.use(protect);

router.post('/', createOrder);
router.get('/:id', getOrder);
router.patch('/:id/accept', acceptOrder);
router.patch('/:id/partial', partialAcceptOrder);
router.patch('/:id/reject', rejectOrder);
router.patch('/:id/fulfilling', markFulfilling);
router.patch('/:id/complete', markCompleted);

export default router;
