const express = require('express');
const { getSpareParts, getSparePartById, createSparePart, updateSparePart, deleteSparePart } = require('../controllers/sparePartController');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

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