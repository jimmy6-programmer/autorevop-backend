const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['success', 'warning', 'info', 'urgent'],
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  relatedId: {
    type: String,
    required: false, // ID of related entity (order, booking, inventory item, etc.)
  },
  relatedType: {
    type: String,
    enum: ['order', 'booking', 'inventory', 'user', 'system'],
    required: false,
  },
  read: {
    type: Boolean,
    default: false,
  },
  readAt: {
    type: Date,
    required: false,
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium',
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Notification', notificationSchema);