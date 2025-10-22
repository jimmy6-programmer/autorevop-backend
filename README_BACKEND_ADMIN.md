# Auto Solutions Backend and Admin Dashboard

This project provides a complete backend system for the Auto Solutions Flutter mobile app, including an admin dashboard for managing users, bookings, and products.

## Project Structure

```
auto_revop-main/
├── backend/                    # Mobile app backend (Node.js + Express + MongoDB)
│   ├── controllers/            # Business logic controllers
│   ├── models/                 # Mongoose models
│   ├── routes/                 # API routes
│   ├── middleware/             # Authentication middleware
│   ├── server.js               # Main server file
│   └── package.json
├── admin-backend/              # Admin backend (Node.js + Express + MongoDB)
│   ├── controllers/            # Admin controllers
│   ├── models/                 # Admin models
│   ├── routes/                 # Admin API routes
│   ├── middleware/             # Admin authentication
│   ├── server.js               # Admin server
│   └── package.json
└── admin-dashboard/            # React admin dashboard
    ├── src/
    │   ├── components/         # Reusable UI components
    │   ├── pages/              # Dashboard pages
    │   ├── services/           # API service functions
    │   └── App.js
    ├── public/
    └── package.json
```

## Mobile App Backend (Port 5000)

### Features
- User authentication (signup, login, forgot password, reset password)
- Booking management (mechanic services, towing services)
- Spare parts/products management
- CORS configured for Flutter app

### API Endpoints

#### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password/:token` - Reset password
- `GET /api/auth/me` - Get current user profile

#### Users
- `GET /api/users` - Get all users (admin)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

#### Bookings
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/:id` - Get booking by ID
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id` - Update booking
- `DELETE /api/bookings/:id` - Delete booking

#### Spare Parts
- `GET /api/spare-parts` - Get all spare parts
- `GET /api/spare-parts/:id` - Get spare part by ID
- `POST /api/spare-parts` - Create spare part
- `PUT /api/spare-parts/:id` - Update spare part
- `DELETE /api/spare-parts/:id` - Delete spare part

#### Legacy Endpoints (for compatibility)
- `GET /api/mechanics` - Get mechanics list
- `GET /api/inventory` - Get spare parts (alias for /api/spare-parts)
- `POST /api/inventory` - Add spare part (alias for POST /api/spare-parts)

## Admin Backend (Port 5001)

### Features
- Admin authentication with JWT
- CRUD operations for users, bookings, and products
- Separate from mobile app backend for security

### API Endpoints

#### Admin Authentication
- `POST /api/admin/login` - Admin login
- `GET /api/admin/profile` - Get admin profile

#### Users Management
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

#### Bookings Management
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/:id` - Get booking by ID
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id` - Update booking
- `DELETE /api/bookings/:id` - Delete booking

#### Products Management
- `GET /api/spare-parts` - Get all products
- `GET /api/spare-parts/:id` - Get product by ID
- `POST /api/spare-parts` - Create product
- `PUT /api/spare-parts/:id` - Update product
- `DELETE /api/spare-parts/:id` - Delete product

## Admin Dashboard (React Frontend)

### Features
- Login page for admin authentication
- Dashboard with statistics
- Users management page with table
- Products management page with add/edit forms
- Bookings management page with status updates
- Responsive design with sidebar navigation

### Pages
- `/login` - Admin login
- `/` - Dashboard overview
- `/users` - Users management
- `/products` - Products management
- `/bookings` - Bookings management

## Setup Instructions

### Prerequisites
- Node.js (v14 or higher)
- MongoDB
- npm or yarn

### 1. Install Dependencies

#### Mobile Backend
```bash
cd backend
npm install
```

#### Admin Backend
```bash
cd admin-backend
npm install
```

#### Admin Dashboard
```bash
cd admin-dashboard
npm install
```

### 2. Environment Configuration

#### Mobile Backend (.env)
```
MONGO_URI=mongodb://localhost:27017/auto_revop
JWT_SECRET=your_jwt_secret_here
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password
PORT=5000
```

#### Admin Backend (.env)
```
MONGO_URI=mongodb://localhost:27017/auto_revop
JWT_SECRET=your_admin_jwt_secret_here
PORT=5001
```

### 3. Start MongoDB
Make sure MongoDB is running on your system.

### 4. Seed Initial Data (Optional)
The mobile backend automatically seeds initial spare parts data on first run.

### 5. Start Servers

#### Start Mobile Backend
```bash
cd backend
npm run dev
```
Server runs on http://localhost:5000

#### Start Admin Backend
```bash
cd admin-backend
npm run dev
```
Server runs on http://localhost:5001

#### Start Admin Dashboard
```bash
cd admin-dashboard
npm start
```
Dashboard runs on http://localhost:3000

### 6. Create Admin User
To create an admin user, you can manually add one to the database or create a script. For development, you can temporarily modify the admin controller to create a default admin.

Example admin credentials for testing:
- Email: admin@example.com
- Password: admin123

## Connecting Flutter App to Backend

In your Flutter app, update the API base URL to point to the mobile backend:

```dart
const String baseUrl = 'http://localhost:5000/api';
```

Example API calls:
- Login: `POST $baseUrl/auth/login`
- Get Spare Parts: `GET $baseUrl/spare-parts`
- Create Booking: `POST $baseUrl/bookings`

## Connecting Admin Dashboard to Backend

The admin dashboard is already configured to connect to `http://localhost:5001/api`. Make sure the admin backend is running.

## Security Notes

- JWT tokens are used for authentication
- Passwords are hashed with bcrypt
- CORS is configured to allow requests from Flutter app
- Admin routes require authentication
- Mobile app routes use user authentication

## Development Notes

- Both backends share the same MongoDB database
- Admin backend uses separate JWT secret for security
- The system is designed to be modular and scalable
- Error handling is implemented throughout the APIs

## Troubleshooting

1. **CORS Issues**: Ensure CORS is properly configured in both backends
2. **Database Connection**: Check MongoDB is running and connection string is correct
3. **Port Conflicts**: Ensure ports 5000, 5001, and 3000 are available
4. **Authentication**: Check JWT secrets are set correctly in .env files

## Future Enhancements

- Add image upload for products
- Implement real-time notifications
- Add more detailed analytics
- Implement role-based access control
- Add API documentation with Swagger