const SparePart = require('../models/SparePart');

// Get all spare parts
exports.getSpareParts = async (req, res) => {
  try {
    const spareParts = await SparePart.find();
    res.json(spareParts);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching spare parts' });
  }
};

// Get spare part by ID
exports.getSparePartById = async (req, res) => {
  try {
    const sparePart = await SparePart.findById(req.params.id);
    if (!sparePart) {
      return res.status(404).json({ message: 'Spare part not found' });
    }
    res.json(sparePart);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching spare part' });
  }
};

// Create spare part
exports.createSparePart = async (req, res) => {
  try {
    const sparePart = new SparePart(req.body);
    await sparePart.save();
    res.status(201).json(sparePart);
  } catch (error) {
    res.status(500).json({ message: 'Error creating spare part' });
  }
};

// Update spare part
exports.updateSparePart = async (req, res) => {
  try {
    const sparePart = await SparePart.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!sparePart) {
      return res.status(404).json({ message: 'Spare part not found' });
    }
    res.json(sparePart);
  } catch (error) {
    res.status(500).json({ message: 'Error updating spare part' });
  }
};

// Delete spare part
exports.deleteSparePart = async (req, res) => {
  try {
    const sparePart = await SparePart.findByIdAndDelete(req.params.id);
    if (!sparePart) {
      return res.status(404).json({ message: 'Spare part not found' });
    }
    res.json({ message: 'Spare part deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting spare part' });
  }
};