const express = require('express');
const { getServices, getServicesByType, getServiceById, createService, updateService, deleteService } = require('../controllers/serviceController');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// Public routes
// GET /api/services - Get all services
router.get('/', getServices);

// GET /api/services/type/:type - Get services by type (mechanic or towing)
router.get('/type/:type', getServicesByType);

// GET /api/services/:id - Get service by ID
router.get('/:id', getServiceById);

// Admin routes
// POST /api/services - Create service
router.post('/', adminAuth, createService);

// PUT /api/services/:id - Update service
router.put('/:id', adminAuth, updateService);

// DELETE /api/services/:id - Delete service
router.delete('/:id', adminAuth, deleteService);

module.exports = router;