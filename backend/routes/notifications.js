const express = require('express');
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  createNotification
} = require('../controllers/notificationController');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// Admin routes
// GET /api/notifications - Get all notifications
router.get('/', adminAuth, getNotifications);

// GET /api/notifications/unread-count - Get unread notifications count
router.get('/unread-count', adminAuth, getUnreadCount);

// PUT /api/notifications/:id/read - Mark notification as read
router.put('/:id/read', adminAuth, markAsRead);

// PUT /api/notifications/mark-all-read - Mark all notifications as read
router.put('/mark-all-read', adminAuth, markAllAsRead);

// DELETE /api/notifications/:id - Delete notification
router.delete('/:id', adminAuth, deleteNotification);

// POST /api/notifications - Create notification (internal use)
router.post('/', adminAuth, createNotification);

module.exports = router;