const express = require('express');
const { getOrders, getOrderById, createOrder, updateOrder, deleteOrder } = require('../controllers/orderController');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// POST /api/orders - Create order (public for mobile app)
router.post('/', createOrder);

// Admin routes
// GET /api/orders - Get all orders
router.get('/', adminAuth, getOrders);

// GET /api/orders/:id - Get order by ID
router.get('/:id', adminAuth, getOrderById);

// PUT /api/orders/:id - Update order
router.put('/:id', adminAuth, updateOrder);

// DELETE /api/orders/:id - Delete order
router.delete('/:id', adminAuth, deleteOrder);

module.exports = router;