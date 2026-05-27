export const errorMiddleware = (err, req, res, next) => {
  console.error('[Error]:', err.message || err);
  
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Server error. Please try again.';
  
  res.status(statusCode).json({
    message,
    errors: err.errors || undefined,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
};
