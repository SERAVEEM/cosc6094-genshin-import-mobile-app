import pool from '../config/db.js';

export const createTransactional = async (conn, { id, user_id, weapon_id, quantity, total_price, redeem_code }) => {
  await conn.execute(
    'INSERT INTO transactions (id, user_id, weapon_id, quantity, total_price, redeem_code) VALUES (?, ?, ?, ?, ?, ?)',
    [id, user_id, weapon_id, quantity, total_price, redeem_code]
  );
  return { id, user_id, weapon_id, quantity, total_price, redeem_code };
};

export const findAllByUserId = async (userId) => {
  const [rows] = await pool.execute(
    `SELECT t.id, t.user_id, t.weapon_id, t.quantity, t.total_price, t.redeem_code, t.created_at, 
            w.name as weapon_name, w.type as weapon_type, w.image as weapon_image 
     FROM transactions t
     JOIN weapons w ON t.weapon_id = w.id
     WHERE t.user_id = ?
     ORDER BY t.created_at DESC`,
    [userId]
  );
  return rows;
};
