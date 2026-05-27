import * as weaponService from '../services/weaponService.js';

export const getCatalog = async (req, res, next) => {
  try {
    const weapons = await weaponService.getCatalog();
    res.status(200).json({
      message: 'Katalog berhasil dimuat!',
      data: weapons
    });
  } catch (error) {
    next(error);
  }
};

export const getWeaponById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const weapon = await weaponService.getWeaponById(id);
    res.status(200).json({
      message: 'Detail produk berhasil dimuat!',
      data: weapon
    });
  } catch (error) {
    next(error);
  }
};

export const createWeapon = async (req, res, next) => {
  try {
    const weaponData = req.body;
    const newWeapon = await weaponService.createWeapon(weaponData);
    res.status(201).json({
      message: 'Produk berhasil ditambahkan ke katalog!',
      data: newWeapon
    });
  } catch (error) {
    next(error);
  }
};

export const updateWeapon = async (req, res, next) => {
  try {
    const { id } = req.params;
    const weaponData = req.body;
    const updatedWeapon = await weaponService.updateWeapon(id, weaponData);
    res.status(200).json({
      message: 'Produk berhasil diperbarui!',
      data: updatedWeapon
    });
  } catch (error) {
    next(error);
  }
};

export const deleteWeapon = async (req, res, next) => {
  try {
    const { id } = req.params;
    await weaponService.deleteWeapon(id);
    res.status(200).json({
      message: 'Produk berhasil dinonaktifkan dari katalog!'
    });
  } catch (error) {
    next(error);
  }
};
