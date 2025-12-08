const express = require('express');
const { login, getProfile } = require('../controllers/adminController');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// POST /api/admin/login - Admin login
router.post('/login', login);

// GET /api/admin/profile - Get admin profile (protected)
router.get('/profile', adminAuth, getProfile);

module.exports = router;