import { v4 as uuidv4 } from 'uuid';
import * as commentRepository from '../repositories/commentRepository.js';
import * as weaponRepository from '../repositories/weaponRepository.js';

const validateComment = ({ rating, content }) => {
  const parsedRating = Number(rating);
  const normalizedContent = String(content || '').trim();

  if (!Number.isInteger(parsedRating) || parsedRating < 1 || parsedRating > 5) {
    const error = new Error('Rating harus berupa angka dari 1 sampai 5.');
    error.statusCode = 422;
    throw error;
  }

  if (normalizedContent.length < 3 || normalizedContent.length > 500) {
    const error = new Error('Komentar harus berisi 3 sampai 500 karakter.');
    error.statusCode = 422;
    throw error;
  }

  return {
    rating: parsedRating,
    content: normalizedContent
  };
};

const ensureWeaponExists = async (weaponId) => {
  const weapon = await weaponRepository.findById(weaponId);
  if (!weapon || weapon.deleted_at !== null) {
    const error = new Error('Produk tidak ditemukan!');
    error.statusCode = 404;
    throw error;
  }
};

export const getCommentsByWeaponId = async (weaponId) => {
  await ensureWeaponExists(weaponId);
  return await commentRepository.findByWeaponId(weaponId);
};

export const createComment = async (weaponId, userId, commentData) => {
  await ensureWeaponExists(weaponId);
  const validComment = validateComment(commentData);

  const comment = await commentRepository.create({
    id: uuidv4(),
    weaponId,
    userId,
    rating: validComment.rating,
    content: validComment.content
  });

  const stats = await commentRepository.getStatsByWeaponId(weaponId);
  const averageRating = Number(stats.average_rating || 5).toFixed(1);
  await weaponRepository.updateRating(weaponId, averageRating);

  return comment;
};
