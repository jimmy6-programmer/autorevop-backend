const express = require('express');
const { getUsers, getUserById, updateUser, deleteUser } = require('../controllers/userController');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

// GET /api/users - Get all users
router.get('/', getUsers);

// GET /api/users/:id - Get user by ID
router.get('/:id', getUserById);

// PUT /api/users/:id - Update user
router.put('/:id', updateUser);

// DELETE /api/users/:id - Delete user
router.delete('/:id', deleteUser);

module.exports = router;