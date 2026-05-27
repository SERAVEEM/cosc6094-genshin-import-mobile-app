import pool from '../config/db.js';

export const findByEmail = async (email) => {
  const [rows] = await pool.execute(
    'SELECT * FROM users WHERE email = ?',
    [email]
  );
  return rows[0] || null;
};

export const findByToken = async (token) => {
  const [rows] = await pool.execute(
    'SELECT * FROM users WHERE session_token = ?',
    [token]
  );
  return rows[0] || null;
};

export const findByOauthId = async (oauthId) => {
  const [rows] = await pool.execute(
    'SELECT * FROM users WHERE oauth_id = ?',
    [oauthId]
  );
  return rows[0] || null;
};

export const create = async ({ id, name, email, password, oauth_id, role }) => {
  await pool.execute(
    'INSERT INTO users (id, name, email, password, oauth_id, role) VALUES (?, ?, ?, ?, ?, ?)',
    [id, name, email, password || null, oauth_id || null, role || 'user']
  );
  return { id, name, email, role };
};

export const updateSessionToken = async (userId, token) => {
  await pool.execute(
    'UPDATE users SET session_token = ? WHERE id = ?',
    [token, userId]
  );
};
