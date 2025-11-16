import { useState, useEffect } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { TrendingUp, TrendingDown, Users, ClipboardList, Package, AlertTriangle } from 'lucide-react';
import { bookingsApi, usersApi, inventoryApi } from '@/lib/api';

interface StatCardProps {
  title: string;
  value: string | number;
  change?: number;
  icon: React.ReactNode;
  color: string;
}

function StatCard({ title, value, change, icon, color }: StatCardProps) {
  return (
    <Card className="relative overflow-hidden group hover:shadow-xl transition-all duration-300 hover:-translate-y-1 h-full">
      <div className={`absolute inset-0 bg-gradient-to-r ${color} opacity-5 group-hover:opacity-10 transition-opacity`}></div>
      <CardContent className="p-4 h-full flex flex-col justify-between">
        <div className="flex items-center justify-between mb-3">
          <div className="flex-1">
            <p className="text-xs font-medium text-slate-600 dark:text-slate-400 mb-1">
              {title}
            </p>
            <p className="text-2xl font-bold text-slate-900 dark:text-white">
              {value}
            </p>
          </div>
          <div className={`p-2 rounded-full bg-gradient-to-r ${color} shadow-lg flex-shrink-0`}>
            {icon}
          </div>
        </div>
        {change !== undefined && (
          <div className={`flex items-center text-xs ${
            change >= 0 ? 'text-green-600' : 'text-red-600'
          }`}>
            {change >= 0 ? <TrendingUp size={14} /> : <TrendingDown size={14} />}
            <span className="ml-1">
              {Math.abs(change)}% from last month
            </span>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

export default function StatsCards() {
  const [stats, setStats] = useState([
    {
      title: 'Total Bookings',
      value: 0,
      change: 0,
      icon: <ClipboardList className="text-white" size={24} />,
      color: 'from-blue-500 to-blue-600'
    },
    {
      title: 'Mechanic Services',
      value: 0,
      change: 0,
      icon: <span className="text-white text-xl">🔧</span>,
      color: 'from-green-500 to-green-600'
    },
    {
      title: 'Towing Services',
      value: 0,
      change: 0,
      icon: <span className="text-white text-xl">🚛</span>,
      color: 'from-orange-500 to-orange-600'
    },
    {
      title: 'Total Users',
      value: 0,
      change: 0,
      icon: <Users className="text-white" size={24} />,
      color: 'from-indigo-500 to-indigo-600'
    },
    {
      title: 'Inventory Value',
      value: '$0',
      change: 0,
      icon: <Package className="text-white" size={24} />,
      color: 'from-purple-500 to-purple-600'
    }
  ]);

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // Fetch all data in parallel
        const [bookingsResponse, usersResponse, inventoryResponse] = await Promise.all([
          bookingsApi.getAll(),
          usersApi.getAll(),
          inventoryApi.getAll()
        ]);

        console.log("StatsCards - Bookings response:", bookingsResponse);
        console.log("StatsCards - Users response:", usersResponse);
        console.log("StatsCards - Inventory response:", inventoryResponse);

        // Safe array normalization
        const safeBookings = Array.isArray(bookingsResponse?.data) ? bookingsResponse.data : [];
        const safeUsers = Array.isArray(usersResponse?.data) ? usersResponse.data : [];
        const safeInventory = Array.isArray(inventoryResponse?.data) ? inventoryResponse.data : [];

        // Calculate stats
        const totalBookings = safeBookings.length;
        const mechanicServices = safeBookings.filter(b => b.type === 'mechanic').length;
        const towingServices = safeBookings.filter(b => b.type === 'towing').length;
        const totalUsers = safeUsers.length;

        // Calculate inventory value
        const inventoryValue = safeInventory.reduce((total, item) => {
          return total + (item.quantity * item.price);
        }, 0);

        // For now, we'll use static change percentages since we don't have historical data
        // In a real app, you'd compare with previous month data
        setStats([
          {
            title: 'Total Bookings',
            value: totalBookings,
            change: 12.5, // Static for now
            icon: <ClipboardList className="text-white" size={24} />,
            color: 'from-blue-500 to-blue-600'
          },
          {
            title: 'Mechanic Services',
            value: mechanicServices,
            change: 15.2, // Static for now
            icon: <span className="text-white text-xl">🔧</span>,
            color: 'from-green-500 to-green-600'
          },
          {
            title: 'Towing Services',
            value: towingServices,
            change: 8.7, // Static for now
            icon: <span className="text-white text-xl">🚛</span>,
            color: 'from-orange-500 to-orange-600'
          },
          {
            title: 'Total Users',
            value: totalUsers,
            change: 5.8, // Static for now
            icon: <Users className="text-white" size={24} />,
            color: 'from-indigo-500 to-indigo-600'
          },
          {
            title: 'Inventory Value',
            value: `$${inventoryValue.toLocaleString()}`,
            change: 8.2, // Static for now
            icon: <Package className="text-white" size={24} />,
            color: 'from-purple-500 to-purple-600'
          }
        ]);
      } catch (error) {
        console.error('Error fetching stats:', error);
        // Keep default values on error
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 xl:grid-cols-5 gap-6 mb-8 items-stretch">
        {Array.from({ length: 5 }).map((_, index) => (
          <Card key={index} className="animate-pulse">
            <CardContent className="p-4 h-full flex flex-col justify-between">
              <div className="flex items-center justify-between mb-3">
                <div className="flex-1">
                  <div className="h-3 bg-gray-200 rounded mb-2"></div>
                  <div className="h-6 bg-gray-200 rounded"></div>
                </div>
                <div className="p-2 rounded-full bg-gray-200 flex-shrink-0">
                  <div className="w-6 h-6 bg-gray-300 rounded"></div>
                </div>
              </div>
              <div className="h-3 bg-gray-200 rounded w-24"></div>
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 xl:grid-cols-5 gap-6 mb-8 items-stretch">
      {stats.map((stat, index) => (
        <div
          key={stat.title}
          className="animate-in slide-in-from-bottom-4 fade-in"
          style={{ animationDelay: `${index * 100}ms` }}
        >
          <StatCard {...stat} />
        </div>
      ))}
    </div>
  );
}