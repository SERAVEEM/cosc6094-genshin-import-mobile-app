import * as commentService from '../services/commentService.js';

export const getWeaponComments = async (req, res, next) => {
  try {
    const comments = await commentService.getCommentsByWeaponId(req.params.id);
    res.status(200).json({
      message: 'Komentar produk berhasil dimuat!',
      data: comments
    });
  } catch (error) {
    next(error);
  }
};

export const createWeaponComment = async (req, res, next) => {
  try {
    const comment = await commentService.createComment(req.params.id, req.user.id, req.body);
    res.status(201).json({
      message: 'Komentar berhasil ditambahkan!',
      data: comment
    });
  } catch (error) {
    next(error);
  }
};
