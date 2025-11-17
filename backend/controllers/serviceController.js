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
    console.log('🔄 Fetching detailing plans...');
    
    // Check if DetailingService model is properly imported
    if (!DetailingService) {
      console.error('❌ DetailingService model not found');
      return res.status(500).json({ message: 'DetailingService model not available' });
    }
    
    let detailingService = await DetailingService.findOne();
    console.log('📋 Found detailing service:', detailingService ? 'Yes' : 'No');
    
    // If no detailing service exists, create one with default values
    if (!detailingService) {
      console.log('🔄 Creating default detailing service...');
      detailingService = new DetailingService({
        basicPrice: 50,
        standardPrice: 100,
        premiumPrice: 200,
        currency: 'USD',
        basicDescription: 'Exterior cleaning only',
        standardDescription: 'Exterior + interior cleaning',
        premiumDescription: 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)'
      });
      await detailingService.save();
      console.log('✅ Default detailing service created');
    }
    
    const response = {
      success: true,
      basicPrice: detailingService.basicPrice || 5000,
      standardPrice: detailingService.standardPrice || 10000,
      premiumPrice: detailingService.premiumPrice || 20000,
      currency: detailingService.currency || 'RWF',
      basicDescription: detailingService.basicDescription || 'Exterior cleaning only',
      standardDescription: detailingService.standardDescription || 'Exterior + interior cleaning',
      premiumDescription: detailingService.premiumDescription || 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)'
    };
    
    console.log('✅ Returning detailing plans:', JSON.stringify(response, null, 2));
    res.json(response);
  } catch (error) {
    console.error('❌ Error fetching detailing plans:', error.message);
    console.error('🔍 Full error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching detailing plans',
      error: error.message
    });
  }
};

// Update detailing plan prices
exports.updateDetailingPlans = async (req, res) => {
  try {
    console.log('🔄 Updating detailing plans...');
    console.log('📋 Update data:', JSON.stringify(req.body, null, 2));

    // Validate required fields
    const { basicPrice, standardPrice, premiumPrice, basicDescription, standardDescription, premiumDescription } = req.body;

    if (basicPrice === undefined || standardPrice === undefined || premiumPrice === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Missing required price fields'
      });
    }

    // Ensure prices are valid numbers
    const parsedBasicPrice = parseFloat(basicPrice);
    const parsedStandardPrice = parseFloat(standardPrice);
    const parsedPremiumPrice = parseFloat(premiumPrice);

    if (isNaN(parsedBasicPrice) || isNaN(parsedStandardPrice) || isNaN(parsedPremiumPrice)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid price values - must be numbers'
      });
    }

    // Prepare update data
    const updateData = {
      basicPrice: parsedBasicPrice,
      standardPrice: parsedStandardPrice,
      premiumPrice: parsedPremiumPrice,
      currency: 'USD',
      basicDescription: basicDescription || 'Exterior cleaning only',
      standardDescription: standardDescription || 'Exterior + interior cleaning',
      premiumDescription: premiumDescription || 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)'
    };

    const detailingService = await DetailingService.findOneAndUpdate(
      {},
      updateData,
      { new: true, upsert: true, runValidators: true }
    );

    console.log('✅ Detailing plans updated successfully');

    res.json({
      success: true,
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
    res.status(500).json({
      success: false,
      message: 'Error updating detailing plans',
      error: error.message
    });
  }
};