const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  phone: {
    type: String,
    required: false,
  },
  country: {
    type: String,
    required: false,
  },
  resetPasswordToken: String,
  resetPasswordExpires: Date,
}, {
  timestamps: true,
});

const inventorySchema = new mongoose.Schema({
  id: String,
  name: String,
  category: String,
  quantity: Number,
  price: Number,
  supplier: String,
  description: String,
  image: String,
  status: String
});

module.exports = { userSchema, inventorySchema };