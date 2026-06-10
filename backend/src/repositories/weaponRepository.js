import pool from '../config/db.js';

export const findAllActive = async () => {
  const [rows] = await pool.execute(
    `SELECT w.id, w.name, w.type, w.description, w.stock, w.image, w.price, 
            w.banner, w.showcase1, w.showcase2, w.showcase3,
            s.ratings, s.dmg, s.crit_rate, s.crit_dmg
     FROM weapons w
     LEFT JOIN weapon_stats s ON w.id = s.weapon_id
     WHERE w.deleted_at IS NULL`
  );
  return rows;
};

export const findById = async (id, conn = pool) => {
  const [rows] = await conn.execute(
    `SELECT w.id, w.name, w.type, w.description, w.stock, w.image, w.price, 
            w.banner, w.showcase1, w.showcase2, w.showcase3, w.deleted_at,
            s.ratings, s.dmg, s.crit_rate, s.crit_dmg
     FROM weapons w
     LEFT JOIN weapon_stats s ON w.id = s.weapon_id
     WHERE w.id = ?`,
    [id]
  );
  return rows[0] || null;
};

export const create = async ({ id, name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3, ratings, dmg, crit_rate, crit_dmg }) => {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    
    await conn.execute(
      'INSERT INTO weapons (id, name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [id, name, type, description, stock, image, price, banner || 'default_banner.png', showcase1 || 'default_showcase1.png', showcase2 || 'default_showcase2.png', showcase3 || 'default_showcase3.png']
    );

    await conn.execute(
      'INSERT INTO weapon_stats (weapon_id, ratings, dmg, crit_rate, crit_dmg) VALUES (?, ?, ?, ?, ?)',
      [id, ratings || '5.0', dmg || '0', crit_rate || '0%', crit_dmg || '0%']
    );

    await conn.commit();
    return { id, name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3, ratings, dmg, crit_rate, crit_dmg };
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
};

export const update = async (id, { name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3, ratings, dmg, crit_rate, crit_dmg }) => {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    await conn.execute(
      'UPDATE weapons SET name = ?, type = ?, description = ?, stock = ?, image = ?, price = ?, banner = ?, showcase1 = ?, showcase2 = ?, showcase3 = ? WHERE id = ?',
      [name, type, description, stock, image, price, banner || 'default_banner.png', showcase1 || 'default_showcase1.png', showcase2 || 'default_showcase2.png', showcase3 || 'default_showcase3.png', id]
    );

    await conn.execute(
      `INSERT INTO weapon_stats (weapon_id, ratings, dmg, crit_rate, crit_dmg) 
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE ratings = VALUES(ratings), dmg = VALUES(dmg), crit_rate = VALUES(crit_rate), crit_dmg = VALUES(crit_dmg)`,
      [id, ratings || '5.0', dmg || '0', crit_rate || '0%', crit_dmg || '0%']
    );

    await conn.commit();
    return { id, name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3, ratings, dmg, crit_rate, crit_dmg };
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
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

export const updateRating = async (id, rating) => {
  await pool.execute(
    `INSERT INTO weapon_stats (weapon_id, ratings)
     VALUES (?, ?)
     ON DUPLICATE KEY UPDATE ratings = VALUES(ratings)`,
    [id, rating]
  );
};
