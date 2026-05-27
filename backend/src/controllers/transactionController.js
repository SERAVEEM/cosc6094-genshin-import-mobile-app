import * as transactionService from '../services/transactionService.js';

export const purchaseItem = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { weapon_id, quantity } = req.body;
    
    const transaction = await transactionService.purchaseItem(userId, { weapon_id, quantity });
    res.status(201).json({
      message: 'Transaksi pembelian berhasil diselesaikan!',
      data: transaction
    });
  } catch (error) {
    next(error);
  }
};

export const getUserHistory = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const history = await transactionService.getUserHistory(userId);
    res.status(200).json({
      message: 'Riwayat transaksi berhasil dimuat!',
      data: history
    });
  } catch (error) {
    next(error);
  }
};
