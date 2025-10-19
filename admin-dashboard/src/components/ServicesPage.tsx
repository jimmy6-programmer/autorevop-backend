import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Search, Wrench, Truck, Plus, Edit, Trash2, Eye, Filter, DollarSign, Loader2, Save, X } from 'lucide-react';

interface Service {
  _id: string;
  name: string;
  type: 'mechanic' | 'towing';
  price: number;
  currency: string;
  description?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

const typeColors = {
  mechanic: 'bg-blue-100 text-blue-800 border-blue-200',
  towing: 'bg-orange-100 text-orange-800 border-orange-200'
};

const typeIcons = {
  mechanic: Wrench,
  towing: Truck
};

export default function ServicesPage() {
  const [services, setServices] = useState<Service[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [selectedService, setSelectedService] = useState<Service | null>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit' | 'add'>('view');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    type: 'mechanic' as 'mechanic' | 'towing',
    price: 0,
    currency: 'USD',
    description: '',
    isActive: true
  });

  useEffect(() => {
    fetchServices();
  }, []);

  const fetchServices = async () => {
    try {
      setLoading(true);
      const response = await fetch('https://autorevop-backend.onrender.com/api/services', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`,
        },
      });
      if (!response.ok) throw new Error('Failed to fetch services');
      const data = await response.json();
      setServices(data);
      setError(null);
    } catch (err) {
      setError('Failed to load services');
      console.error('Error fetching services:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredServices = services.filter(service => {
    const matchesSearch = service.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         service.description?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = typeFilter === 'all' || service.type === typeFilter;
    return matchesSearch && matchesType;
  });

  const handleView = (service: Service) => {
    setSelectedService(service);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEdit = (service: Service) => {
    setSelectedService(service);
    setFormData({
      name: service.name,
      type: service.type,
      price: service.price,
      currency: service.currency,
      description: service.description || '',
      isActive: service.isActive
    });
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setFormData({
      name: '',
      type: 'mechanic',
      price: 0,
      currency: 'USD',
      description: '',
      isActive: true
    });
    setModalMode('add');
    setIsModalOpen(true);
  };

  const handleSave = async () => {
    console.log('🔄 Starting service save...');
    console.log('📋 Form data:', formData);
    console.log('🔐 Auth token:', localStorage.getItem('adminToken') ? 'Present' : 'Missing');

    try {
      const url = modalMode === 'add' ? 'https://autorevop-backend.onrender.com/api/services' : `https://autorevop-backend.onrender.com/api/services/${selectedService?._id}`;
      const method = modalMode === 'add' ? 'POST' : 'PUT';

      console.log('🌐 Making request to:', url);
      console.log('📝 Method:', method);

      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`,
        },
        body: JSON.stringify(formData),
      });

      console.log('📊 Response status:', response.status);
      console.log('📄 Response headers:', Object.fromEntries(response.headers.entries()));

      const responseText = await response.text();
      console.log('📄 Response body:', responseText);

      if (!response.ok) {
        throw new Error(`Failed to save service: ${response.status} - ${responseText}`);
      }

      console.log('✅ Service saved successfully');
      await fetchServices(); // Refresh the list
      setIsModalOpen(false);
    } catch (err) {
      console.error('❌ Error saving service:', err);
      alert(`Failed to save service: ${err.message}`);
    }
  };

  const handleDelete = async (serviceId: string) => {
    if (!confirm('Are you sure you want to delete this service?')) return;

    try {
      const response = await fetch(`https://autorevop-backend.onrender.com/api/services/${serviceId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`,
        },
      });

      if (!response.ok) throw new Error('Failed to delete service');

