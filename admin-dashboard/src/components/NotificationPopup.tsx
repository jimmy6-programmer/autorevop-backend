import { useState, useEffect, useCallback } from 'react';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Bell, X, CheckCircle, AlertTriangle, Info, Clock, Loader2 } from 'lucide-react';
import { notificationsApi } from '@/lib/api';
import { toast } from 'sonner';

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

const getNotificationIcon = (type: string) => {
  switch (type) {
    case 'success':
      return <CheckCircle className="text-green-500" size={16} />;
    case 'warning':
      return <AlertTriangle className="text-yellow-500" size={16} />;
    case 'urgent':
      return <AlertTriangle className="text-red-500" size={16} />;
    default:
      return <Info className="text-blue-500" size={16} />;
  }
};

const getNotificationColor = (type: string) => {
  switch (type) {
    case 'success':
      return 'border-l-green-500 bg-green-50/50';
    case 'warning':
      return 'border-l-yellow-500 bg-yellow-50/50';
    case 'urgent':
      return 'border-l-red-500 bg-red-50/50';
    default:
      return 'border-l-blue-500 bg-blue-50/50';
  }
};

const getTimeAgo = (date: Date) => {
  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (diffInSeconds < 60) return `${diffInSeconds} sec ago`;
  if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} min ago`;
  if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} hour ago`;
  return `${Math.floor(diffInSeconds / 86400)} day ago`;
};

export default function NotificationPopup() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  const fetchNotifications = useCallback(async () => {
    try {
      setLoading(true);
      const data = await notificationsApi.getAll();
      setNotifications(data);
    } catch (err) {
      console.error('Error fetching notifications:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchUnreadCount = useCallback(async () => {
    try {
      const data = await notificationsApi.getUnreadCount();
      setUnreadCount(data.count);
    } catch (err) {
      console.error('Error fetching unread count:', err);
    }
  }, []);

  useEffect(() => {
    if (isOpen) {
      fetchNotifications();
    }
  }, [isOpen, fetchNotifications]);

  // Poll for unread count every 10 seconds
  useEffect(() => {
    fetchUnreadCount(); // Initial fetch
    const interval = setInterval(fetchUnreadCount, 10000); // Poll every 10 seconds
    return () => clearInterval(interval);
  }, [fetchUnreadCount]);

  const markAsRead = async (id: string) => {
    try {
      await notificationsApi.markAsRead(id);
      setNotifications(notifications.map(n =>
        n._id === id ? { ...n, read: true, readAt: new Date().toISOString() } : n
      ));
      setUnreadCount(prev => Math.max(0, prev - 1));
    } catch (err) {
      console.error('Error marking notification as read:', err);
      toast('Failed to mark notification as read');
    }
  };

  const markAllAsRead = async () => {
    try {
      await notificationsApi.markAllAsRead();
      setNotifications(notifications.map(n => ({ ...n, read: true, readAt: new Date().toISOString() })));
      setUnreadCount(0);
    } catch (err) {
      console.error('Error marking all notifications as read:', err);
      toast('Failed to mark all notifications as read');
    }
  };

  const deleteNotification = async (id: string) => {
    try {
      await notificationsApi.delete(id);
      setNotifications(notifications.filter(n => n._id !== id));
    } catch (err) {
      console.error('Error deleting notification:', err);
      toast('Failed to delete notification');
    }
  };

  return (
    <Popover open={isOpen} onOpenChange={setIsOpen}>
      <PopoverTrigger asChild>
        <Button variant="ghost" size="icon" className="relative">
          <Bell size={20} />
          {unreadCount > 0 && (
            <Badge className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center p-0 animate-pulse">
              {unreadCount}
            </Badge>
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-96 p-0 shadow-xl border-0 bg-white/95 backdrop-blur-sm" align="end">
        <div className="p-4 border-b border-slate-200">
          <div className="flex items-center justify-between">
            <h3 className="font-semibold text-lg">Notifications</h3>
            <div className="flex items-center space-x-2">
              {unreadCount > 0 && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={markAllAsRead}
                  className="text-xs text-blue-600 hover:text-blue-700"
                >
                  Mark all read
                </Button>
              )}
              <Badge variant="secondary" className="text-xs">
                {notifications.length}
              </Badge>
            </div>
          </div>
        </div>
        
        <div className="max-h-96 overflow-y-auto">
           {loading ? (
             <div className="p-8 text-center text-slate-500">
               <Loader2 size={24} className="mx-auto mb-4 animate-spin" />
               <p>Loading notifications...</p>
             </div>
           ) : notifications.length === 0 ? (
             <div className="p-8 text-center text-slate-500">
               <Bell size={48} className="mx-auto mb-4 text-slate-300" />
               <p>No notifications</p>
             </div>
           ) : (
             <div className="divide-y divide-slate-100">
               {notifications.slice(0, 10).map((notification) => {
                 const timeAgo = notification.createdAt
                   ? getTimeAgo(new Date(notification.createdAt))
                   : 'Unknown';

                 return (
                   <div
                     key={notification._id || `notification-${Math.random()}`}
                     className={`p-4 border-l-4 ${getNotificationColor(notification.type)} ${
                       !notification.read ? 'bg-slate-50/50' : ''
                     } hover:bg-slate-50 transition-colors group`}
                   >
                     <div className="flex items-start justify-between">
                       <div className="flex items-start space-x-3 flex-1">
                         {getNotificationIcon(notification.type)}
                         <div className="flex-1 min-w-0">
                           <div className="flex items-center space-x-2 mb-1">
                             <h4 className={`text-sm font-medium ${!notification.read ? 'text-slate-900' : 'text-slate-700'}`}>
                               {notification.title}
                             </h4>
                             {!notification.read && (
                               <div className="h-2 w-2 bg-blue-500 rounded-full"></div>
                             )}
                           </div>
                           <p className="text-sm text-slate-600 mb-2">{notification.message}</p>
                           <div className="flex items-center space-x-2">
                             <Clock size={12} className="text-slate-400" />
                             <span className="text-xs text-slate-500">{timeAgo}</span>
                           </div>
                         </div>
                       </div>
                       <div className="flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity">
                         {!notification.read && (
                           <Button
                             variant="ghost"
                             size="sm"
                             onClick={() => markAsRead(notification._id!)}
                             className="h-6 w-6 p-0 hover:bg-blue-100"
                           >
                             <CheckCircle size={12} className="text-blue-600" />
                           </Button>
                         )}
                         <Button
                           variant="ghost"
                           size="sm"
                           onClick={() => deleteNotification(notification._id!)}
                           className="h-6 w-6 p-0 hover:bg-red-100"
                         >
                           <X size={12} className="text-red-600" />
                         </Button>
                       </div>
                     </div>
                   </div>
                 );
               })}
             </div>
           )}
        </div>
        
        {notifications.length > 0 && (
          <div className="p-3 border-t border-slate-200 bg-slate-50/50">
            <Button variant="ghost" size="sm" className="w-full text-blue-600 hover:text-blue-700">
              View All Notifications
            </Button>
          </div>
        )}
      </PopoverContent>
    </Popover>
  );
}