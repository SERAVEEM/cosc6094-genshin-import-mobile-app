import * as authService from '../services/authService.js';

export const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    const user = await authService.register({ name, email, password });
    res.status(201).json({
      message: 'Registrasi berhasil!',
      user
    });
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login({ email, password });
    res.status(200).json({
      message: 'Login berhasil!',
      ...result
    });
  } catch (error) {
    next(error);
  }
};

export const oauth = async (req, res, next) => {
  try {
    const { email, name, oauth_id } = req.body;
    const result = await authService.handleOauth({ email, name, oauth_id });
    res.status(200).json({
      message: 'Login OAuth berhasil!',
      ...result
    });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req, res, next) => {
  try {
    await authService.logout(req.user.id);
    res.status(200).json({
      message: 'Logout berhasil!'
    });
  } catch (error) {
    next(error);
  }
};
