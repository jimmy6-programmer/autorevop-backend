// Define interfaces based on your mock data
interface Booking {
  _id: string;
  type: 'mechanic' | 'towing';
  fullName: string;
  phoneNumber: string;
  vehicleBrand?: string;
  vehicleModel?: string;
  carPlateNumber?: string;
  issue?: string;
  serviceType?: string;
  location: string;
  pickupLocation?: string;
  totalPrice: string;
  mechanicId?: string;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt?: string;
  updatedAt?: string;
}


interface Inventory {
  id: string;
  name: string;
  category: string;
  quantity: number;
  price: number;
  supplier: string;
  description: string;
  image?: string;
  status: 'in-stock' | 'low-stock' | 'out-of-stock';
  lastUpdated: string;
}

export interface User {
  _id?: string;
  name: string;
  password?: string;
  role: 'admin' | 'mechanic' | 'customer';
  email: string;
  phone: string;
  country?: string;
  createdAt?: string;
}

interface Order {
  _id?: string;
  customerName: string;
  customerPhone: string;
  customerEmail?: string;
  items: Array<{
    productId: string;
    productName: string;
    quantity: number;
    price: number;
    total: number;
  }>;
  totalAmount: number;
  deliveryLocation: string;
  status: 'pending' | 'confirmed' | 'preparing' | 'shipped' | 'delivered' | 'cancelled';
  paymentMethod: 'cash' | 'card' | 'mobile_money';
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

interface Notification {
  _id?: string;
  type: 'success' | 'warning' | 'info' | 'urgent';
  title: string;
  message: string;
  relatedId?: string;
  relatedType?: 'order' | 'booking' | 'inventory' | 'user' | 'system';
  read: boolean;
  readAt?: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  createdAt?: string;
  updatedAt?: string;
}

// Define params types for query filtering
interface OrderParams {
  status?: string;
  startDate?: string;
  endDate?: string;
}


interface InventoryParams {
  status?: string;
  category?: string;
}


// Update API_BASE_URL to match backend port
const API_BASE_URL = 'https://autorevop-backend.onrender.com/api';

// Helper function to get auth headers
const getAuthHeaders = () => {
  const token = localStorage.getItem('adminToken');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};


// Bookings API
export const bookingsApi = {
  async getAll(): Promise<Booking[]> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout

    try {
      const response = await fetch(`${API_BASE_URL}/bookings`, {
        method: 'GET',
        headers: getAuthHeaders(),
        mode: 'cors',
        signal: controller.signal,
      });
      clearTimeout(timeoutId);
      if (!response.ok) throw new Error(`Failed to fetch bookings: ${response.statusText}`);
      return response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      if (error.name === 'AbortError') {
        throw new Error('Request timed out');
      }
      throw error;
    }
  },

  async getById(id: string): Promise<Booking> {
    const response = await fetch(`${API_BASE_URL}/bookings/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch booking: ${response.statusText}`);
    return response.json();
  },

  async create(booking: Booking): Promise<Booking> {
    const response = await fetch(`${API_BASE_URL}/bookings`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(booking),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to create booking: ${response.statusText}`);
    return response.json();
  },

  async update(id: string, booking: Partial<Booking>): Promise<Booking> {
    const response = await fetch(`${API_BASE_URL}/bookings/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(booking),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to update booking: ${response.statusText}`);
    return response.json();
  },

  async delete(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/bookings/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to delete booking: ${response.statusText}`);
  },

  async assignMechanic(id: string, mechanicId: string): Promise<Booking> {
    const response = await fetch(`${API_BASE_URL}/bookings/${id}/assign`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify({ mechanicId }),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to assign mechanic: ${response.statusText}`);
    return response.json();
  },
};

// Inventory API (using spare-parts endpoint)
export const inventoryApi = {
  async getAll(params?: InventoryParams): Promise<Inventory[]> {
    const query = new URLSearchParams(params as Record<string, string>).toString();
    const response = await fetch(`${API_BASE_URL}/spare-parts?${query}`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch inventory: ${response.statusText}`);
    return response.json();
  },

  async getById(id: string): Promise<Inventory> {
    const response = await fetch(`${API_BASE_URL}/spare-parts/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch inventory item: ${response.statusText}`);
    return response.json();
  },

  async create(item: Inventory): Promise<Inventory> {
    const response = await fetch(`${API_BASE_URL}/spare-parts`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(item),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to create inventory item: ${response.statusText}`);
    return response.json();
  },

  async update(id: string, item: Partial<Inventory>): Promise<Inventory> {
    const response = await fetch(`${API_BASE_URL}/spare-parts/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(item),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to update inventory item: ${response.statusText}`);
    return response.json();
  },

  async delete(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/spare-parts/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to delete inventory item: ${response.statusText}`);
  },

  async updateStock(id: string, quantityChange: number): Promise<Inventory> {
    const response = await fetch(`${API_BASE_URL}/spare-parts/${id}/stock`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify({ quantityChange }),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to update stock: ${response.statusText}`);
    return response.json();
  },
};


// Admin API
export const adminApi = {
  async login(email: string, password: string): Promise<{ token: string }> {
    const response = await fetch(`${API_BASE_URL}/admin/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to login: ${response.statusText}`);
    return response.json();
  },

  async getProfile(token: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/admin/profile`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch profile: ${response.statusText}`);
    return response.json();
  },
};

// Users API
export const usersApi = {
  async getAll(): Promise<User[]> {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch users: ${response.statusText}`);
    return response.json();
  },

  async getById(id: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/users/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch user: ${response.statusText}`);
    return response.json();
  },

  async create(user: User): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(user),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to create user: ${response.statusText}`);
    return response.json();
  },

  async update(id: string, user: Partial<User>): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/users/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(user),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to update user: ${response.statusText}`);
    return response.json();
  },

  async delete(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/users/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to delete user: ${response.statusText}`);
  },
};

// Orders API
export const ordersApi = {
  async getAll(): Promise<Order[]> {
    const response = await fetch(`${API_BASE_URL}/orders`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch orders: ${response.statusText}`);
    return response.json();
  },

  async getById(id: string): Promise<Order> {
    const response = await fetch(`${API_BASE_URL}/orders/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch order: ${response.statusText}`);
    return response.json();
  },

  async create(order: Order): Promise<Order> {
    const response = await fetch(`${API_BASE_URL}/orders`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(order),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to create order: ${response.statusText}`);
    return response.json();
  },

  async update(id: string, order: Partial<Order>): Promise<Order> {
    const response = await fetch(`${API_BASE_URL}/orders/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(order),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to update order: ${response.statusText}`);
    return response.json();
  },

  async delete(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/orders/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to delete order: ${response.statusText}`);
  },
};

// Notifications API
export const notificationsApi = {
  async getAll(): Promise<Notification[]> {
    const response = await fetch(`${API_BASE_URL}/notifications`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch notifications: ${response.statusText}`);
    return response.json();
  },

  async getUnreadCount(): Promise<{ count: number }> {
    const response = await fetch(`${API_BASE_URL}/notifications/unread-count`, {
      method: 'GET',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to fetch unread count: ${response.statusText}`);
    return response.json();
  },

  async markAsRead(id: string): Promise<Notification> {
    const response = await fetch(`${API_BASE_URL}/notifications/${id}/read`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to mark notification as read: ${response.statusText}`);
    return response.json();
  },

  async markAllAsRead(): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/notifications/mark-all-read`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to mark all notifications as read: ${response.statusText}`);
    return response.json();
  },

  async delete(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/notifications/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
      mode: 'cors',
    });
    if (!response.ok) throw new Error(`Failed to delete notification: ${response.statusText}`);
  },
};