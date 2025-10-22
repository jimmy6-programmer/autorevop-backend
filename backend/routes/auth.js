const express = require('express');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const User = require('../models/User');
const Booking = require('../models/Booking');
const auth = require('../middleware/auth');

const router = express.Router();

// Signup
router.post('/signup', async (req, res) => {
  const { name, email, password, phone, country } = req.body;

  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: 'User already exists' });
    }

    user = new User({ name, email, password, phone, country });
    await user.save();

    const payload = { user: { id: user.id } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.status(201).json({ token });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const payload = { user: { id: user.id } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.json({ token });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Forgot Password
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;

  console.log(`Forgot password request for email: ${email}`);

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    // Generate 6-digit reset code
    const resetToken = Math.floor(Math.random() * 900000) + 100000;
    user.resetPasswordToken = resetToken.toString();
    user.resetPasswordExpires = Date.now() + 3600000; // 1 hour
    await user.save();

    // Create transporter
    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.EMAIL_PORT) || 587,
      secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    // Email options
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Password Reset Code',
      text: `You requested a password reset. Use this 6-digit code to reset your password: ${resetToken}\n\nThis code expires in 1 hour.`,
      html: `<p>You requested a password reset.</p><p>Use this 6-digit code to reset your password: <strong>${resetToken}</strong></p><p>This code expires in 1 hour.</p>`,
    };

    // Send email
    try {
      await transporter.sendMail(mailOptions);
      res.json({ message: 'Password reset email sent' });
    } catch (emailError) {
      console.error('Email sending failed:', emailError.message);
      // For testing, return the token if email fails
      res.json({ message: 'Password reset token generated (email failed)', token: resetToken });
    }
  } catch (err) {
    console.error('Error in forgot-password:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Reset Password
router.post('/reset-password/:token', async (req, res) => {
  const { password } = req.body;
  const { token } = req.params;

  try {
    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();

    res.json({ message: 'Password reset successful' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Protected route example
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Fetch mechanics from dashboard API (same server for now)
router.get('/mechanics', async (req, res) => {
  try {
    // For now, fetch from the same server's mechanics endpoint
    // In production, this would be: process.env.DASHBOARD_API_URL || 'https://your-dashboard-api.com/api/mechanics'
    const dashboardApiUrl = 'http://localhost:5000/api/mechanics';

    const response = await fetch(dashboardApiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        // Add any required authentication headers for the dashboard API
        // 'Authorization': `Bearer ${process.env.DASHBOARD_API_TOKEN}`,
      },
    });

    if (!response.ok) {
      return res.status(response.status).json({ message: 'Failed to fetch mechanics from dashboard' });
    }

    const mechanicsData = await response.json();

    // Transform the data to match our expected format
    const specialtyMapping = {
      'Engine Repair': 'engineMaintenance',
      'Brake Systems': 'brakePads', // closest match
      'Electrical Systems': 'batteryReplacement', // closest match
      'Transmission': 'engineMaintenance', // fallback
    };

    const transformedMechanics = mechanicsData.map((mechanic, index) => ({
      id: parseInt(mechanic.id.split('-')[1]) || index + 1, // Extract number from "MECH-001"
      name: mechanic.name,
      specialtyKey: specialtyMapping[mechanic.specialty] || 'engineMaintenance', // fallback to engineMaintenance
      location: mechanic.location || 'Unknown', // Use the location from API
      phone: mechanic.phone,
      imageAsset: mechanic.image, // Use the image URL directly
      email: mechanic.email,
      specialty: mechanic.specialty,
      experience: mechanic.experience,
      status: mechanic.status,
      rating: mechanic.rating,
      completedJobs: mechanic.completedJobs,
      jobs: mechanic.jobs,
    }));

    res.json(transformedMechanics);
  } catch (err) {
    console.error('Error fetching mechanics:', err);
    res.status(500).json({ message: 'Server error fetching mechanics' });
  }
});

// Fetch inventory from dashboard API
router.get('/inventory', async (req, res) => {
  try {
    // Fetch from the dashboard API
    const dashboardApiUrl = 'http://localhost:5000/api/inventory';

    const response = await fetch(dashboardApiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        // Add any required authentication headers for the dashboard API
        // 'Authorization': `Bearer ${process.env.DASHBOARD_API_TOKEN}`,
      },
    });

    if (!response.ok) {
      return res.status(response.status).json({ message: 'Failed to fetch inventory from dashboard' });
    }

    const inventoryData = await response.json();

    res.json(inventoryData);
  } catch (err) {
    console.error('Error fetching inventory:', err);
    res.status(500).json({ message: 'Server error fetching inventory' });
  }
});


module.exports = router;