      await fetchServices(); // Refresh the list
    } catch (err) {
      console.error('Error deleting service:', err);
      alert('Failed to delete service');
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      type: 'mechanic',
      price: 0,
      currency: 'USD',
      description: '',
      isActive: true
    });
  };

  return (
    <>
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm animate-in slide-in-from-bottom-4 fade-in">
        <CardHeader>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
            <CardTitle className="flex items-center space-x-2">
              <Wrench className="text-purple-600" size={24} />
              <span className="text-xl font-bold">Services Management</span>
              <Badge variant="secondary" className="ml-2">
                {filteredServices.length}
              </Badge>
            </CardTitle>

            <Button onClick={handleAdd} className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700">
              <Plus size={16} className="mr-2" />
              Add Service
            </Button>
          </div>

          <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2 mt-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
              <Input
                placeholder="Search services..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>

            <Select value={typeFilter} onValueChange={setTypeFilter}>
              <SelectTrigger className="w-full sm:w-48">
                <Filter size={16} className="mr-2" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="mechanic">Mechanic</SelectItem>
                <SelectItem value="towing">Towing</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>

        <CardContent>
          {loading && (
            <div className="flex justify-center items-center py-12">
              <Loader2 className="h-8 w-8 animate-spin" />
              <span className="ml-2">Loading services...</span>
            </div>
          )}
          {error && (
            <div className="text-center py-12">
              <p className="text-red-600">{error}</p>
              <Button onClick={fetchServices} className="mt-4">
                Try Again
              </Button>
            </div>
          )}
          {!loading && !error && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              {filteredServices.map((service) => {
                const TypeIcon = typeIcons[service.type];
                return (
                  <Card key={service._id} className="group hover:shadow-lg transition-all duration-200 hover:scale-105">
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center space-x-2 mb-2">
                            <TypeIcon size={16} className="text-slate-600" />
                            <Badge className={`text-xs ${typeColors[service.type]}`}>
                              {service.type}
                            </Badge>
                          </div>
                          <h3 className="font-semibold text-sm truncate">{service.name}</h3>
                          {service.description && (
                            <p className="text-xs text-slate-600 truncate mt-1">{service.description}</p>
                          )}
                        </div>
                        <Badge variant={service.isActive ? "default" : "secondary"} className="text-xs ml-2">
                          {service.isActive ? 'Active' : 'Inactive'}
                        </Badge>
                      </div>

                      <div className="space-y-2 mb-3">
                        <div className="flex items-center justify-between text-sm">
                          <span className="text-slate-600">Price:</span>
                          <span className="font-medium text-green-600 flex items-center">
                            <DollarSign size={12} />
                            {service.price.toFixed(2)} {service.currency}
                          </span>
                        </div>

                        <div className="text-xs text-slate-500">
                          <p>Created: {new Date(service.createdAt).toLocaleDateString()}</p>
                        </div>
                      </div>

                      <div className="flex space-x-1">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleView(service)}
                          className="h-8 w-8 p-0 hover:bg-blue-100"
                        >
                          <Eye size={14} className="text-blue-600" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleEdit(service)}
                          className="h-8 w-8 p-0 hover:bg-green-100"
                        >
                          <Edit size={14} className="text-green-600" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(service._id)}
                          className="h-8 w-8 p-0 hover:bg-red-100"
                        >
                          <Trash2 size={14} className="text-red-600" />
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}

              {filteredServices.length === 0 && (
                <div className="text-center py-12 col-span-full">
                  <div className="text-slate-400 mb-4">
                    <Wrench size={48} className="mx-auto" />
                  </div>
                  <p className="text-slate-600">No services found matching your criteria</p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>
              {modalMode === 'view' ? 'View Service' :
               modalMode === 'edit' ? 'Edit Service' : 'Add Service'}
            </DialogTitle>
          </DialogHeader>

          {modalMode === 'view' && selectedService ? (
            <div className="space-y-4">
              <div>
                <Label className="text-sm font-medium">Name</Label>
                <p className="text-sm text-slate-600">{selectedService.name}</p>
              </div>
              <div>
                <Label className="text-sm font-medium">Type</Label>
                <p className="text-sm text-slate-600 capitalize">{selectedService.type}</p>
              </div>
              <div>
                <Label className="text-sm font-medium">Price</Label>
                <p className="text-sm text-slate-600">
                  {selectedService.price.toFixed(2)} {selectedService.currency}
                </p>
              </div>
              <div>
                <Label className="text-sm font-medium">Description</Label>
                <p className="text-sm text-slate-600">{selectedService.description || 'No description'}</p>
              </div>
              <div>
                <Label className="text-sm font-medium">Status</Label>
                <p className="text-sm text-slate-600">{selectedService.isActive ? 'Active' : 'Inactive'}</p>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              <div>
                <Label htmlFor="name">Name</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  placeholder="Service name"
                />
              </div>

              <div>
                <Label htmlFor="type">Type</Label>
                <Select value={formData.type} onValueChange={(value: 'mechanic' | 'towing') => setFormData({...formData, type: value})}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="mechanic">Mechanic</SelectItem>
                    <SelectItem value="towing">Towing</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="price">Price</Label>
                  <Input
                    id="price"
                    type="number"
                    step="0.01"
                    value={formData.price}
                    onChange={(e) => setFormData({...formData, price: parseFloat(e.target.value) || 0})}
                    placeholder="0.00"
                  />
                </div>
                <div>
                  <Label htmlFor="currency">Currency</Label>
                  <Select value={formData.currency} onValueChange={(value) => setFormData({...formData, currency: value})}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="USD">USD</SelectItem>
                      <SelectItem value="EUR">EUR</SelectItem>
                      <SelectItem value="RWF">RWF</SelectItem>
                      <SelectItem value="KES">KES</SelectItem>
                      <SelectItem value="TZS">TZS</SelectItem>
                      <SelectItem value="UGX">UGX</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div>
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  placeholder="Service description (optional)"
                  rows={3}
                />
              </div>

              <div className="flex items-center space-x-2">
                <Switch
                  id="isActive"
                  checked={formData.isActive}
                  onCheckedChange={(checked) => setFormData({...formData, isActive: checked})}
                />
                <Label htmlFor="isActive">Active</Label>
              </div>

              <div className="flex justify-end space-x-2 pt-4">
                <Button variant="outline" onClick={() => setIsModalOpen(false)}>
                  <X size={16} className="mr-2" />
                  Cancel
                </Button>
                <Button onClick={handleSave}>
                  <Save size={16} className="mr-2" />
                  Save
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}