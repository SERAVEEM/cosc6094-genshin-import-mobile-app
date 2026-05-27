import { v4 as uuidv4 } from 'uuid';
import pool from '../config/db.js';
import * as weaponRepository from '../repositories/weaponRepository.js';
import * as transactionRepository from '../repositories/transactionRepository.js';

export const purchaseItem = async (userId, { weapon_id, quantity }) => {
  const qty = parseInt(quantity);
  
  if (!weapon_id || isNaN(qty) || qty <= 0) {
    const error = new Error('ID produk dan kuantitas pembelian wajib valid!');
    error.statusCode = 400;
    throw error;
  }

  const conn = await pool.getConnection();

  try {
    await conn.beginTransaction();

    // 1. Fetch weapon with row lock (FOR UPDATE)
    const [weapons] = await conn.execute(
      'SELECT id, name, stock, price, deleted_at FROM weapons WHERE id = ? FOR UPDATE',
      [weapon_id]
    );

    const weapon = weapons[0];

    if (!weapon || weapon.deleted_at !== null) {
      const error = new Error('Produk tidak ditemukan atau tidak aktif!');
      error.statusCode = 404;
      throw error;
    }

    // 2. Validate stock capacity (VAL-03)
    if (qty > weapon.stock) {
      const error = new Error('Transaksi Gagal: Jumlah pembelian melebihi sisa stok yang tersedia!');
      error.statusCode = 422;
      throw error;
    }

    // 3. Deduct stock
    await weaponRepository.updateStockTransactional(conn, weapon_id, qty);

    // 4. Log transaction
    const total_price = qty * parseFloat(weapon.price);
    const transactionId = uuidv4();
    const newTransaction = {
      id: transactionId,
      user_id: userId,
      weapon_id,
      quantity: qty,
      total_price
    };

    const loggedTx = await transactionRepository.createTransactional(conn, newTransaction);

    await conn.commit();
    return {
      ...loggedTx,
      weapon_name: weapon.name,
      price_per_item: weapon.price
    };

  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
};

export const getUserHistory = async (userId) => {
  return await transactionRepository.findAllByUserId(userId);
};
