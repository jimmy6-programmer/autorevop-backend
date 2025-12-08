import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Package, Save, X, DollarSign, Hash } from 'lucide-react';

interface InventoryItem {
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

interface InventoryEditModalProps {
  item: InventoryItem | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (item: InventoryItem) => void;
  onDelete: (itemId: string) => void;
  mode: 'view' | 'edit' | 'add';
}

const statusColors = {
  'in-stock': 'bg-green-100 text-green-800 border-green-200',
  'low-stock': 'bg-yellow-100 text-yellow-800 border-yellow-200',
  'out-of-stock': 'bg-red-100 text-red-800 border-red-200'
};

export default function InventoryEditModal({ 
  item, 
  isOpen, 
  onClose, 
  onSave, 
  onDelete, 
  mode 
}: InventoryEditModalProps) {
  const [editedItem, setEditedItem] = useState<InventoryItem | null>(null);
  const [isEditing, setIsEditing] = useState(mode === 'edit' || mode === 'add');

  useEffect(() => {
    if (item) {
      setEditedItem({ ...item });
    } else if (mode === 'add') {
      setEditedItem({
        id: `INV-${Date.now()}`,
        name: '',
        category: '',
        quantity: 0,
        price: 0,
        supplier: '',
        description: '',
        image: '',
        status: 'in-stock',
        lastUpdated: new Date().toISOString().split('T')[0]
      });
    }
    setIsEditing(mode === 'edit' || mode === 'add');
  }, [item, mode]);

  if (!editedItem) return null;

  const handleSave = () => {
    // Auto-update status based on quantity
    let status: 'in-stock' | 'low-stock' | 'out-of-stock' = 'in-stock';
    if (editedItem.quantity === 0) {
      status = 'out-of-stock';
    } else if (editedItem.quantity <= 10) {
      status = 'low-stock';
    }

    const updatedItem = {
      ...editedItem,
      status,
      lastUpdated: new Date().toISOString().split('T')[0]
    };

    onSave(updatedItem);
    setIsEditing(false);
    onClose();
  };

  const handleDelete = () => {
    if (confirm('Are you sure you want to delete this inventory item?')) {
      onDelete(editedItem.id);
      onClose();
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center justify-between">
            <span className="flex items-center space-x-2">
              <Package className="text-blue-600" size={24} />
              <span>{mode === 'add' ? 'Add New Item' : `Inventory Item - ${editedItem.name}`}</span>
            </span>
            <div className="flex items-center space-x-2">
              {!isEditing ? (
                <Button onClick={() => setIsEditing(true)} size="sm">
                  Edit Item
                </Button>
              ) : (
                <div className="flex space-x-2">
                  <Button onClick={handleSave} size="sm" className="bg-green-600 hover:bg-green-700">
                    <Save size={16} className="mr-1" />
                    Save
                  </Button>
                  <Button onClick={() => setIsEditing(false)} variant="outline" size="sm">
                    <X size={16} className="mr-1" />
                    Cancel
                  </Button>
                </div>
              )}
              {mode !== 'add' && (
                <Button onClick={handleDelete} variant="destructive" size="sm">
                  Delete
                </Button>
              )}
            </div>
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* Basic Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label>Item Name</Label>
              {isEditing ? (
                <Input
                  value={editedItem.name}
                  onChange={(e) => setEditedItem({ ...editedItem, name: e.target.value })}
                  className="mt-1"
                  placeholder="Enter item name"
                />
              ) : (
                <p className="mt-1 p-2 bg-slate-50 rounded">{editedItem.name}</p>
              )}
            </div>

            <div>
              <Label>Category</Label>
              {isEditing ? (
                <Select value={editedItem.category} onValueChange={(value) => setEditedItem({ ...editedItem, category: value })}>
                  <SelectTrigger className="mt-1">
                    <SelectValue placeholder="Select category" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Engine Parts">Engine Parts</SelectItem>
                    <SelectItem value="Brake System">Brake System</SelectItem>
                    <SelectItem value="Electrical">Electrical</SelectItem>
                    <SelectItem value="Transmission">Transmission</SelectItem>
                    <SelectItem value="Suspension">Suspension</SelectItem>
                    <SelectItem value="Tools">Tools</SelectItem>
                    <SelectItem value="Fluids">Fluids</SelectItem>
                    <SelectItem value="Other">Other</SelectItem>
                  </SelectContent>
                </Select>
              ) : (
                <p className="mt-1 p-2 bg-slate-50 rounded">{editedItem.category}</p>
              )}
            </div>

            <div>
              <Label className="flex items-center space-x-1">
                <Hash size={14} />
                <span>Quantity</span>
              </Label>
              {isEditing ? (
                <Input
                  type="number"
                  value={editedItem.quantity}
                  onChange={(e) => setEditedItem({ ...editedItem, quantity: parseInt(e.target.value) || 0 })}
                  className="mt-1"
                  min="0"
                />
              ) : (
                <div className="mt-1 p-2 bg-slate-50 rounded flex items-center justify-between">
                  <span>{editedItem.quantity}</span>
                  <Badge className={statusColors[editedItem.status]}>
                    {editedItem.status.replace('-', ' ')}
                  </Badge>
                </div>
              )}
            </div>

            <div>
              <Label className="flex items-center space-x-1">
                <DollarSign size={14} />
                <span>Price</span>
              </Label>
              {isEditing ? (
                <Input
                  type="number"
                  step="0.01"
                  value={editedItem.price}
                  onChange={(e) => setEditedItem({ ...editedItem, price: parseFloat(e.target.value) || 0 })}
                  className="mt-1"
                  min="0"
                />
              ) : (
                <p className="mt-1 p-2 bg-slate-50 rounded">${editedItem.price.toFixed(2)}</p>
              )}
            </div>

            <div className="md:col-span-2">
              <Label>Supplier</Label>
              {isEditing ? (
                <Input
                  value={editedItem.supplier}
                  onChange={(e) => setEditedItem({ ...editedItem, supplier: e.target.value })}
                  className="mt-1"
                  placeholder="Enter supplier name"
                />
              ) : (
                <p className="mt-1 p-2 bg-slate-50 rounded">{editedItem.supplier}</p>
              )}
            </div>

            <div className="md:col-span-2">
              <Label>Image URL</Label>
              {isEditing ? (
                <Input
                  value={editedItem.image || ''}
                  onChange={(e) => setEditedItem({ ...editedItem, image: e.target.value })}
                  className="mt-1"
                  placeholder="Enter image URL (optional)"
                />
              ) : (
                <div className="mt-1">
                  {editedItem.image ? (
                    <div className="flex items-center space-x-2">
                      <img
                        src={editedItem.image}
                        alt={editedItem.name}
                        className="w-16 h-16 object-cover rounded"
                        onError={(e) => {
                          e.currentTarget.style.display = 'none';
                        }}
                      />
                      <span className="text-sm text-slate-600">{editedItem.image}</span>
                    </div>
                  ) : (
                    <p className="p-2 bg-slate-50 rounded text-slate-500">No image</p>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* Description */}
          <div>
            <Label>Description</Label>
            {isEditing ? (
              <Textarea
                value={editedItem.description || ''}
                onChange={(e) => setEditedItem({ ...editedItem, description: e.target.value })}
                className="mt-1"
                rows={3}
                placeholder="Enter item description..."
              />
            ) : (
              <p className="mt-1 p-3 bg-slate-50 rounded min-h-[80px]">
                {editedItem.description || 'No description available'}
              </p>
            )}
          </div>

          {/* Status and Last Updated */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t">
            <div>
              <Label>Status</Label>
              <div className="mt-1">
                <Badge className={statusColors[editedItem.status]}>
                  {editedItem.status.replace('-', ' ')}
                </Badge>
              </div>
            </div>
            <div>
              <Label>Last Updated</Label>
              <p className="mt-1 p-2 bg-slate-50 rounded text-sm">{editedItem.lastUpdated}</p>
            </div>
          </div>

          {/* Stock Level Warning */}
          {editedItem.quantity <= 10 && (
            <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <div className="flex items-center space-x-2">
                <Package className="text-yellow-600" size={16} />
                <span className="text-yellow-800 font-medium">
                  {editedItem.quantity === 0 ? 'Out of Stock' : 'Low Stock Warning'}
                </span>
              </div>
              <p className="text-yellow-700 text-sm mt-1">
                {editedItem.quantity === 0 
                  ? 'This item is currently out of stock. Consider restocking soon.'
                  : `Only ${editedItem.quantity} units remaining. Consider restocking soon.`
                }
              </p>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}