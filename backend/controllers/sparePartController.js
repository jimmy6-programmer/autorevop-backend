const SparePart = require('../models/SparePart');

// Get all spare parts
exports.getSpareParts = async (req, res) => {
  try {
    const { page = 1, limit = 50, search } = req.query;

    let query = {};

    // Add search functionality
    if (search) {
      query = {
        $or: [
          { name: { $regex: search, $options: 'i' } },
          { description: { $regex: search, $options: 'i' } },
          { category: { $regex: search, $options: 'i' } }
        ]
      };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const spareParts = await SparePart.find(query)
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });

    const total = await SparePart.countDocuments(query);

    res.json({
      data: spareParts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching spare parts' });
  }
};

// Get spare part by ID
exports.getSparePartById = async (req, res) => {
  try {
    const sparePart = await SparePart.findOne({ id: req.params.id });
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
    const sparePart = await SparePart.findOneAndUpdate({ id: req.params.id }, req.body, { new: true, runValidators: true });
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
    const sparePart = await SparePart.findOneAndDelete({ id: req.params.id });
    if (!sparePart) {
      return res.status(404).json({ message: 'Spare part not found' });
    }
    res.json({ message: 'Spare part deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting spare part' });
  }
};