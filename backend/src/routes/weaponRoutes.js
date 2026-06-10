import express from 'express';
import * as weaponController from '../controllers/weaponController.js';
import * as commentController from '../controllers/commentController.js';
import { authMiddleware, roleMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/', weaponController.getCatalog);
router.get('/:id/comments', commentController.getWeaponComments);
router.get('/:id', authMiddleware, weaponController.getWeaponById);

router.post('/:id/comments', authMiddleware, commentController.createWeaponComment);
router.post('/', authMiddleware, roleMiddleware(['admin']), weaponController.createWeapon);
router.put('/:id', authMiddleware, roleMiddleware(['admin']), weaponController.updateWeapon);
router.delete('/:id', authMiddleware, roleMiddleware(['admin']), weaponController.deleteWeapon);

export default router;
