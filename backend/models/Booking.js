const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true, // 'mechanic' or 'towing'
  },
  fullName: {
    type: String,
    required: true,
  },
  phoneNumber: {
    type: String,
    required: true,
  },
  vehicleBrand: {
    type: String,
    required: function() { return this.type === 'mechanic'; },
  },
  vehicleModel: {
    type: String,
    required: function() { return this.type === 'towing'; },
  },
  carPlateNumber: {
    type: String,
    required: function() { return this.type === 'towing'; },
  },
  serviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    required: true,
  },
  issue: {
    type: String,
    required: false, // Not required since we now use serviceId
  },
  serviceType: {
    type: String,
    required: false, // Not required since we now use serviceId
  },
  location: {
    type: String,
    required: true,
  },
  pickupLocation: {
    type: String,
    required: function() { return this.type === 'towing'; },
  },
  totalPrice: {
    type: String,
    required: true,
  },
  currency: {
    type: String,
    required: true,
    default: 'USD',
  },
  mechanicId: {
    type: String, // ID of the mechanic, if selected
    required: false,
  },
  status: {
    type: String,
    default: 'pending', // pending, confirmed, completed, cancelled
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Booking', bookingSchema);