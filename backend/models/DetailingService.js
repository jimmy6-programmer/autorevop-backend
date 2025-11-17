const mongoose = require('mongoose');

const detailingServiceSchema = new mongoose.Schema({
  basicPrice: {
    type: Number,
    required: true,
    default: 50, // Default price in USD
  },
  standardPrice: {
    type: Number,
    required: true,
    default: 100, // Default price in USD
  },
  premiumPrice: {
    type: Number,
    required: true,
    default: 200, // Default price in USD
  },
  currency: {
    type: String,
    required: true,
    default: 'USD',
  },
  basicDescription: {
    type: String,
    default: 'Exterior cleaning only',
  },
  standardDescription: {
    type: String,
    default: 'Exterior + interior cleaning',
  },
  premiumDescription: {
    type: String,
    default: 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)',
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('DetailingService', detailingServiceSchema);