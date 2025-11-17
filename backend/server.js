const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

const SparePart = require('./models/SparePart');
const Admin = require('./models/Admin');
const Service = require('./models/Service');
const DetailingService = require('./models/DetailingService');

// Database connection
mongoose.connect(process.env.DATABASE_URL)
.then(() => {
  console.log('MongoDB connected');
  seedInitialData();
  seedDefaultAdmin();
  seedInitialServices();
  seedDetailingService();
})
.catch(err => console.log(err));

// Seed initial data
async function seedInitialData() {
  try {
    const count = await SparePart.countDocuments();
    if (count === 0) {
      const initialData = [
        {
          id: "INV-1759666001892",
          name: "Oil filter",
          category: "Fluids",
          quantity: 20,
          price: 7000,
          supplier: "Kodak Oil filter",
          description: "Best oil filter in town",
          image: "https://images.unsplash.com/photo-1626368167765-fd8a597f3770?w=500",
          status: "in-stock"
        },
        {
          id: "INV-1759687637690",
          name: "Car wheel",
          category: "Tools",
          quantity: 30,
          price: 50000,
          supplier: "Ikirezi Spare parts",
          description: "Best car wheels in all cars",
          image: "https://images.unsplash.com/photo-1727017878252-2071b00ea38f?w=500",
          status: "in-stock"
        }
      ];
      await SparePart.insertMany(initialData);
      console.log('Initial inventory data seeded');
    }
  } catch (error) {
    console.error('Error seeding initial data:', error);
  }
}

// Seed default admin
async function seedDefaultAdmin() {
  try {
    const count = await Admin.countDocuments();
    if (count === 0) {
      const defaultAdmin = new Admin({
        username: 'admin',
        email: 'admin@auto-solutions.com',
        password: 'admin123',
        role: 'admin'
      });
      await defaultAdmin.save();
      console.log('Default admin user created');
    }
  } catch (error) {
    console.error('Error seeding default admin:', error);
  }
}

// Seed initial services
async function seedInitialServices() {
  try {
    const count = await Service.countDocuments();
    if (count === 0) {
      const initialServices = [
        // Mechanic Services
        {
          name: 'Engine Problem',
          type: 'mechanic',
          price: 80.0,
          currency: 'USD',
          description: 'Engine diagnostics and repair services',
          isActive: true,
        },
        {
          name: 'Brake Issue',
          type: 'mechanic',
          price: 60.0,
          currency: 'USD',
          description: 'Brake system inspection and repair',
          isActive: true,
        },
        {
          name: 'Transmission',
          type: 'mechanic',
          price: 120.0,
          currency: 'USD',
          description: 'Transmission system repair and maintenance',
          isActive: true,
        },
        {
          name: 'Electrical',
          type: 'mechanic',
          price: 70.0,
          currency: 'USD',
          description: 'Electrical system diagnostics and repair',
          isActive: true,
        },
        {
          name: 'Suspension',
          type: 'mechanic',
          price: 90.0,
          currency: 'USD',
          description: 'Suspension system inspection and repair',
          isActive: true,
        },
        {
          name: 'Tire/Wheel',
          type: 'mechanic',
          price: 40.0,
          currency: 'USD',
          description: 'Tire and wheel services',
          isActive: true,
        },
        {
          name: 'Air Conditioning',
          type: 'mechanic',
          price: 50.0,
          currency: 'USD',
          description: 'AC system repair and recharge',
          isActive: true,
        },
        {
          name: 'Exhaust',
          type: 'mechanic',
          price: 65.0,
          currency: 'USD',
          description: 'Exhaust system repair',
          isActive: true,
        },
        {
          name: 'Battery',
          type: 'mechanic',
          price: 35.0,
          currency: 'USD',
          description: 'Battery testing and replacement',
          isActive: true,
        },
        {
          name: 'Oil Change',
          type: 'mechanic',
          price: 25.0,
          currency: 'USD',
          description: 'Engine oil change service',
          isActive: true,
        },
        {
          name: 'Tuning',
          type: 'mechanic',
          price: 100.0,
          currency: 'USD',
          description: 'Engine tuning and performance optimization',
          isActive: true,
        },
        {
          name: 'Body Work',
          type: 'mechanic',
          price: 150.0,
          currency: 'USD',
          description: 'Body work and paint services',
          isActive: true,
        },
        // Towing Services
        {
          name: 'Standard Vehicle Towing',
          type: 'towing',
          price: 50.0,
          currency: 'USD',
          description: 'Standard towing service for vehicles',
          isActive: true,
        },
        {
          name: 'Accident Recovery Towing',
          type: 'towing',
          price: 100.0,
          currency: 'USD',
          description: 'Emergency towing for accident recovery',
          isActive: true,
        },
        {
          name: 'Long-Distance Towing',
          type: 'towing',
          price: 150.0,
          currency: 'USD',
          description: 'Long distance vehicle transportation',
          isActive: true,
        },
        {
          name: 'Motorcycle Towing',
          type: 'towing',
          price: 40.0,
          currency: 'USD',
          description: 'Specialized motorcycle towing service',
          isActive: true,
        },
        {
          name: 'Battery Jump-Start & Fuel Delivery',
          type: 'towing',
          price: 25.0,
          currency: 'USD',
          description: 'Emergency battery jump-start and fuel delivery',
          isActive: true,
        },
      ];
      await Service.insertMany(initialServices);
      console.log('Initial services data seeded');
    }
  } catch (error) {
    console.error('Error seeding initial services:', error);
  }
}

