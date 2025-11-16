import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import InventoryEditModal from '@/components/InventoryEditModal';
import { Search, Package, Plus, Edit, Trash2, Eye, Filter, DollarSign, Loader2 } from 'lucide-react';
import { inventoryApi } from '@/lib/api';

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

const statusColors = {
  'in-stock': 'bg-green-100 text-green-800 border-green-200',
  'low-stock': 'bg-yellow-100 text-yellow-800 border-yellow-200',
  'out-of-stock': 'bg-red-100 text-red-800 border-red-200'
};

export default function InventoryGrid() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedItem, setSelectedItem] = useState<InventoryItem | null>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit' | 'add'>('view');
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    fetchInventory();
  }, []);

  const fetchInventory = async () => {
    try {
      setLoading(true);
      const response = await inventoryApi.getAll();
      setInventory(response.data || []);
      setError(null);
    } catch (err) {
      setError('Failed to load inventory');
      console.error('Error fetching inventory:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredInventory = inventory.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         item.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         item.supplier.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = categoryFilter === 'all' || item.category === categoryFilter;
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesCategory && matchesStatus;
  });

  const categories = [...new Set(inventory.map(item => item.category))];

  const handleView = (item: InventoryItem) => {
    setSelectedItem(item);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEdit = (item: InventoryItem) => {
    setSelectedItem(item);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setSelectedItem(null);
    setModalMode('add');
    setIsModalOpen(true);
  };

  const handleSave = async (updatedItem: InventoryItem) => {
    try {
      if (modalMode === 'add') {
        await inventoryApi.create(updatedItem);
      } else {
        await inventoryApi.update(updatedItem.id, updatedItem);
      }
      await fetchInventory(); // Refresh the list
    } catch (err) {
      console.error('Error saving inventory item:', err);
      alert('Failed to save inventory item');
    }
  };

  const handleDelete = async (itemId: string) => {
    try {
      await inventoryApi.delete(itemId);
      await fetchInventory(); // Refresh the list
    } catch (err) {
      console.error('Error deleting inventory item:', err);
      alert('Failed to delete inventory item');
    }
  };

  return (
    <>
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm animate-in slide-in-from-bottom-4 fade-in">
        <CardHeader>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
            <CardTitle className="flex items-center space-x-2">
              <Package className="text-purple-600" size={24} />
              <span className="text-xl font-bold">Inventory Management</span>
              <Badge variant="secondary" className="ml-2">
                {filteredInventory.length}
              </Badge>
            </CardTitle>
            
            <Button onClick={handleAdd} className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700">
              <Plus size={16} className="mr-2" />
              Add Item
            </Button>
          </div>
          
          <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2 mt-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
              <Input
                placeholder="Search inventory..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            
            <Select value={categoryFilter} onValueChange={setCategoryFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <Filter size={16} className="mr-2" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Categories</SelectItem>
                {categories.map(category => (
                  <SelectItem key={category} value={category}>{category}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-full sm:w-40">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Status</SelectItem>
                <SelectItem value="in-stock">In Stock</SelectItem>
                <SelectItem value="low-stock">Low Stock</SelectItem>
                <SelectItem value="out-of-stock">Out of Stock</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        
        <CardContent>
          {loading && (
            <div className="flex justify-center items-center py-12">
              <Loader2 className="h-8 w-8 animate-spin" />
              <span className="ml-2">Loading inventory...</span>
            </div>
          )}
          {error && (
            <div className="text-center py-12">
              <p className="text-red-600">{error}</p>
              <Button onClick={fetchInventory} className="mt-4">
                Try Again
              </Button>
            </div>
          )}
          {!loading && !error && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filteredInventory.map((item) => (
              <Card key={item.id} className="group hover:shadow-lg transition-all duration-200 hover:scale-105">
                <CardContent className="p-4">
                  {item.image && (
                    <div className="mb-3">
                      <img
                        src={item.image}
                        alt={item.name}
                        className="w-full h-32 object-cover rounded-md"
                        onError={(e) => {
                          e.currentTarget.style.display = 'none';
                        }}
                      />
                    </div>
                  )}
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-sm truncate">{item.name}</h3>
                      <p className="text-xs text-slate-600 truncate">{item.category}</p>
                    </div>
                    <Badge className={`text-xs ml-2 ${statusColors[item.status]}`}>
                      {item.status.replace('-', ' ')}
                    </Badge>
                  </div>

                  <div className="space-y-2 mb-3">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-slate-600">Quantity:</span>
                      <span className={`font-medium ${item.quantity <= 10 ? 'text-red-600' : 'text-slate-900'}`}>
                        {item.quantity}
                      </span>
                    </div>

                    <div className="flex items-center justify-between text-sm">
                      <span className="text-slate-600">Price:</span>
                      <span className="font-medium text-green-600 flex items-center">
                        <DollarSign size={12} />
                        {item.price.toFixed(2)}
                      </span>
                    </div>

                    <div className="text-xs text-slate-500">
                      <p>Supplier: {item.supplier}</p>
                      <p>Updated: {item.lastUpdated}</p>
                    </div>
                  </div>

                  <div className="flex space-x-1">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleView(item)}
                      className="h-8 w-8 p-0 hover:bg-blue-100"
                    >
                      <Eye size={14} className="text-blue-600" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleEdit(item)}
                      className="h-8 w-8 p-0 hover:bg-green-100"
                    >
                      <Edit size={14} className="text-green-600" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDelete(item.id)}
                      className="h-8 w-8 p-0 hover:bg-red-100"
                    >
                      <Trash2 size={14} className="text-red-600" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}

            {filteredInventory.length === 0 && (
              <div className="text-center py-12 col-span-full">
                <div className="text-slate-400 mb-4">
                  <Package size={48} className="mx-auto" />
                </div>
                <p className="text-slate-600">No inventory items found matching your criteria</p>
              </div>
            )}
          </div>
        )}
       </CardContent>
      </Card>

      <InventoryEditModal
        item={selectedItem}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSave}
        onDelete={handleDelete}
        mode={modalMode}
      />
    </>
  );
}