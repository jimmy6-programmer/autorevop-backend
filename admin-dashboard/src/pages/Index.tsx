import { useState } from 'react';
import Layout from '@/components/Layout';
import StatsCards from '@/components/StatsCards';
import BookingsPage from '@/components/BookingsPage';
import OrdersPage from '@/components/OrdersPage';
import NotificationsPage from '@/components/NotificationsPage';
import UsersPage from '@/components/UsersPage';
import InventoryGrid from '@/components/InventoryGrid';
import ServicesPage from '@/components/ServicesPage';
import SettingsPage from '@/components/SettingsPage';
import SignInPage from '@/components/SignInPage';

export default function Index() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleSignIn = (credentials: { email: string; password: string }) => {
    // Authentication is handled in SignInPage component
    setIsAuthenticated(true);
  };

  const handleSignOut = () => {
    localStorage.removeItem('adminToken');
    setIsAuthenticated(false);
    setActiveTab('dashboard');
  };

  if (!isAuthenticated) {
    return <SignInPage onSignIn={handleSignIn} />;
  }

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return (
          <div className="w-full max-w-full space-y-8">
            <div className="animate-in slide-in-from-top-4 fade-in">
              <h2 className="text-3xl font-bold text-slate-800 mb-2">
                Welcome back, Admin! 👋
              </h2>
              <p className="text-slate-600 mb-8">
                Here's what's happening with your repair service today.
              </p>
            </div>
            
            <StatsCards />

            {/* Full width Bookings table - takes entire row */}
            <div className="w-full">
              <BookingsPage />
            </div>
          </div>
        );
      
      case 'Bookings':
        return (
          <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
            <BookingsPage />
          </div>
        );

      case 'orders':
        return (
          <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
            <OrdersPage />
          </div>
        );

      case 'notifications':
        return (
          <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
            <NotificationsPage />
          </div>
        );

      case 'users':
        return (
          <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
            <UsersPage />
          </div>
        );

      case 'inventory':
        return (
          <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
            <InventoryGrid />
          </div>
        );

      case 'services':
        return (
          <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
            <ServicesPage />
          </div>
        );

      case 'settings':
        return <SettingsPage />;
      
      default:
        return (
          <div className="text-center py-12">
            <h2 className="text-2xl font-bold text-slate-800 mb-4">Page Not Found</h2>
            <p className="text-slate-600">The requested page could not be found.</p>
          </div>
        );
    }
  };

  return (
    <Layout activeTab={activeTab} onTabChange={setActiveTab} onSignOut={handleSignOut}>
      <div className="w-full max-w-full">
        {renderContent()}
      </div>
    </Layout>
  );
}