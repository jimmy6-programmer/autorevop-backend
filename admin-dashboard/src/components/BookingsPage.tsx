import { useState, useEffect, useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import BookingDetailsModal from '@/components/BookingDetailsModal';
import { Search, Eye, Edit, Trash2, Plus, Filter, Loader2, RefreshCw } from 'lucide-react';
import { bookingsApi } from '@/lib/api';
import { toast } from 'sonner';

interface Booking {
  _id: string;
  type: 'mechanic' | 'towing' | 'detailing';
  fullName: string;
  phoneNumber: string;
  vehicleBrand?: string;
  vehicleModel?: string;
  carPlateNumber?: string;
  serviceId?: string;
  issue?: string;
  serviceType?: string;
  location: string;
  pickupLocation?: string;
  totalPrice: string;
  mechanicId?: string;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt?: string;
  updatedAt?: string;
  vehicleType?: string; // For detailing services
  serviceId_populated?: {
    _id: string;
    name: string;
    type: string;
    price: number;
  };
}

const statusColors = {
  pending: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  completed: 'bg-green-100 text-green-800 border-green-200',
  cancelled: 'bg-red-100 text-red-800 border-red-200',
};

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit' | 'add'>('view');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [statusFilter, setStatusFilter] = useState('all');
  const [activeTab, setActiveTab] = useState('mechanic');
  const [serviceTabs, setServiceTabs] = useState(['mechanic', 'towing', 'detailing']);

  useEffect(() => {
    fetchBookings();
  }, []);

  const fetchBookings = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await bookingsApi.getAll();
      console.log("Bookings response:", response);
      const safeBookings = Array.isArray(response?.data) ? response.data : [];
      setBookings(safeBookings);
    } catch (err) {
      setError('Failed to load bookings');
      console.error('Error fetching bookings:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredBookings = useMemo(() => {
    const safeBookings = Array.isArray(bookings) ? bookings : [];
    return safeBookings.filter((booking) => {
      const matchesSearch =
        (booking.fullName?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
        (booking.phoneNumber?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
        (booking.vehicleBrand?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
        (booking.vehicleModel?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
        (booking.issue?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
        (booking.serviceType?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
        (booking.location?.toLowerCase() || '').includes(searchTerm.toLowerCase());
      const matchesStatus = statusFilter === 'all' || booking.status === statusFilter;
      const matchesServiceType = booking.type === activeTab;
      return matchesSearch && matchesStatus && matchesServiceType;
    });
  }, [bookings, searchTerm, statusFilter, activeTab]);

  const handleView = (booking: Booking) => {
    setSelectedBooking(booking);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEdit = (booking: Booking) => {
    setSelectedBooking(booking);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setSelectedBooking({
      _id: '',
      type: activeTab as 'mechanic' | 'towing',
      fullName: '',
      phoneNumber: '',
      location: '',
      totalPrice: '',
      status: 'pending',
    });
    setModalMode('add');
    setIsModalOpen(true);
  };

  const handleSave = async (updatedBooking: Booking) => {
    try {
      if (modalMode === 'add') {
        await bookingsApi.create(updatedBooking);
        toast.success('Booking created successfully');
      } else {
        await bookingsApi.update(updatedBooking._id, updatedBooking);
        toast.success('Booking updated successfully');
      }
      await fetchBookings();
    } catch (err) {
      console.error('Error saving booking:', err);
      toast.error('Failed to save booking');
    }
  };

  const handleDelete = async (bookingId: string) => {
    if (!confirm('Are you sure you want to delete this booking?')) return;

    try {
      await bookingsApi.delete(bookingId);
      await fetchBookings();
      toast.success('Booking deleted successfully');
    } catch (err) {
      console.error('Error deleting booking:', err);
      toast.error('Failed to delete booking');
    }
  };

  if (loading) {
    return (
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardContent className="flex justify-center items-center py-12">
          <Loader2 className="h-8 w-8 animate-spin mr-2" />
          <span>Loading bookings...</span>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardContent className="text-center py-12">
          <p className="text-red-600 mb-4">{error}</p>
          <Button onClick={fetchBookings} className="bg-blue-600 hover:bg-blue-700">
            <RefreshCw size={16} className="mr-2" />
            Try Again
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <>
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="mechanic">Mechanic Services</TabsTrigger>
          <TabsTrigger value="towing">Towing Services</TabsTrigger>
          <TabsTrigger value="detailing">Detailing Services</TabsTrigger>
        </TabsList>
        <TabsContent value={activeTab} className="mt-6">
          <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm animate-in slide-in-from-bottom-4 fade-in">
            <CardHeader>
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
                <CardTitle className="flex items-center space-x-2">
                  <span className="text-xl font-bold">
                    {activeTab === 'mechanic' ? 'Mechanic Bookings' :
                     activeTab === 'towing' ? 'Towing Bookings' :
                     'Detailing Bookings'}
                  </span>
                  <Badge variant="secondary" className="ml-2">
                    {filteredBookings.length}
                  </Badge>
                </CardTitle>

                <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                    <Input
                      placeholder="Search bookings..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10 w-full sm:w-64"
                    />
                  </div>

                  <Select value={statusFilter} onValueChange={setStatusFilter}>
                    <SelectTrigger className="w-full sm:w-32">
                      <Filter size={16} className="mr-2" />
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Status</SelectItem>
                      <SelectItem value="pending">Pending</SelectItem>
                      <SelectItem value="completed">Completed</SelectItem>
                      <SelectItem value="cancelled">Cancelled</SelectItem>
                    </SelectContent>
                  </Select>

                  <Button onClick={handleAdd} className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700">
                    <Plus size={16} className="mr-2" />
                    Add Booking
                  </Button>
                </div>
              </div>
            </CardHeader>

            <CardContent>
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Booking ID</TableHead>
                      <TableHead>Customer Name</TableHead>
                      <TableHead className="hidden md:table-cell">Phone</TableHead>
                      <TableHead className="hidden lg:table-cell">
                        {activeTab === 'detailing' ? 'Vehicle Type' : 'Vehicle Brand'}
                      </TableHead>
                      <TableHead>
                        {activeTab === 'mechanic' ? 'Issue' :
                         activeTab === 'towing' ? 'Service Type' :
                         'Phone Number'}
                      </TableHead>
                      <TableHead className="hidden sm:table-cell">Location</TableHead>
                      <TableHead className="hidden sm:table-cell">Status</TableHead>
                      <TableHead className="hidden xl:table-cell">Created Date</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredBookings.map((booking) => (
                      <TableRow key={booking._id} className="hover:bg-slate-50 transition-colors">
                        <TableCell className="font-medium">{booking._id}</TableCell>
                        <TableCell>{booking.fullName}</TableCell>
                        <TableCell className="hidden md:table-cell">
                          {activeTab === 'detailing' ? booking.phoneNumber : booking.phoneNumber}
                        </TableCell>
                        <TableCell className="hidden lg:table-cell">
                          {activeTab === 'detailing'
                            ? (booking.vehicleType || '-')
                            : (booking.vehicleBrand || '-')
                          }
                        </TableCell>
                        <TableCell>
                          {activeTab === 'mechanic'
                            ? (booking.issue || booking.serviceId_populated?.name || '-')
                            : activeTab === 'towing'
                            ? (booking.serviceType || booking.serviceId_populated?.name || '-')
                            : (booking.phoneNumber || '-')
                          }
                        </TableCell>
                        <TableCell className="hidden sm:table-cell">{booking.location}</TableCell>
                        <TableCell className="hidden sm:table-cell">
                          <Badge className={statusColors[booking.status] || statusColors.pending}>
                            {booking.status}
                          </Badge>
                        </TableCell>
                        <TableCell className="hidden xl:table-cell">
                          {booking.createdAt ? new Date(booking.createdAt).toLocaleDateString() : '-'}
                        </TableCell>
                        <TableCell>
                          <div className="flex space-x-1">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleView(booking)}
                              className="h-8 w-8 p-0 hover:bg-blue-100"
                              title="View booking"
                            >
                              <Eye size={14} className="text-blue-600" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleEdit(booking)}
                              className="h-8 w-8 p-0 hover:bg-green-100"
                              title="Edit booking"
                            >
                              <Edit size={14} className="text-green-600" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleDelete(booking._id)}
                              className="h-8 w-8 p-0 hover:bg-red-100"
                              title="Delete booking"
                            >
                              <Trash2 size={14} className="text-red-600" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>

                {filteredBookings.length === 0 && (
                  <div className="text-center py-12">
                    <div className="text-slate-400 mb-4">
                      <Search size={48} className="mx-auto" />
                    </div>
                    <p className="text-slate-600">No bookings found matching your criteria</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <BookingDetailsModal
        booking={selectedBooking}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSave}
        mode={modalMode}
      />
    </>
  );
}