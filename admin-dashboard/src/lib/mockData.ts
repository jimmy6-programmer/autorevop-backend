// Enhanced mock data with additional fields for new functionality

export const Orders = [
  {
    id: 'ORD-001',
    customer: 'John Smith',
    product: 'Engine Oil',
    location: 'Musanze, KG 382',
    status: 'completed',
    date: '2024-01-15',
    estimatedCost: 45,
    actualCost: 42,
    customerPhone: '+1 (555) 123-4567',
    customerEmail: 'john.smith@email.com',
  },
  {
    id: 'ORD-002',
    customer: 'Sarah Johnson',
    product: 'Brake Pads',
    location: 'Kicukiro, KG 382',
    status: 'cancelled',
    date: '2024-01-16',
    estimatedCost: 320,
    actualCost: 315,
    customerPhone: '+1 (555) 234-5678',
    customerEmail: 'sarah.johnson@email.com',
  },
  {
    id: 'ORD-003',
    customer: 'Mike Wilson',
    product: 'Brake Pads',
    location: 'Kicukiro, KG 382',
    status: 'pending',
    date: '2024-01-17',
    estimatedCost: 150,
    actualCost: 145,
    customerPhone: '+1 (555) 345-6789',
    customerEmail: 'mike.wilson@email.com',
  },
  {
    id: 'ORD-004',
    customer: 'Emily Davis',
    product: 'Brake Pads',
    location: 'Kicukiro, KG 382',
    status: 'cancelled',
    date: '2024-01-18',
    estimatedCost: 280,
    actualCost: 275,
    customerPhone: '+1 (555) 456-7890',
    customerEmail: 'emily.davis@email.com',
  },
  {
    id: 'ORD-005',
    customer: 'Jennifer Wilson',
    product: 'Battery',
    location: 'Kicukiro, KG 382',
    status: 'pending',
    date: '2024-01-19',
    estimatedCost: 200,
    actualCost: 195,
    customerPhone: '+1 (555) 567-8901',
    customerEmail: 'jennifer.wilson@email.com',
  }
];

export const Bookings = [
  {
    id: 'BOOK-001',
    customer: 'John Smith',
    vehicle: '2020 Honda Civic',
    service: 'Oil Change',
    status: 'completed',
    priority: 'low',
    assignedTo: 'Alex Rodriguez',
    date: '2024-01-15',
    estimatedCost: 45,
    actualCost: 42,
    customerPhone: '+1 (555) 123-4567',
    customerEmail: 'john.smith@email.com',
    description: 'Regular oil change service with filter replacement',
    notes: 'Customer requested synthetic oil'
  },
  {
    id: 'BOOK-002',
    customer: 'Sarah Johnson',
    vehicle: '2019 Toyota Camry',
    service: 'Brake Repair',
    status: 'cancelled',
    priority: 'high',
    assignedTo: 'Mike Johnson',
    date: '2024-01-16',
    estimatedCost: 320,
    customerPhone: '+1 (555) 234-5678',
    customerEmail: 'sarah.johnson@email.com',
    description: 'Front brake pads replacement and rotor resurfacing',
    notes: 'Customer reported squeaking noise'
  },
  {
    id: 'BOOK-003',
    customer: 'Mike Wilson',
    vehicle: '2021 Ford F-150',
    service: 'Engine Diagnostic',
    status: 'pending',
    priority: 'medium',
    assignedTo: 'Sarah Wilson',
    date: '2024-01-17',
    estimatedCost: 150,
    customerPhone: '+1 (555) 345-6789',
    customerEmail: 'mike.wilson@email.com',
    description: 'Check engine light diagnostic and repair',
    notes: 'Engine light came on yesterday'
  },
  {
    id: 'BOOK-004',
    customer: 'Emily Davis',
    vehicle: '2018 BMW X3',
    service: 'AC Repair',
    status: 'cancelled',
    priority: 'low',
    assignedTo: 'Tom Brown',
    date: '2024-01-18',
    estimatedCost: 280,
    customerPhone: '+1 (555) 456-7890',
    customerEmail: 'emily.davis@email.com',
    description: 'Air conditioning system not cooling properly',
    notes: 'Customer cancelled due to cost'
  },
  {
    id: 'BOOK-005',
    customer: 'Jennifer Wilson',
    vehicle: '2022 Tesla Model 3',
    service: 'Battery Check',
    status: 'pending',
    priority: 'medium',
    assignedTo: 'Alex Rodriguez',
    date: '2024-01-19',
    estimatedCost: 200,
    customerPhone: '+1 (555) 567-8901',
    customerEmail: 'jennifer.wilson@email.com',
    description: 'Battery performance diagnostic and health check',
    notes: 'Range has decreased recently'
  }
];

