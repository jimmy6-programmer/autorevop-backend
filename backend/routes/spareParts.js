const express = require('express');
const { getSpareParts, getSparePartById, createSparePart, updateSparePart, deleteSparePart } = require('../controllers/sparePartController');
const adminAuth = require('../middleware/adminAuth');
const auth = require('../middleware/auth');

const router = express.Router();

// Public routes - no authentication required for reading
// GET /api/spare-parts - Get all spare parts (public)
router.get('/', getSpareParts);

// GET /api/spare-parts/:id - Get spare part by ID (public)
router.get('/:id', getSparePartById);

// Admin routes - require admin authentication
// POST /api/spare-parts - Create spare part
router.post('/', adminAuth, createSparePart);

// PUT /api/spare-parts/:id - Update spare part
router.put('/:id', adminAuth, updateSparePart);

// DELETE /api/spare-parts/:id - Delete spare part
router.delete('/:id', adminAuth, deleteSparePart);

// GET /api/spare-parts - Get all spare parts
router.get('/', getSpareParts);

// GET /api/spare-parts/:id - Get spare part by ID
router.get('/:id', getSparePartById);

// POST /api/spare-parts - Create spare part
router.post('/', createSparePart);

// PUT /api/spare-parts/:id - Update spare part
router.put('/:id', updateSparePart);

// DELETE /api/spare-parts/:id - Delete spare part
router.delete('/:id', deleteSparePart);

module.exports = router;