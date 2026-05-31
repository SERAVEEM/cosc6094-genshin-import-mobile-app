import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

let pool;

if (process.env.DB_HOST === 'mock' || process.env.NODE_ENV === 'test') {
  const users = [
    {
      id: 'a8be354d-eb23-49ec-8cb3-7a9192461421',
      name: 'Aimin Admin',
      email: 'admin@gachamerch.com',
      password: '$2a$10$D0LFIO59dLXz82ghvg1dkOUG6PFt1M6ZrECAkOF7mmxPIg2FnKfSO',
      oauth_id: null,
      role: 'admin',
      session_token: null
    },
    {
      id: 'b287955d-16ef-46e3-82bd-dfcdcf209b5a',
      name: 'Tabibito User',
      email: 'user@gachamerch.com',
      password: '$2a$10$D0LFIO59dLXz82ghvg1dkOUG6PFt1M6ZrECAkOF7mmxPIg2FnKfSO',
      oauth_id: null,
      role: 'user',
      session_token: null
    }
  ];

  const weapons = [
    {
      id: 'w1000001-eb23-49ec-8cb3-7a9192461421',
      name: "Wolf's Gravestone",
      type: 'Claymore',
      description: 'A longsword used by the Wolf Knight. Originally just a heavy sheet of iron, it gained legendary power through its close friendship with the wolf.',
      stock: 5,
      image: 'assets/Product/Missplitter reforged.png',
      price: 1500000.00,
      deleted_at: null,
      banner: 'assets/Product/mistsplitter Banner.png',
      showcase1: 'assets/Product/Missplitter showcase.png',
      showcase2: 'assets/Product/mistsplitter Banner.png',
      showcase3: 'assets/Product/Missplitter showcase2.png',
      ratings: '5.0',
      dmg: '250',
      crit_rate: '40%',
      crit_dmg: '150%'
    },
    {
      id: 'w1000002-eb23-49ec-8cb3-7a9192461421',
      name: 'Primordial Jade Winged-Spear',
      type: 'Polearm',
      description: 'A jade spear created by the Archons. Its light shines with the purity of primeval stone, capable of piercing dragons and sealing gods.',
      stock: 3,
      image: 'assets/Product/Susano\'o sword.png',
      price: 1400000.00,
      deleted_at: null,
      banner: 'assets/Product/mistsplitter Banner.png',
      showcase1: 'assets/Product/Missplitter showcase.png',
      showcase2: 'assets/Product/mistsplitter Banner.png',
      showcase3: 'assets/Product/Missplitter showcase2.png',
      ratings: '4.8',
      dmg: '224',
      crit_rate: '35%',
      crit_dmg: '130%'
    },
    {
      id: 'w1000003-eb23-49ec-8cb3-7a9192461421',
      name: "Gladiator's Nostalgia",
      type: 'Artifact-Flower',
      description: 'A flower badge worn by the ancient gladiators. Symbolizes the dreams and nostalgia of the fighters who fought in the colosseum.',
      stock: 10,
      image: 'assets/Product/Sword of destiny.png',
      price: 500000.00,
      deleted_at: null,
      banner: 'assets/Product/mistsplitter Banner.png',
      showcase1: 'assets/Product/Missplitter showcase.png',
      showcase2: 'assets/Product/mistsplitter Banner.png',
      showcase3: 'assets/Product/Missplitter showcase2.png',
      ratings: '4.9',
      dmg: '0',
      crit_rate: '15%',
      crit_dmg: '80%'
    }
  ];

  const transactions = [];

  const executeMockQuery = (sql, params = []) => {
    const normSql = sql.replace(/\s+/g, ' ').trim();
    
    // 1. SELECT from users WHERE email = ?
    if (normSql.includes('FROM users WHERE email = ?')) {
      const user = users.find(u => u.email === params[0]);
      return [user ? [{ ...user }] : []];
    }
    
    // 2. SELECT from users WHERE session_token = ?
    if (normSql.includes('FROM users WHERE session_token = ?')) {
      const user = users.find(u => u.session_token === params[0]);
      return [user ? [{ ...user }] : []];
    }
    
    // 3. SELECT from users WHERE oauth_id = ?
    if (normSql.includes('FROM users WHERE oauth_id = ?')) {
      const user = users.find(u => u.oauth_id === params[0]);
      return [user ? [{ ...user }] : []];
    }
    
    // 4. INSERT INTO users
    if (normSql.includes('INSERT INTO users')) {
      const [id, name, email, password, oauth_id, role] = params;
      const newUser = { id, name, email, password, oauth_id, role: role || 'user', session_token: null };
      users.push(newUser);
      return [[], { affectedRows: 1 }];
    }
    
    // 5. UPDATE users SET session_token = ? WHERE id = ?
    if (normSql.includes('UPDATE users SET session_token = ? WHERE id = ?')) {
      const [token, id] = params;
      const user = users.find(u => u.id === id);
      if (user) {
        user.session_token = token;
      }
      return [[], { affectedRows: 1 }];
    }
    
    // 6. SELECT active weapons
    if (normSql.includes('FROM weapons') && normSql.includes('deleted_at IS NULL')) {
      const active = weapons.filter(w => w.deleted_at === null);
      return [active.map(w => ({ ...w }))];
    }
    
    // 7. SELECT weapon by id (active or deleted, including FOR UPDATE)
    if (normSql.includes('FROM weapons') && (normSql.includes('id = ?') || normSql.includes('weapon_id = ?'))) {
      const weapon = weapons.find(w => w.id === params[0]);
      return [weapon ? [{ ...weapon }] : []];
    }
    
    // 8. INSERT INTO weapons
    if (normSql.includes('INSERT INTO weapons')) {
      const [id, name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3] = params;
      const newWeapon = {
        id, name, type, description, stock, image, price,
        banner: banner || 'default_banner.png',
        showcase1: showcase1 || 'default_showcase1.png',
        showcase2: showcase2 || 'default_showcase2.png',
        showcase3: showcase3 || 'default_showcase3.png',
        deleted_at: null,
        ratings: '5.0',
        dmg: '0',
        crit_rate: '0%',
        crit_dmg: '0%'
      };
      weapons.push(newWeapon);
      return [[], { affectedRows: 1 }];
    }

    // 8.5 INSERT INTO weapon_stats
    if (normSql.includes('INSERT INTO weapon_stats')) {
      const [weapon_id, ratings, dmg, crit_rate, crit_dmg] = params;
      const weapon = weapons.find(w => w.id === weapon_id);
      if (weapon) {
        weapon.ratings = ratings;
        weapon.dmg = dmg;
        weapon.crit_rate = crit_rate;
        weapon.crit_dmg = crit_dmg;
      }
      return [[], { affectedRows: 1 }];
    }
    
    // 9. UPDATE weapons
    if (normSql.includes('UPDATE weapons SET name = ?')) {
      const [name, type, description, stock, image, price, banner, showcase1, showcase2, showcase3, id] = params;
      const weapon = weapons.find(w => w.id === id);
      if (weapon) {
        weapon.name = name;
        weapon.type = type;
        weapon.description = description;
        weapon.stock = stock;
        weapon.image = image;
        weapon.price = price;
        weapon.banner = banner;
        weapon.showcase1 = showcase1;
        weapon.showcase2 = showcase2;
        weapon.showcase3 = showcase3;
      }
      return [[], { affectedRows: 1 }];
    }

    // 9.5 UPDATE weapon_stats
    if (normSql.includes('UPDATE weapon_stats SET')) {
      const [ratings, dmg, crit_rate, crit_dmg, weapon_id] = params;
      const weapon = weapons.find(w => w.id === weapon_id);
      if (weapon) {
        weapon.ratings = ratings;
        weapon.dmg = dmg;
        weapon.crit_rate = crit_rate;
        weapon.crit_dmg = crit_dmg;
      }
      return [[], { affectedRows: 1 }];
    }
    
    // 10. UPDATE weapons SET deleted_at = NOW()
    if (normSql.includes('UPDATE weapons SET deleted_at = NOW()')) {
      const weapon = weapons.find(w => w.id === params[0]);
      if (weapon) {
        weapon.deleted_at = new Date().toISOString();
      }
      return [[], { affectedRows: 1 }];
    }
    
    // 11. UPDATE weapons SET stock = stock - ?
    if (normSql.includes('UPDATE weapons SET stock = stock - ?')) {
      const [qty, id] = params;
      const weapon = weapons.find(w => w.id === id);
      if (weapon) {
        weapon.stock -= qty;
      }
      return [[], { affectedRows: 1 }];
    }
    
    // 12. INSERT INTO transactions
    if (normSql.includes('INSERT INTO transactions')) {
      const [id, user_id, weapon_id, quantity, total_price, redeem_code] = params;
      const newTx = {
        id,
        user_id,
        weapon_id,
        quantity,
        total_price,
        redeem_code: redeem_code || null,
        created_at: new Date().toISOString()
      };
      transactions.push(newTx);
      return [[], { affectedRows: 1 }];
    }
    
    // 13. SELECT from transactions
    if (normSql.includes('FROM transactions')) {
      const userId = params[0];
      const userTxs = transactions.filter(t => t.user_id === userId);
      const joined = userTxs.map(t => {
        const weapon = weapons.find(w => w.id === t.weapon_id);
        return {
          ...t,
          weapon_name: weapon ? weapon.name : null,
          weapon_type: weapon ? weapon.type : null,
          weapon_image: weapon ? weapon.image : null
        };
      });
      return [joined];
    }
    
    console.log('WARNING: Unmatched mock query:', sql, params);
    return [[], { affectedRows: 0 }];
  };

  class MockConnection {
    async execute(sql, params) {
      return executeMockQuery(sql, params);
    }
    async beginTransaction() {}
    async commit() {}
    async rollback() {}
    release() {}
  }

  pool = {
    async execute(sql, params) {
      return executeMockQuery(sql, params);
    },
    async getConnection() {
      return new MockConnection();
    }
  };
} else {
  pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'genshin_import',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  });
}

export default pool;
