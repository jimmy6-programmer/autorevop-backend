import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import OrderDetailsModal from '@/components/OrderDetailsModal';
import { Search, Eye, Edit, Trash2, Plus, Filter, Loader2 } from 'lucide-react';
import { ordersApi } from '@/lib/api';

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

const statusColors = {
  pending: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  confirmed: 'bg-blue-100 text-blue-800 border-blue-200',
  preparing: 'bg-orange-100 text-orange-800 border-orange-200',
  shipped: 'bg-purple-100 text-purple-800 border-purple-200',
  delivered: 'bg-green-100 text-green-800 border-green-200',
  cancelled: 'bg-red-100 text-red-800 border-red-200'
};

export default function OrdersTable() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit' | 'add'>('view');
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const data = await ordersApi.getAll();
      setOrders(data);
      setError(null);
    } catch (err) {
      setError('Failed to load orders');
      console.error('Error fetching orders:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredOrders = orders.filter(order => {
    const matchesSearch = (order.customerName?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
                          (order.customerPhone?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
                          (order.deliveryLocation?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
                          order.items.some(item => item.productName?.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesStatus = statusFilter === 'all' || order.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const handleView = (order: Order) => {
    setSelectedOrder(order);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEdit = (order: Order) => {
    setSelectedOrder(order);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setSelectedOrder(null);
    setModalMode('add');
    setIsModalOpen(true);
  };

  const handleSave = async (updatedOrder: Order) => {
    try {
      if (modalMode === 'add') {
        await ordersApi.create(updatedOrder);
      } else {
        // Remove _id from the update object as it's immutable in MongoDB
        const { _id, ...orderData } = updatedOrder;
        await ordersApi.update(_id!, orderData);
      }
      await fetchOrders(); // Refresh the list
      setIsModalOpen(false); // Close modal on success
    } catch (err) {
      console.error('Error saving order:', err);
      // Show more specific error message
      const errorMessage = err instanceof Error ? err.message : 'Failed to save order';
      alert(`Error: ${errorMessage}`);
    }
  };

  const handleDelete = async (orderId: string) => {
    try {
      await ordersApi.delete(orderId);
      await fetchOrders(); // Refresh the list
    } catch (err) {
      console.error('Error deleting order:', err);
      alert('Failed to delete order');
    }
  };

  return (
    <>
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm animate-in slide-in-from-bottom-4 fade-in">
        <CardHeader>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
            <CardTitle className="flex items-center space-x-2">
              <span className="text-xl font-bold">Recent Orders</span>
              <Badge variant="secondary" className="ml-2">
                {filteredOrders.length}
              </Badge>
            </CardTitle>
            
            <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                <Input
                  placeholder="Search Orders..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 w-full sm:w-64"
                />
              </div>
              
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-full sm:w-40">
                  <Filter size={16} className="mr-2" />
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="pending">Pending</SelectItem>
                  <SelectItem value="confirmed">Confirmed</SelectItem>
                  <SelectItem value="preparing">Preparing</SelectItem>
                  <SelectItem value="shipped">Shipped</SelectItem>
                  <SelectItem value="delivered">Delivered</SelectItem>
                  <SelectItem value="cancelled">Cancelled</SelectItem>
                </SelectContent>
              </Select>

              <Button onClick={handleAdd} className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700">
                <Plus size={16} className="mr-2" />
                Add Order
              </Button>
            </div>
          </div>
        </CardHeader>
        
        <CardContent>
          {loading && (
            <div className="flex justify-center items-center py-12">
              <Loader2 className="h-8 w-8 animate-spin" />
              <span className="ml-2">Loading orders...</span>
            </div>
          )}
          {error && (
            <div className="text-center py-12">
              <p className="text-red-600">{error}</p>
              <Button onClick={fetchOrders} className="mt-4">
                Try Again
              </Button>
            </div>
          )}
          {!loading && !error && (
            <div className="overflow-x-auto">
              <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Order ID</TableHead>
                  <TableHead>Customer Name</TableHead>
                  <TableHead className="hidden md:table-cell">Items</TableHead>
                  <TableHead className="hidden lg:table-cell">Phone</TableHead>
                  <TableHead className="hidden sm:table-cell">Delivery Location</TableHead>
                  <TableHead className="hidden lg:table-cell">Status</TableHead>
                  <TableHead className="hidden xl:table-cell">Total Amount</TableHead>
                  <TableHead className="hidden xl:table-cell">Created Date</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredOrders.map((order) => (
                  <TableRow key={order._id || `order-${Math.random()}`} className="hover:bg-slate-50 transition-colors">
                    <TableCell className="font-medium">{order._id?.slice(-8) || 'N/A'}</TableCell>
                    <TableCell>{order.customerName || '-'}</TableCell>
                    <TableCell className="hidden md:table-cell">
                      {order.items.length > 0
                        ? `${order.items[0].productName}${order.items.length > 1 ? ` (+${order.items.length - 1} more)` : ''}`
                        : '-'
                      }
                    </TableCell>
                    <TableCell className="hidden lg:table-cell">{order.customerPhone || '-'}</TableCell>
                    <TableCell className="hidden sm:table-cell">{order.deliveryLocation || '-'}</TableCell>
                    <TableCell className="hidden lg:table-cell">
                      <Badge className={statusColors[order.status] || statusColors.pending}>
                        {order.status?.replace('-', ' ') || 'pending'}
                      </Badge>
                    </TableCell>
                    <TableCell className="hidden xl:table-cell">${order.totalAmount || 0}</TableCell>
                    <TableCell className="hidden xl:table-cell">
                      {order.createdAt ? new Date(order.createdAt).toLocaleDateString() : '-'}
                    </TableCell>
                    <TableCell>
                      <div className="flex space-x-1">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleView(order)}
                          className="h-8 w-8 p-0 hover:bg-blue-100"
                        >
                          <Eye size={14} className="text-blue-600" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleEdit(order)}
                          className="h-8 w-8 p-0 hover:bg-green-100"
                        >
                          <Edit size={14} className="text-green-600" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(order._id!)}
                          className="h-8 w-8 p-0 hover:bg-red-100"
                        >
                          <Trash2 size={14} className="text-red-600" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            
             {filteredOrders.length === 0 && (
               <div className="text-center py-12">
                 <div className="text-slate-400 mb-4">
                   <Search size={48} className="mx-auto" />
                 </div>
                 <p className="text-slate-600">No Orders found matching your criteria</p>
               </div>
             )}
           </div>
         )}
       </CardContent>
      </Card>

      <OrderDetailsModal
        order={selectedOrder}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSave}
        onDelete={handleDelete}
        mode={modalMode}
      />
    </>
  );
}