// Seed detailing service
async function seedDetailingService() {
  try {
    const count = await DetailingService.countDocuments();
    if (count === 0) {
      const defaultDetailingService = new DetailingService({
        basicPrice: 5000,
        standardPrice: 10000,
        premiumPrice: 20000,
        currency: 'RWF',
        basicDescription: 'Exterior cleaning only',
        standardDescription: 'Exterior + interior cleaning',
        premiumDescription: 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)'
      });
      await defaultDetailingService.save();
      console.log('Default detailing service created');
    }
  } catch (error) {
    console.error('Error seeding detailing service:', error);
  }
}

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/users', require('./routes/users'));
app.use('/api/bookings', require('./routes/bookings'));
app.use('/api/spare-parts', require('./routes/spareParts'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/services', require('./routes/services'));

// Legacy inventory endpoint (for compatibility)
app.get('/api/inventory', async (req, res) => {
  try {
    const inventory = await SparePart.find();
    res.json(inventory);
  } catch (error) {
    console.error('Error fetching inventory:', error);
    res.status(500).json({ message: 'Error fetching inventory' });
  }
});

// Legacy add spare part
app.post('/api/inventory', async (req, res) => {
  try {
    const { id, name, category, quantity, price, supplier, description, image, status } = req.body;

    const newSparePart = new SparePart({
      id,
      name,
      category,
      quantity,
      price,
      supplier,
      description,
      image,
      status
    });

    const savedPart = await newSparePart.save();
    res.status(201).json(savedPart);
  } catch (error) {
    console.error('Error adding spare part:', error);
    res.status(500).json({ message: 'Error adding spare part' });
  }
});

// Mechanics endpoint
app.get('/api/mechanics', (req, res) => {
  const mechanics = [
    {
      "_id": "68e02547925cfe77c719c9c4",
      "id": "MECH-001",
      "name": "Alex Rodriguez",
      "phone": "+1 (555) 111-2222",
      "email": "alex.rodriguez@repairhub.com",
      "specialty": "Engine Repair",
      "experience": "8 years",
      "status": "available",
      "rating": 4.8,
      "completedJobs": 156,
      "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      "location": "Rwanda",
      "jobs": [
        {
          "id": "JOB-001",
          "orderId": "ORD-001",
          "customerName": "John Smith",
          "service": "Oil Change",
          "completedDate": "2024-01-15T00:00:00.000Z",
          "rating": 5,
          "feedback": "Excellent service, very professional",
          "_id": "68e02547925cfe77c719c9c5"
        }
      ],
      "__v": 0,
      "createdAt": "2025-10-03T19:34:31.631Z",
      "updatedAt": "2025-10-03T19:34:31.631Z"
    },
    {
      "_id": "68e02547925cfe77c719c9c6",
      "id": "MECH-002",
      "name": "Maria Garcia",
      "phone": "+1 (555) 222-3333",
      "email": "maria.garcia@repairhub.com",
      "specialty": "Brake Systems",
      "experience": "6 years",
      "status": "busy",
      "rating": 4.9,
      "completedJobs": 134,
      "image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=face",
      "location": "Kenya",
      "jobs": [
        {
          "id": "JOB-002",
          "orderId": "ORD-002",
          "customerName": "Sarah Johnson",
          "service": "Brake Replacement",
          "completedDate": "2024-01-16T00:00:00.000Z",
          "rating": 5,
          "feedback": "Very thorough and knowledgeable",
          "_id": "68e02547925cfe77c719c9c7"
        }
      ],
      "__v": 0,
      "createdAt": "2025-10-03T19:34:31.632Z",
      "updatedAt": "2025-10-05T07:09:58.318Z"
    },
    {
      "_id": "68e02547925cfe77c719c9c8",
      "id": "MECH-003",
      "name": "David Chen",
      "phone": "+1 (555) 333-4444",
      "email": "david.chen@repairhub.com",
      "specialty": "Electrical Systems",
      "experience": "10 years",
      "status": "available",
      "rating": 4.7,
      "completedJobs": 203,
      "image": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "location": "Rwanda",
      "jobs": [
        {
          "id": "JOB-003",
          "orderId": "ORD-003",
          "customerName": "Mike Wilson",
          "service": "Battery Replacement",
          "completedDate": "2024-01-17T00:00:00.000Z",
          "rating": 4,
          "feedback": "Good work, but took longer than expected",
          "_id": "68e02547925cfe77c719c9c9"
        }
      ],
      "__v": 0,
      "createdAt": "2025-10-03T19:34:31.632Z",
      "updatedAt": "2025-10-03T19:34:31.632Z"
    },
    {
      "_id": "68e02547925cfe77c719c9ca",
      "id": "MECH-004",
      "name": "Sarah Johnson",
      "phone": "+1 (555) 444-5555",
      "email": "sarah.johnson@repairhub.com",
      "specialty": "Transmission",
      "experience": "7 years",
      "status": "offline",
      "rating": 4.6,
      "completedJobs": 89,
      "image": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      "location": "Kenya",
      "jobs": [
        {
          "id": "JOB-004",
          "orderId": "ORD-004",
          "customerName": "Emily Davis",
          "service": "Transmission Service",
          "completedDate": "2024-01-18T00:00:00.000Z",
          "rating": 5,
          "feedback": "Outstanding expertise",
          "_id": "68e02547925cfe77c719c9cb"
        }
      ],
      "__v": 0,
      "createdAt": "2025-10-03T19:34:31.632Z",
      "updatedAt": "2025-10-03T19:34:31.632Z"
    }
  ];
  res.json(mechanics);
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));