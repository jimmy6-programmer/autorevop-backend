const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true, // 'mechanic', 'towing', or 'detailing'
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
  vehicleType: {
    type: String,
    required: function() { return this.type === 'detailing'; },
  },
  serviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    required: function() { return !this.customIssue && this.type !== 'detailing'; }, // Not required for detailing or custom issues
  },
  issue: {
    type: String,
    required: false, // Not required since we now use serviceId
  },
  serviceType: {
    type: String,
    required: function() { return this.type === 'detailing'; }, // Required for detailing bookings
  },
  customIssue: {
    type: String,
    required: false, // For custom issues when "Other" is selected
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