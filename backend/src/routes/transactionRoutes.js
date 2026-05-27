import express from 'express';
import * as transactionController from '../controllers/transactionController.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(authMiddleware);

router.post('/', transactionController.purchaseItem);
router.get('/history', transactionController.getUserHistory);

export default router;
