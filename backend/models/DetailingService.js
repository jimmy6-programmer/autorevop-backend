const mongoose = require('mongoose');

const detailingServiceSchema = new mongoose.Schema({
  basicPrice: {
    type: Number,
    required: true,
    default: 5000, // Default price in RWF
  },
  standardPrice: {
    type: Number,
    required: true,
    default: 10000, // Default price in RWF
  },
  premiumPrice: {
    type: Number,
    required: true,
    default: 20000, // Default price in RWF
  },
  currency: {
    type: String,
    required: true,
    default: 'RWF',
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