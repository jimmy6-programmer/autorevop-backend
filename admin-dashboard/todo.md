# Vehicle Repair Admin Dashboard - MVP Implementation

## Core Features to Implement:
1. **Dashboard Overview** - Main stats and metrics
2. **Orders Management** - Track repair Orders and their status
3. **Mechanics Management** - Add/manage available mechanics
4. **Materials/Parts Inventory** - Manage stock and materials
5. **Modern UI/UX** - Animated, responsive design

## Files to Create/Modify:

### 1. src/pages/Index.tsx
- Main dashboard with overview cards
- Recent Orders summary
- Quick stats (total Orders, active mechanics, low stock alerts)

### 2. src/components/Layout.tsx
- Sidebar navigation
- Header with user info
- Responsive layout wrapper

### 3. src/components/OrdersTable.tsx
- Orders list with status tracking
- Filter and search functionality
- Status badges and actions

### 4. src/components/MechanicsCard.tsx
- Mechanics availability display
- Add new mechanic form
- Status indicators (available/busy/offline)

### 5. src/components/InventoryGrid.tsx
- Materials/parts inventory grid
- Stock level indicators
- Add new items functionality

### 6. src/components/StatsCards.tsx
- Animated statistics cards
- Key metrics display
- Trend indicators

### 7. src/lib/mockData.ts
- Sample data for Orders, mechanics, inventory
- Mock API responses for development

### 8. index.html
- Update title to "Vehicle Repair Admin Dashboard"

## Design Principles:
- Modern glassmorphism effects
- Smooth animations and transitions
- Dark/light mode support
- Mobile-responsive design
- Vibrant color scheme with gradients
- Interactive hover effects