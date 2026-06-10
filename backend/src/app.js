import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes.js';
import weaponRoutes from './routes/weaponRoutes.js';
import transactionRoutes from './routes/transactionRoutes.js';
import { errorMiddleware } from './middleware/errorMiddleware.js';
import pool from './config/db.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/weapons', weaponRoutes);
app.use('/api/transactions', transactionRoutes);

app.get('/', (req, res) => {
  res.json({
    status: 'healthy',
    message: 'Genshin Import API is online!'
  });
});

app.get('/api/health/db', async (req, res, next) => {
  try {
    await pool.execute('SELECT 1');
    res.json({
      status: 'healthy',
      database: process.env.DB_NAME || 'genshin_import'
    });
  } catch (error) {
    next(error);
  }
});

app.use(errorMiddleware);

app.listen(PORT, () => {
  console.log(`[Server] Genshin Import API is running on http://localhost:${PORT}`);
});

export default app;
