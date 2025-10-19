import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';
import NotificationPopup from '@/components/NotificationPopup';
import {
  Home,
  ClipboardList,
  Users,
  Package,
  Menu,
  Settings,
  LogOut,
  ShoppingCartIcon,
  Bell,
  Wrench
} from 'lucide-react';

interface LayoutProps {
  children: React.ReactNode;
  activeTab: string;
  onTabChange: (tab: string) => void;
  onSignOut: () => void;
}

const sidebarItems = [
  { id: 'dashboard', label: 'Dashboard', icon: Home },
  { id: 'Bookings', label: 'Bookings', icon: ShoppingCartIcon },
  { id: 'orders', label: 'Orders', icon: ClipboardList },
  { id: 'notifications', label: 'Notifications', icon: Bell },
  { id: 'users', label: 'Users', icon: Users },
  { id: 'inventory', label: 'Inventory', icon: Package },
  { id: 'services', label: 'Services', icon: Wrench },
  { id: 'settings', label: 'Settings', icon: Settings },
];

export default function Layout({ children, activeTab, onTabChange, onSignOut }: LayoutProps) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const SidebarContent = () => (
    <div className="flex flex-col h-full bg-gradient-to-b from-slate-900 to-slate-800 text-white">
      <div className="p-6 border-b border-slate-700">
        <h2 className="text-xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
          <img src="/ic_launcher.png" className="w-20 h-20 mb-1 object-contain mx-auto" alt="Auto RevOp Logo" /> <p className='ml-9'>Auto RevOp</p>
        </h2>
      </div>
      
      <nav className="flex-1 p-4 space-y-2">
        {sidebarItems.map((item) => {
          const Icon = item.icon;
          return (
            <button
              key={item.id}
              onClick={() => {
                onTabChange(item.id);
                setIsMobileMenuOpen(false);
              }}
              className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-all duration-200 hover:bg-slate-700/50 ${
                activeTab === item.id 
                  ? 'bg-gradient-to-r from-blue-600 to-purple-600 shadow-lg' 
                  : 'hover:translate-x-1'
              }`}
            >
              <Icon size={20} />
              <span className="font-medium">{item.label}</span>
            </button>
          );
        })}
      </nav>
      
      <div className="p-4 border-t border-slate-700 space-y-2">
        <Button 
          onClick={onSignOut}
          variant="ghost" 
          className="w-full justify-start text-white hover:bg-slate-700/50"
        >
          <LogOut size={20} className="mr-3 text-red-600" />
          <p className='text-red-600'>Logout</p>
        </Button>
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-gradient-to-br from-slate-50 to-blue-50 dark:from-slate-900 dark:to-slate-800">
      {/* Desktop Sidebar */}
      <div className="hidden lg:block w-64 shadow-xl">
        <SidebarContent />
      </div>

      {/* Mobile Sidebar */}
      <Sheet open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
        <SheetContent side="left" className="p-0 w-64">
          <SidebarContent />
        </SheetContent>
      </Sheet>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-md border-b border-slate-200 dark:border-slate-700 px-6 py-4 shadow-sm">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Sheet>
                <SheetTrigger asChild>
                  <Button variant="ghost" size="icon" className="lg:hidden">
                    <Menu size={20} />
                  </Button>
                </SheetTrigger>
                <SheetContent side="left" className="p-0 w-64">
                  <SidebarContent />
                </SheetContent>
              </Sheet>
              
              <h1 className="text-2xl font-bold text-slate-800 dark:text-white capitalize">
                {activeTab}
              </h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <NotificationPopup />
              
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-semibold">
                  A
                </div>
                <span className="hidden sm:block text-sm font-medium text-slate-700 dark:text-slate-300">
                  Admin User
                </span>
              </div>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}