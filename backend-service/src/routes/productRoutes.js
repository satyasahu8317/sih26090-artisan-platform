import express from 'express';
import { getMyProducts, createProduct } from '../controllers/productController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.post('/', createProduct);
router.get('/my', getMyProducts);

export default router;
