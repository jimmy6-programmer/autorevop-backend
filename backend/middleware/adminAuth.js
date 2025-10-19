const jwt = require('jsonwebtoken');

module.exports = function(req, res, next) {
  console.log('🔐 Admin auth middleware triggered');
  console.log('📋 Headers:', req.headers);
  console.log('🔑 Authorization header:', req.header('Authorization'));

  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    console.log('❌ No token provided');
    return res.status(401).json({ message: 'No token, authorization denied' });
  }

  console.log('🔍 Verifying token...');

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('✅ Token verified successfully');
    req.admin = decoded.admin;
    next();
  } catch (err) {
    console.log('❌ Token verification failed:', err.message);
    res.status(401).json({ message: 'Token is not valid' });
  }
};