import { useState, useEffect, useCallback, useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Search, Eye, Trash2, CheckCircle, X, Loader2, Filter } from 'lucide-react';
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

const typeColors = {
  success: 'bg-green-100 text-green-800 border-green-200',
  warning: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  info: 'bg-blue-100 text-blue-800 border-blue-200',
  urgent: 'bg-red-100 text-red-800 border-red-200'
};

const priorityColors = {
  low: 'bg-gray-100 text-gray-800 border-gray-200',
  medium: 'bg-blue-100 text-blue-800 border-blue-200',
  high: 'bg-orange-100 text-orange-800 border-orange-200',
  urgent: 'bg-red-100 text-red-800 border-red-200'
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [readFilter, setReadFilter] = useState('all');

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = useCallback(async () => {
    try {
      setLoading(true);
      const data = await notificationsApi.getAll();
      setNotifications(data);
      setError(null);
    } catch (err) {
      setError('Failed to load notifications');
      console.error('Error fetching notifications:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  const filteredNotifications = useMemo(() => {
    return notifications.filter(notification => {
      const matchesSearch = (notification.title?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
                           (notification.message?.toLowerCase() || '').includes(searchTerm.toLowerCase());
      const matchesType = typeFilter === 'all' || notification.type === typeFilter;
      const matchesRead = readFilter === 'all' ||
                         (readFilter === 'read' && notification.read) ||
                         (readFilter === 'unread' && !notification.read);
      return matchesSearch && matchesType && matchesRead;
    });
  }, [notifications, searchTerm, typeFilter, readFilter]);

  const handleMarkAsRead = async (id: string) => {
    try {
      await notificationsApi.markAsRead(id);
      setNotifications(notifications.map(n =>
        n._id === id ? { ...n, read: true, readAt: new Date().toISOString() } : n
      ));
      toast('Notification marked as read');
    } catch (err) {
      console.error('Error marking notification as read:', err);
      toast('Failed to mark notification as read');
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await notificationsApi.markAllAsRead();
      setNotifications(notifications.map(n => ({ ...n, read: true, readAt: new Date().toISOString() })));
      toast('All notifications marked as read');
    } catch (err) {
      console.error('Error marking all notifications as read:', err);
      toast('Failed to mark all notifications as read');
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await notificationsApi.delete(id);
      setNotifications(notifications.filter(n => n._id !== id));
      toast('Notification deleted');
    } catch (err) {
      console.error('Error deleting notification:', err);
      toast('Failed to delete notification');
    }
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <div className="w-full animate-in slide-in-from-bottom-4 fade-in">
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardHeader>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
            <CardTitle className="flex items-center space-x-2">
              <span className="text-xl font-bold">Notifications</span>
              <Badge variant="secondary" className="ml-2">
                {filteredNotifications.length}
              </Badge>
              {unreadCount > 0 && (
                <Badge variant="destructive" className="ml-2">
                  {unreadCount} unread
                </Badge>
              )}
            </CardTitle>

            <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                <Input
                  placeholder="Search notifications..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 w-full sm:w-64"
                />
              </div>

              <Select value={typeFilter} onValueChange={setTypeFilter}>
                <SelectTrigger className="w-full sm:w-32">
                  <Filter size={16} className="mr-2" />
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Types</SelectItem>
                  <SelectItem value="success">Success</SelectItem>
                  <SelectItem value="warning">Warning</SelectItem>
                  <SelectItem value="info">Info</SelectItem>
                  <SelectItem value="urgent">Urgent</SelectItem>
                </SelectContent>
              </Select>

              <Select value={readFilter} onValueChange={setReadFilter}>
                <SelectTrigger className="w-full sm:w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="read">Read</SelectItem>
                  <SelectItem value="unread">Unread</SelectItem>
                </SelectContent>
              </Select>

              {unreadCount > 0 && (
                <Button onClick={handleMarkAllAsRead} variant="outline">
                  <CheckCircle size={16} className="mr-2" />
                  Mark All Read
                </Button>
              )}
            </div>
          </div>
        </CardHeader>

        <CardContent>
          {loading && (
            <div className="flex justify-center items-center py-12">
              <Loader2 className="h-8 w-8 animate-spin" />
              <span className="ml-2">Loading notifications...</span>
            </div>
          )}
          {error && (
            <div className="text-center py-12">
              <p className="text-red-600">{error}</p>
              <Button onClick={fetchNotifications} className="mt-4">
                Try Again
              </Button>
            </div>
          )}
          {!loading && !error && (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Type</TableHead>
                    <TableHead>Title</TableHead>
                    <TableHead className="hidden md:table-cell">Message</TableHead>
                    <TableHead className="hidden sm:table-cell">Priority</TableHead>
                    <TableHead className="hidden lg:table-cell">Status</TableHead>
                    <TableHead className="hidden xl:table-cell">Created Date</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredNotifications.map((notification) => (
                    <TableRow key={notification._id || `notification-${Math.random()}`} className="hover:bg-slate-50 transition-colors">
                      <TableCell>
                        <Badge className={typeColors[notification.type] || typeColors.info}>
                          {notification.type}
                        </Badge>
                      </TableCell>
                      <TableCell className="font-medium">{notification.title}</TableCell>
                      <TableCell className="hidden md:table-cell max-w-xs truncate">{notification.message}</TableCell>
                      <TableCell className="hidden sm:table-cell">
                        <Badge className={priorityColors[notification.priority] || priorityColors.medium}>
                          {notification.priority}
                        </Badge>
                      </TableCell>
                      <TableCell className="hidden lg:table-cell">
                        <Badge variant={notification.read ? "secondary" : "default"}>
                          {notification.read ? 'Read' : 'Unread'}
                        </Badge>
                      </TableCell>
                      <TableCell className="hidden xl:table-cell">
                        {notification.createdAt ? new Date(notification.createdAt).toLocaleDateString() : '-'}
                      </TableCell>
                      <TableCell>
                        <div className="flex space-x-1">
                          {!notification.read && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleMarkAsRead(notification._id!)}
                              className="h-8 w-8 p-0 hover:bg-blue-100"
                              title="Mark as read"
                            >
                              <CheckCircle size={14} className="text-blue-600" />
                            </Button>
                          )}
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(notification._id!)}
                            className="h-8 w-8 p-0 hover:bg-red-100"
                            title="Delete notification"
                          >
                            <X size={14} className="text-red-600" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {filteredNotifications.length === 0 && (
                <div className="text-center py-12">
                  <div className="text-slate-400 mb-4">
                    <Search size={48} className="mx-auto" />
                  </div>
                  <p className="text-slate-600">No notifications found matching your criteria</p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}