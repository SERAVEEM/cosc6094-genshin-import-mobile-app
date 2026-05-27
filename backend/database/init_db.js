import mysql from 'mysql2/promise';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function init() {
  console.log('[DB] Connecting to MySQL server to initialize database...');
  
  // Connection without database name since schema.sql creates it
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
  });

  try {
    const sqlPath = path.join(__dirname, 'schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    console.log('[DB] Executing SQL script...');
    await connection.query(sql);
    
    console.log('[DB] Database "genshin_import" initialized successfully with seed data!');
  } catch (error) {
    console.error('[DB] Error initializing database:', error);
  } finally {
    await connection.end();
  }
}

init();
