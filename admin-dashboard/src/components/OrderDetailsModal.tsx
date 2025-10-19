import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Separator } from '@/components/ui/separator';
import { Calendar, Car, User, Phone, Mail, DollarSign, Save, Plus, Trash2 } from 'lucide-react';

interface OrderItem {
  productId: string;
  productName: string;
  quantity: number;
  price: number;
  total: number;
}

interface Order {
  _id?: string;
  customerName: string;
  customerPhone: string;
  customerEmail?: string;
  items: OrderItem[];
  totalAmount: number;
  deliveryLocation: string;
  status: 'pending' | 'confirmed' | 'preparing' | 'shipped' | 'delivered' | 'cancelled';
  paymentMethod: 'cash' | 'card' | 'mobile_money';
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

interface OrderDetailsModalProps {
  order: Order | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (order: Order) => void;
  onDelete: (orderId: string) => void;
  mode: 'view' | 'edit' | 'add';
}

export default function OrderDetailsModal({ order, isOpen, onClose, onSave, onDelete, mode }: OrderDetailsModalProps) {
  const [editedOrder, setEditedOrder] = useState<Order>({
    customerName: '',
    customerPhone: '',
    customerEmail: '',
    items: [],
    totalAmount: 0,
    deliveryLocation: '',
    status: 'pending',
    paymentMethod: 'cash',
    notes: '',
  });

  useEffect(() => {
    if (order) {
      setEditedOrder({ ...order });
    } else if (mode === 'add') {
      setEditedOrder({
        customerName: '',
        customerPhone: '',
        customerEmail: '',
        items: [{ productId: '', productName: '', quantity: 1, price: 0, total: 0 }],
        totalAmount: 0,
        deliveryLocation: '',
        status: 'pending',
        paymentMethod: 'cash',
        notes: '',
      });
    }
  }, [order, mode]);

  const handleSave = () => {
    // Basic validation
    if (!editedOrder.customerName || !editedOrder.customerPhone || !editedOrder.deliveryLocation) {
      alert('Please fill in customer name, phone, and delivery location.');
      return;
    }

    // Validate items
    if (editedOrder.items.length === 0) {
      alert('Please add at least one item to the order.');
      return;
    }

    // Validate each item has required fields
    for (let i = 0; i < editedOrder.items.length; i++) {
      const item = editedOrder.items[i];
      if (!item.productName || item.quantity <= 0 || item.price < 0) {
        alert(`Item ${i + 1}: Please provide a valid product name, quantity > 0, and price >= 0.`);
        return;
      }
    }

    onSave(editedOrder);
    onClose();
  };

  const handleDelete = () => {
    if (confirm('Are you sure you want to delete this order?')) {
      onDelete(editedOrder._id!);
      onClose();
    }
  };

  const addItem = () => {
    setEditedOrder({
      ...editedOrder,
      items: [...editedOrder.items, { productId: '', productName: '', quantity: 1, price: 0, total: 0 }]
    });
  };

  const removeItem = (index: number) => {
    const newItems = editedOrder.items.filter((_, i) => i !== index);
    const newTotal = newItems.reduce((sum, item) => sum + item.total, 0);
    setEditedOrder({
      ...editedOrder,
      items: newItems,
      totalAmount: newTotal
    });
  };

  const updateItem = (index: number, field: keyof OrderItem, value: string | number) => {
    const newItems = [...editedOrder.items];
    newItems[index] = { ...newItems[index], [field]: value };

    if (field === 'quantity' || field === 'price') {
      newItems[index].total = newItems[index].quantity * newItems[index].price;
    }

    const newTotal = newItems.reduce((sum, item) => sum + item.total, 0);

    setEditedOrder({
      ...editedOrder,
      items: newItems,
      totalAmount: newTotal
    });
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto p-6 rounded-lg bg-white shadow-lg" aria-describedby=''>
        <DialogHeader>
          <DialogTitle className="flex items-center justify-between text-xl font-bold text-gray-800">
            <div className="flex items-center space-x-2">
              <Car className="text-blue-600" size={24} />
              <span>{mode === 'add' ? 'Add New Order' : `Order Details - ${editedOrder._id?.slice(-8) || 'N/A'}`}</span>
            </div>
            {mode !== 'add' && (
              <Button onClick={handleDelete} variant="destructive" size="sm">
                Delete
              </Button>
            )}
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* Customer Information */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <h3 className="text-lg font-semibold flex items-center space-x-2 text-gray-700 mb-4">
              <User className="text-green-600" size={20} />
              <span>Customer Information</span>
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <Label className="text-sm font-medium text-gray-600">Customer Name *</Label>
                <Input
                  value={editedOrder.customerName}
                  onChange={(e) => setEditedOrder({ ...editedOrder, customerName: e.target.value })}
                  className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                  placeholder="Enter customer name"
                />
              </div>
              <div>
                <Label className="flex items-center space-x-1 text-sm font-medium text-gray-600">
                  <Phone size={14} />
                  <span>Phone Number *</span>
                </Label>
                <Input
                  value={editedOrder.customerPhone}
                  onChange={(e) => setEditedOrder({ ...editedOrder, customerPhone: e.target.value })}
                  className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                  placeholder="Enter phone number"
                />
              </div>
              <div>
                <Label className="flex items-center space-x-1 text-sm font-medium text-gray-600">
                  <Mail size={14} />
                  <span>Email</span>
                </Label>
                <Input
                  value={editedOrder.customerEmail || ''}
                  onChange={(e) => setEditedOrder({ ...editedOrder, customerEmail: e.target.value })}
                  className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                  placeholder="Enter email (optional)"
                />
              </div>
            </div>
          </div>

          {/* Order Items */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold flex items-center space-x-2 text-gray-700">
                <Car className="text-blue-600" size={20} />
                <span>Order Items</span>
              </h3>
              <Button onClick={addItem} size="sm" className="bg-blue-600 hover:bg-blue-700">
                <Plus size={14} className="mr-1" />
                Add Item
              </Button>
            </div>
            <div className="space-y-3">
              {editedOrder.items.map((item, index) => (
                <div key={index} className="flex items-center space-x-2 p-3 bg-white rounded border">
                  <div className="flex-1">
                    <Input
                      placeholder="Product name"
                      value={item.productName}
                      onChange={(e) => updateItem(index, 'productName', e.target.value)}
                    />
                  </div>
                  <div className="w-20">
                    <Input
                      type="number"
                      placeholder="Qty"
                      value={item.quantity}
                      onChange={(e) => updateItem(index, 'quantity', parseInt(e.target.value) || 1)}
                    />
                  </div>
                  <div className="w-24">
                    <Input
                      type="number"
                      placeholder="Price"
                      value={item.price}
                      onChange={(e) => updateItem(index, 'price', parseFloat(e.target.value) || 0)}
                    />
                  </div>
                  <div className="w-20 text-center font-medium">
                    ${item.total.toFixed(2)}
                  </div>
                  <Button
                    onClick={() => removeItem(index)}
                    variant="ghost"
                    size="sm"
                    className="text-red-600 hover:text-red-700"
                  >
                    <Trash2 size={14} />
                  </Button>
                </div>
              ))}
            </div>
          </div>

          {/* Order Details */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4 bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold text-gray-700">Order Details</h3>
              <div className="space-y-3">
                <div>
                  <Label className="text-sm font-medium text-gray-600">Delivery Location *</Label>
                  <Input
                    value={editedOrder.deliveryLocation}
                    onChange={(e) => setEditedOrder({ ...editedOrder, deliveryLocation: e.target.value })}
                    className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                    placeholder="Enter delivery location"
                  />
                </div>
                <div>
                  <Label className="text-sm font-medium text-gray-600">Payment Method</Label>
                  <Select
                    value={editedOrder.paymentMethod}
                    onValueChange={(value: 'cash' | 'card' | 'mobile_money') =>
                      setEditedOrder({ ...editedOrder, paymentMethod: value })
                    }
                  >
                    <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                      <SelectValue placeholder="Select payment method" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="cash">Cash</SelectItem>
                      <SelectItem value="card">Card</SelectItem>
                      <SelectItem value="mobile_money">Mobile Money</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label className="text-sm font-medium text-gray-600">Notes</Label>
                  <Input
                    value={editedOrder.notes || ''}
                    onChange={(e) => setEditedOrder({ ...editedOrder, notes: e.target.value })}
                    className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                    placeholder="Additional notes (optional)"
                  />
                </div>
              </div>
            </div>

            <div className="space-y-4 bg-gray-50 p-4 rounded-lg">
              <h3 className="text-lg font-semibold text-gray-700">Order Status</h3>
              <div className="space-y-3">
                <div>
                  <Label className="text-sm font-medium text-gray-600">Status</Label>
                  <Select
                    value={editedOrder.status}
                    onValueChange={(value: Order['status']) =>
                      setEditedOrder({ ...editedOrder, status: value })
                    }
                  >
                    <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                      <SelectValue placeholder="Select status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="pending">Pending</SelectItem>
                      <SelectItem value="confirmed">Confirmed</SelectItem>
                      <SelectItem value="preparing">Preparing</SelectItem>
                      <SelectItem value="shipped">Shipped</SelectItem>
                      <SelectItem value="delivered">Delivered</SelectItem>
                      <SelectItem value="cancelled">Cancelled</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="p-3 bg-white rounded border">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Total Amount:</span>
                    <span className="text-lg font-bold text-green-600">${editedOrder.totalAmount.toFixed(2)}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Footer with Save Button */}
          <div className="bg-gray-50 p-4 rounded-lg flex justify-end">
            <Button
              onClick={handleSave}
              size="sm"
              className="bg-green-600 hover:bg-green-700 text-white transition-colors"
            >
              <Save size={16} className="mr-1" />
              Save
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}