import { v4 as uuidv4 } from 'uuid';
import * as weaponRepository from '../repositories/weaponRepository.js';

const validateWeapon = ({ name, price, stock }) => {
  if (!name || price === undefined || stock === undefined) {
    const error = new Error('Data produk tidak valid! Pastikan harga dan stok berupa angka positif.');
    error.statusCode = 422;
    throw error;
  }
  
  const parsedPrice = parseFloat(price);
  const parsedStock = parseInt(stock);

  if (isNaN(parsedPrice) || parsedPrice <= 0 || isNaN(parsedStock) || parsedStock <= 0) {
    const error = new Error('Data produk tidak valid! Pastikan harga dan stok berupa angka positif.');
    error.statusCode = 422;
    throw error;
  }
};

export const getCatalog = async () => {
  return await weaponRepository.findAllActive();
};

export const getWeaponById = async (id) => {
  const weapon = await weaponRepository.findById(id);
  if (!weapon || weapon.deleted_at !== null) {
    const error = new Error('Produk tidak ditemukan!');
    error.statusCode = 404;
    throw error;
  }
  return weapon;
};

export const createWeapon = async (weaponData) => {
  validateWeapon(weaponData);
  
  const newWeapon = {
    id: uuidv4(),
    name: weaponData.name,
    type: weaponData.type || 'Sword',
    description: weaponData.description || '',
    stock: parseInt(weaponData.stock),
    image: weaponData.image || 'default_weapon.png',
    price: parseFloat(weaponData.price)
  };

  return await weaponRepository.create(newWeapon);
};

export const updateWeapon = async (id, weaponData) => {
  validateWeapon(weaponData);

  const existing = await weaponRepository.findById(id);
  if (!existing || existing.deleted_at !== null) {
    const error = new Error('Produk tidak ditemukan!');
    error.statusCode = 404;
    throw error;
  }

  const updatedWeapon = {
    name: weaponData.name,
    type: weaponData.type || existing.type,
    description: weaponData.description || existing.description,
    stock: parseInt(weaponData.stock),
    image: weaponData.image || existing.image,
    price: parseFloat(weaponData.price)
  };

  return await weaponRepository.update(id, updatedWeapon);
};

export const deleteWeapon = async (id) => {
  const existing = await weaponRepository.findById(id);
  if (!existing || existing.deleted_at !== null) {
    const error = new Error('Produk tidak ditemukan!');
    error.statusCode = 404;
    throw error;
  }
  await weaponRepository.softDelete(id);
};
