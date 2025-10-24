const Booking = require('../models/Booking');
const Notification = require('../models/Notification');

// Get all bookings
exports.getBookings = async (req, res) => {
  try {
    const bookings = await Booking.find().populate('serviceId', 'name type price');
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching bookings' });
  }
};

// Get booking by ID
exports.getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching booking' });
  }
};

// Create booking
exports.createBooking = async (req, res) => {
  try {
    console.log('🔄 Creating booking...');
    console.log('📋 Request body:', JSON.stringify(req.body, null, 2));

    // Populate issue/serviceType from service if serviceId is provided
    let bookingData = { ...req.body };

    if (bookingData.serviceId && !bookingData.issue && !bookingData.serviceType) {
      const Service = require('../models/Service');
      const service = await Service.findById(bookingData.serviceId);
      if (service) {
        if (bookingData.type === 'mechanic') {
          bookingData.issue = service.name;
        } else if (bookingData.type === 'towing') {
          bookingData.serviceType = service.name;
        }
        console.log('📝 Populated service info:', bookingData.type === 'mechanic' ? bookingData.issue : bookingData.serviceType);
      }
    }

    // Handle custom issue for "Other" option
    if (bookingData.customIssue && bookingData.type === 'mechanic') {
      bookingData.issue = bookingData.customIssue;
      console.log('📝 Using custom issue:', bookingData.issue);
    }

    const booking = new Booking(bookingData);
    console.log('💾 Saving booking to database...');

    await booking.save();
    console.log('✅ Booking saved successfully:', booking._id);

    // Create notification for new booking
    const serviceType = booking.type === 'mechanic' ? 'Mechanic Service' : 'Towing Service';
    const notification = new Notification({
      type: 'info',
      title: `New ${serviceType} Booking`,
      message: `${serviceType} booking ${booking._id} has been requested by ${booking.fullName}`,
      relatedId: booking._id,
      relatedType: 'booking',
    });

    console.log('🔔 Creating notification...');
    await notification.save();
    console.log('✅ Notification created');

    console.log('📤 Sending success response');
    res.status(201).json(booking);
  } catch (error) {
    console.error('❌ Error creating booking:', error.message);
    console.error('🔍 Error details:', error);
    console.error('📋 Error stack:', error.stack);
    res.status(500).json({ message: 'Error creating booking', error: error.message });
  }
};

// Update booking
exports.updateBooking = async (req, res) => {
  try {
    const oldBooking = await Booking.findById(req.params.id);
    const booking = await Booking.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Create notification for booking status update
    if (req.body.status && oldBooking && req.body.status !== oldBooking.status) {
      const serviceType = booking.type === 'mechanic' ? 'Mechanic Service' : 'Towing Service';
      const notification = new Notification({
        type: 'success',
        title: `${serviceType} Booking Status Updated`,
        message: `${serviceType} booking ${booking._id} status changed to ${req.body.status}`,
        relatedId: booking._id,
        relatedType: 'booking',
      });
      await notification.save();
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: 'Error updating booking' });
  }
};

// Delete booking
exports.deleteBooking = async (req, res) => {
  try {
    const booking = await Booking.findByIdAndDelete(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }
    res.json({ message: 'Booking deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting booking' });
  }
};