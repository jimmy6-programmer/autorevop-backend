const Service = require('../models/Service');
const DetailingService = require('../models/DetailingService');

// Get all services
exports.getServices = async (req, res) => {
  try {
    const services = await Service.find();
    res.json(services);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching services' });
  }
};

// Get services by type (mechanic or towing)
exports.getServicesByType = async (req, res) => {
  try {
    const { type } = req.params;
    const services = await Service.find({ type, isActive: true });
    res.json(services);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching services' });
  }
};

// Get service by ID
exports.getServiceById = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    res.json(service);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching service' });
  }
};

// Create service
exports.createService = async (req, res) => {
  try {
    console.log('🔄 Creating service...');
    console.log('📋 Request body:', JSON.stringify(req.body, null, 2));

    const service = new Service(req.body);
    console.log('💾 Saving service to database...');

    await service.save();
    console.log('✅ Service saved successfully:', service._id);

    res.status(201).json(service);
  } catch (error) {
    console.error('❌ Error creating service:', error.message);
    console.error('🔍 Error details:', error);
    res.status(500).json({ message: 'Error creating service', error: error.message });
  }
};

// Update service
exports.updateService = async (req, res) => {
  try {
    console.log('🔄 Updating service:', req.params.id);
    console.log('📋 Update data:', JSON.stringify(req.body, null, 2));

    const service = await Service.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!service) {
      console.log('❌ Service not found');
      return res.status(404).json({ message: 'Service not found' });
    }

    console.log('✅ Service updated successfully');
    res.json(service);
  } catch (error) {
    console.error('❌ Error updating service:', error.message);
    console.error('🔍 Error details:', error);
    res.status(500).json({ message: 'Error updating service', error: error.message });
  }
};

// Delete service
exports.deleteService = async (req, res) => {
  try {
    const service = await Service.findByIdAndDelete(req.params.id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    res.json({ message: 'Service deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting service' });
  }
};

// Detailing Service Controllers

// Get detailing plan prices
exports.getDetailingPlans = async (req, res) => {
  try {
    let detailingService = await DetailingService.findOne();
    
    // If no detailing service exists, create one with default values
    if (!detailingService) {
      detailingService = new DetailingService({
        basicPrice: 5000,
        standardPrice: 10000,
        premiumPrice: 20000,
        currency: 'RWF'
      });
      await detailingService.save();
    }
    
    res.json({
      basicPrice: detailingService.basicPrice,
      standardPrice: detailingService.standardPrice,
      premiumPrice: detailingService.premiumPrice,
      currency: detailingService.currency,
      basicDescription: detailingService.basicDescription,
      standardDescription: detailingService.standardDescription,
      premiumDescription: detailingService.premiumDescription
    });
  } catch (error) {
    console.error('❌ Error fetching detailing plans:', error.message);
    res.status(500).json({ message: 'Error fetching detailing plans', error: error.message });
  }
};

// Update detailing plan prices
exports.updateDetailingPlans = async (req, res) => {
  try {
    console.log('🔄 Updating detailing plans...');
    console.log('📋 Update data:', JSON.stringify(req.body, null, 2));

    let detailingService = await DetailingService.findOne();
    
    if (!detailingService) {
      // Create new detailing service if none exists
      detailingService = new DetailingService(req.body);
    } else {
      // Update existing detailing service
      Object.assign(detailingService, req.body);
    }
    
    await detailingService.save();
    console.log('✅ Detailing plans updated successfully');
    
    res.json({
      basicPrice: detailingService.basicPrice,
      standardPrice: detailingService.standardPrice,
      premiumPrice: detailingService.premiumPrice,
      currency: detailingService.currency,
      basicDescription: detailingService.basicDescription,
      standardDescription: detailingService.standardDescription,
      premiumDescription: detailingService.premiumDescription
    });
  } catch (error) {
    console.error('❌ Error updating detailing plans:', error.message);
    console.error('🔍 Error details:', error);
    res.status(500).json({ message: 'Error updating detailing plans', error: error.message });
  }
};