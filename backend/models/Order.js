const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  customerName: {
    type: String,
    required: true,
  },
  customerPhone: {
    type: String,
    required: true,
  },
  customerEmail: {
    type: String,
    required: false,
  },
  items: [{
    productId: {
      type: String,
      required: true,
    },
    productName: {
      type: String,
      required: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: 1,
    },
    price: {
      type: Number,
      required: true,
    },
    total: {
      type: Number,
      required: true,
    },
  }],
  totalAmount: {
    type: Number,
    required: true,
  },
  deliveryLocation: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'shipped', 'delivered', 'cancelled'],
    default: 'pending',
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'mobile_money'],
    default: 'cash',
  },
  notes: {
    type: String,
    required: false,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Order', orderSchema);