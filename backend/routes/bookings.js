const express = require('express');
const { getBookings, getBookingById, createBooking, updateBooking, deleteBooking } = require('../controllers/bookingController');
const adminAuth = require('../middleware/adminAuth');
const auth = require('../middleware/auth');

const router = express.Router();

// POST /api/bookings - Create booking (no auth for now)
router.post('/', createBooking);

// Admin routes
// GET /api/bookings - Get all bookings
router.get('/', adminAuth, getBookings);

// GET /api/bookings/:id - Get booking by ID
router.get('/:id', adminAuth, getBookingById);

// PUT /api/bookings/:id - Update booking
router.put('/:id', adminAuth, updateBooking);

// DELETE /api/bookings/:id - Delete booking
router.delete('/:id', adminAuth, deleteBooking);

module.exports = router;