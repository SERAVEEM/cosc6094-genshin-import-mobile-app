import pool from '../config/db.js';

export const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Authorization token is missing or invalid!' });
    }

    const token = authHeader.split(' ')[1];
    if (!token || token.length < 20) {
      return res.status(401).json({ message: 'Invalid token format!' });
    }

    // Query database for user with this session token
    const [rows] = await pool.execute(
      'SELECT id, name, email, role FROM users WHERE session_token = ?',
      [token]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Unauthorized: Session token has expired or is invalid!' });
    }

    req.user = rows[0];
    next();
  } catch (error) {
    next(error);
  }
};

export const roleMiddleware = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized!' });
    }
    
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden: You do not have permission to perform this action!' });
    }
    
    next();
  };
};
