import express from 'express';
import { getMyProducts, createProduct, getProduct, updateProduct, deleteProduct, publishProduct, unpublishProduct } from '../controllers/productController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.post('/', createProduct);
router.get('/my', getMyProducts);
router.get('/:id', getProduct);
router.put('/:id', updateProduct);
router.delete('/:id', deleteProduct);
router.patch('/:id/publish', publishProduct);
router.patch('/:id/unpublish', unpublishProduct);

export default router;