export const mechanics = [
  {
    id: 'MECH-001',
    name: 'Alex Rodriguez',
    phone: '+1 (555) 111-2222',
    email: 'alex.rodriguez@repairhub.com',
    specialty: 'Engine Repair',
    experience: '8 years',
    status: 'available',
    rating: 4.8,
    completedJobs: 156,
    jobs: [
      {
        id: 'JOB-001',
        orderId: 'ORD-001',
        customerName: 'John Smith',
        service: 'Oil Change',
        completedDate: '2024-01-15',
        rating: 5,
        feedback: 'Excellent service, very professional'
      },
      {
        id: 'JOB-002',
        orderId: 'ORD-012',
        customerName: 'Mary Johnson',
        service: 'Engine Tune-up',
        completedDate: '2024-01-10',
        rating: 4,
        feedback: 'Good work, car runs much better now'
      }
    ]
  },
  {
    id: 'MECH-002',
    name: 'Mike Johnson',
    phone: '+1 (555) 222-3333',
    email: 'mike.johnson@repairhub.com',
    specialty: 'Brake Systems',
    experience: '6 years',
    status: 'busy',
    rating: 4.6,
    completedJobs: 134,
    jobs: [
      {
        id: 'JOB-003',
        orderId: 'ORD-008',
        customerName: 'David Brown',
        service: 'Brake Replacement',
        completedDate: '2024-01-12',
        rating: 5,
        feedback: 'Perfect brake job, stops like new'
      }
    ]
  },
  {
    id: 'MECH-003',
    name: 'Sarah Wilson',
    phone: '+1 (555) 333-4444',
    email: 'sarah.wilson@repairhub.com',
    specialty: 'Electrical Systems',
    experience: '5 years',
    status: 'available',
    rating: 4.9,
    completedJobs: 98,
    jobs: [
      {
        id: 'JOB-004',
        orderId: 'ORD-015',
        customerName: 'Lisa Garcia',
        service: 'Electrical Diagnostic',
        completedDate: '2024-01-08',
        rating: 5,
        feedback: 'Found the issue quickly, great expertise'
      }
    ]
  },
  {
    id: 'MECH-004',
    name: 'Tom Brown',
    phone: '+1 (555) 444-5555',
    email: 'tom.brown@repairhub.com',
    specialty: 'AC & Heating',
    experience: '4 years',
    status: 'offline',
    rating: 4.3,
    completedJobs: 87,
    jobs: [
      {
        id: 'JOB-005',
        orderId: 'ORD-020',
        customerName: 'Robert Lee',
        service: 'AC Repair',
        completedDate: '2024-01-05',
        rating: 4,
        feedback: 'AC works well now, thanks'
      }
    ]
  }
];

export const inventory = [
  {
    id: 'INV-001',
    name: 'Engine Oil 5W-30',
    category: 'Fluids',
    quantity: 45,
    price: 8.99,
    supplier: 'Mobil 1',
    description: 'High-quality synthetic engine oil for modern vehicles',
    status: 'in-stock',
    lastUpdated: '2024-01-15'
  },
  {
    id: 'INV-002',
    name: 'Brake Pads Set',
    category: 'Brake System',
    quantity: 8,
    price: 89.99,
    supplier: 'Brembo',
    description: 'Premium ceramic brake pads for front wheels',
    status: 'low-stock',
    lastUpdated: '2024-01-14'
  },
  {
    id: 'INV-003',
    name: 'Spark Plugs',
    category: 'Engine Parts',
    quantity: 5,
    price: 12.50,
    supplier: 'NGK',
    description: 'Iridium spark plugs for improved performance',
    status: 'low-stock',
    lastUpdated: '2024-01-13'
  },
  {
    id: 'INV-004',
    name: 'Air Filter',
    category: 'Engine Parts',
    quantity: 0,
    price: 24.99,
    supplier: 'K&N',
    description: 'High-flow air filter for better engine breathing',
    status: 'out-of-stock',
    lastUpdated: '2024-01-12'
  },
  {
    id: 'INV-005',
    name: 'Transmission Fluid',
    category: 'Fluids',
    quantity: 22,
    price: 15.99,
    supplier: 'Valvoline',
    description: 'Automatic transmission fluid for smooth shifting',
    status: 'in-stock',
    lastUpdated: '2024-01-16'
  },
  {
    id: 'INV-006',
    name: 'Battery 12V',
    category: 'Electrical',
    quantity: 12,
    price: 129.99,
    supplier: 'Interstate',
    description: 'Maintenance-free car battery with 3-year warranty',
    status: 'in-stock',
    lastUpdated: '2024-01-11'
  },
  {
    id: 'INV-007',
    name: 'Tire Pressure Gauge',
    category: 'Tools',
    quantity: 3,
    price: 19.99,
    supplier: 'Tekton',
    description: 'Digital tire pressure gauge for accurate readings',
    status: 'low-stock',
    lastUpdated: '2024-01-10'
  },
  {
    id: 'INV-008',
    name: 'Coolant',
    category: 'Fluids',
    quantity: 18,
    price: 11.99,
    supplier: 'Prestone',
    description: 'Extended life antifreeze/coolant for all vehicles',
    status: 'in-stock',
    lastUpdated: '2024-01-09'
  }
];