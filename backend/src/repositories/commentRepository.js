import pool from '../config/db.js';

export const findByWeaponId = async (weaponId) => {
  const [rows] = await pool.execute(
    `SELECT c.id, c.weapon_id, c.user_id, u.name AS user_name, c.rating, c.content, c.created_at
     FROM comments c
     JOIN users u ON c.user_id = u.id
     WHERE c.weapon_id = ?
     ORDER BY c.created_at DESC`,
    [weaponId]
  );
  return rows;
};

export const create = async ({ id, weaponId, userId, rating, content }) => {
  await pool.execute(
    'INSERT INTO comments (id, weapon_id, user_id, rating, content) VALUES (?, ?, ?, ?, ?)',
    [id, weaponId, userId, rating, content]
  );

  const [rows] = await pool.execute(
    `SELECT c.id, c.weapon_id, c.user_id, u.name AS user_name, c.rating, c.content, c.created_at
     FROM comments c
     JOIN users u ON c.user_id = u.id
     WHERE c.id = ?`,
    [id]
  );

  return rows[0];
};

export const getStatsByWeaponId = async (weaponId) => {
  const [rows] = await pool.execute(
    'SELECT COUNT(*) AS total_comments, AVG(rating) AS average_rating FROM comments WHERE weapon_id = ?',
    [weaponId]
  );
  return rows[0];
};
