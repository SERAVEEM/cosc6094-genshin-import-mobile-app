import pool from '../config/db.js';

export const findAllActive = async () => {
  const [rows] = await pool.execute(
    'SELECT id, name, type, description, stock, image, price FROM weapons WHERE deleted_at IS NULL'
  );
  return rows;
};

export const findById = async (id, conn = pool) => {
  const [rows] = await conn.execute(
    'SELECT id, name, type, description, stock, image, price, deleted_at FROM weapons WHERE id = ?',
    [id]
  );
  return rows[0] || null;
};

export const create = async ({ id, name, type, description, stock, image, price }) => {
  await pool.execute(
    'INSERT INTO weapons (id, name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [id, name, type, description, stock, image, price]
  );
  return { id, name, type, description, stock, image, price };
};

export const update = async (id, { name, type, description, stock, image, price }) => {
  await pool.execute(
    'UPDATE weapons SET name = ?, type = ?, description = ?, stock = ?, image = ?, price = ? WHERE id = ?',
    [name, type, description, stock, image, price, id]
  );
  return { id, name, type, description, stock, image, price };
};

export const softDelete = async (id) => {
  await pool.execute(
    'UPDATE weapons SET deleted_at = NOW() WHERE id = ?',
    [id]
  );
};

export const updateStockTransactional = async (conn, id, quantityDeduction) => {
  await conn.execute(
    'UPDATE weapons SET stock = stock - ? WHERE id = ?',
    [quantityDeduction, id]
  );
};
