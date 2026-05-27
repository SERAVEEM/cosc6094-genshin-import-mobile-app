import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import * as userRepository from '../repositories/userRepository.js';
import pool from '../config/db.js'; // Fallback for direct update if needed

const generateToken = () => {
  return crypto.randomBytes(10).toString('hex'); // Generates a 20-character alphanumeric string
};

export const register = async ({ name, email, password }) => {
  if (!email || !email.includes('@') || !password || password.length < 6) {
    const error = new Error('Format email tidak valid atau password terlalu pendek!');
    error.statusCode = 422;
    throw error;
  }

  const existingUser = await userRepository.findByEmail(email);
  if (existingUser) {
    const error = new Error('Email sudah terdaftar!');
    error.statusCode = 400;
    throw error;
  }

  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  const newUser = {
    id: uuidv4(),
    name,
    email,
    password: hashedPassword,
    oauth_id: null,
    role: 'user'
  };

  return await userRepository.create(newUser);
};

export const login = async ({ email, password }) => {
  if (!email || !password) {
    const error = new Error('Email dan password tidak boleh kosong!');
    error.statusCode = 400;
    throw error;
  }

  const user = await userRepository.findByEmail(email);
  if (!user || !user.password) {
    const error = new Error('Kredensial tidak valid!');
    error.statusCode = 401;
    throw error;
  }

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    const error = new Error('Kredensial tidak valid!');
    error.statusCode = 401;
    throw error;
  }

  const token = generateToken();
  await userRepository.updateSessionToken(user.id, token);

  return {
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role
    }
  };
};

export const handleOauth = async ({ email, name, oauth_id }) => {
  if (!oauth_id || !email) {
    const error = new Error('OAuth ID dan email tidak boleh kosong!');
    error.statusCode = 400;
    throw error;
  }

  let user = await userRepository.findByOauthId(oauth_id);

  if (!user) {
    user = await userRepository.findByEmail(email);
    if (user) {
      // Link OAuth ID to existing email account
      await pool.execute(
        'UPDATE users SET oauth_id = ? WHERE id = ?',
        [oauth_id, user.id]
      );
      // Reload user
      user = await userRepository.findByEmail(email);
    }
  }

  if (!user) {
    const newUserId = uuidv4();
    await userRepository.create({
      id: newUserId,
      name,
      email,
      password: null,
      oauth_id,
      role: 'user'
    });
    user = await userRepository.findByEmail(email);
  }

  const token = generateToken();
  await userRepository.updateSessionToken(user.id, token);

  return {
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role
    }
  };
};

export const logout = async (userId) => {
  await userRepository.updateSessionToken(userId, null);
};
