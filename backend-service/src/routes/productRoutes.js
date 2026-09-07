import express from 'express';
import { getMyProducts, getPublicProducts, createProduct, getProduct, updateProduct, deleteProduct, publishProduct, unpublishProduct } from '../controllers/productController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.get('/', getPublicProducts);        // Any authenticated user — buyer or artisan
router.post('/', createProduct);           // Artisan only (enforced in controller)
router.get('/my', getMyProducts);          // Artisan only (enforced in controller)
router.get('/:id', getProduct);            // Buyer: PUBLISHED + artisan summary; Artisan: own products
router.put('/:id', updateProduct);
router.delete('/:id', deleteProduct);
router.patch('/:id/publish', publishProduct);
router.patch('/:id/unpublish', unpublishProduct);

export default router;

