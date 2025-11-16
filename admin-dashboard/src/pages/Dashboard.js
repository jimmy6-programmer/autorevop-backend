import { useEffect, useState } from 'react';
import { usersAPI, bookingsAPI, sparePartsAPI } from '../services/api';
import './Dashboard.css';

const Dashboard = () => {
  const [stats, setStats] = useState({
    users: 0,
    bookings: 0,
    products: 0,
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [users, bookings, products] = await Promise.all([
          usersAPI.getUsers(),
          bookingsAPI.getBookings(),
          sparePartsAPI.getSpareParts(),
        ]);

        console.log("Users response:", users);
        console.log("Bookings response:", bookings);
        console.log("Products response:", products);

        const safeUsers = Array.isArray(users?.data) ? users.data : [];
        const safeBookings = Array.isArray(bookings?.data) ? bookings.data : [];
        const safeProducts = Array.isArray(products?.data) ? products.data : [];

        setStats({
          users: safeUsers.length,
          bookings: safeBookings.length,
          products: safeProducts.length,
        });
      } catch (error) {
        console.error('Error fetching stats:', error);
      }
    };
    fetchStats();
  }, []);

  return (
    <div className="dashboard">
      <h1>Dashboard Overview</h1>
      <div className="stats">
        <div className="stat-card">
          <h3>Total Users</h3>
          <p>{stats.users}</p>
        </div>
        <div className="stat-card">
          <h3>Total Bookings</h3>
          <p>{stats.bookings}</p>
        </div>
        <div className="stat-card">
          <h3>Total Products</h3>
          <p>{stats.products}</p>
        </div>
        <div className="stat-card">
          <h3>Revenue</h3>
          <p>$12,450</p>
        </div>
      </div>
      <div className="dashboard-grid">
        <div className="chart-card">
          <h3>User Growth</h3>
          <div className="chart-placeholder">📈 Chart will be implemented here</div>
        </div>
        <div className="chart-card">
          <h3>Recent Bookings</h3>
          <div className="chart-placeholder">📊 Recent activity chart</div>
        </div>
        <div className="chart-card">
          <h3>Product Performance</h3>
          <div className="chart-placeholder">📉 Performance metrics</div>
        </div>
        <div className="chart-card">
          <h3>System Status</h3>
          <div className="chart-placeholder">✅ All systems operational</div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
