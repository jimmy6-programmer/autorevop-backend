import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Separator } from '@/components/ui/separator';
import { Calendar, Car, User, Phone, Mail, DollarSign, Save } from 'lucide-react';

// Vehicle models by make (matching mobile app)
const vehicleModels: Record<string, string[]> = {
  'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander', 'Prius', 'Tacoma', 'Tundra', '4Runner', 'Sienna', 'Avalon', 'Yaris', 'C-HR', 'Land Cruiser', 'Sequoia', 'Venza'],
  'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'HR-V', 'Fit', 'Odyssey', 'Ridgeline', 'Passport', 'Insight', 'Clarity'],
  'Ford': ['F-150', 'Explorer', 'Escape', 'Mustang', 'Focus', 'Fusion', 'Edge', 'Ranger', 'Bronco', 'Expedition', 'Transit', 'EcoSport'],
  'Chevrolet': ['Silverado', 'Equinox', 'Malibu', 'Traverse', 'Tahoe', 'Suburban', 'Colorado', 'Cruze', 'Impala', 'Camaro', 'Corvette', 'Blazer'],
  'Nissan': ['Altima', 'Sentra', 'Rogue', 'Pathfinder', 'Titan', 'Frontier', 'Maxima', 'Murano', 'Kicks', 'Versa', 'Armada', '370Z'],
  'BMW': ['3 Series', '5 Series', 'X3', 'X5', 'X1', '7 Series', 'X7', 'i3', 'i8', 'M3', 'M5', 'Z4'],
  'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'A-Class', 'CLA', 'GLA', 'GLB', 'G-Class', 'Sprinter'],
  'Audi': ['A3', 'A4', 'A6', 'Q5', 'Q7', 'Q3', 'A5', 'A7', 'TT', 'R8', 'Q8', 'e-tron'],
  'Volkswagen': ['Jetta', 'Passat', 'Tiguan', 'Atlas', 'Golf', 'Arteon', 'ID.4', 'Touareg', 'Beetle'],
  'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Palisade', 'Kona', 'Venue', 'Accent', 'Veloster', 'Nexo'],
  'Kia': ['Sportage', 'Sorento', 'Telluride', 'Soul', 'Forte', 'Optima', 'Rio', 'Stinger', 'Carnival', 'Seltos'],
  'Mazda': ['CX-5', 'CX-9', 'Mazda3', 'Mazda6', 'CX-30', 'CX-3', 'MX-5 Miata', 'CX-50'],
  'Subaru': ['Outback', 'Forester', 'Crosstrek', 'Ascent', 'Impreza', 'Legacy', 'WRX', 'BRZ', 'XV'],
  'Lexus': ['RX', 'GX', 'LX', 'ES', 'LS', 'NX', 'UX', 'IS', 'RC', 'LC'],
  'Acura': ['MDX', 'RDX', 'TLX', 'ILX', 'RLX', 'NSX'],
  'Infiniti': ['QX60', 'QX80', 'QX50', 'Q50', 'Q60', 'QX30'],
  'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck'],
  'Volvo': ['XC90', 'XC60', 'XC40', 'S90', 'S60', 'V90', 'V60'],
  'Jaguar': ['F-PACE', 'E-PACE', 'XE', 'XF', 'XJ', 'F-TYPE', 'I-PACE'],
  'Land Rover': ['Range Rover', 'Discovery', 'Defender', 'Evoque', 'Velar', 'Sport'],
  'Porsche': ['911', 'Cayenne', 'Macan', 'Panamera', 'Taycan', 'Boxster', 'Cayman'],
  'Ferrari': ['488', 'Portofino', 'Roma', 'SF90', '812', 'F8', 'GTC4Lusso'],
  'Lamborghini': ['Huracan', 'Urus', 'Aventador', 'Gallardo', 'Murcielago'],
  'Maserati': ['Ghibli', 'Quattroporte', 'Levante', 'GranTurismo', 'GranCabrio'],
  'Bentley': ['Continental GT', 'Bentayga', 'Flying Spur', 'Mulsanne'],
  'Rolls-Royce': ['Ghost', 'Dawn', 'Wraith', 'Cullinan'],
  'Aston Martin': ['DB11', 'Vantage', 'DBS', 'Rapide', 'Valhalla'],
  'McLaren': ['720S', '570S', '600LT', 'Senna', 'Speedtail'],
  'Bugatti': ['Chiron', 'Divo', 'Centodieci'],
  'Other': ['Other']
};

interface Booking {
  _id: string;
  type: 'mechanic' | 'towing' | 'detailing';
  fullName: string;
  phoneNumber: string;
  vehicleBrand?: string;
  vehicleModel?: string;
  carPlateNumber?: string;
  issue?: string;
  serviceType?: string;
  location: string;
  pickupLocation?: string;
  totalPrice: string;
  mechanicId?: string;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt?: string;
  updatedAt?: string;
}

interface BookingDetailsModalProps {
  booking: Booking | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (booking: Booking) => void | Promise<void>;
  mode: 'view' | 'edit' | 'add';
}

export default function BookingDetailsModal({ booking, isOpen, onClose, onSave, mode }: BookingDetailsModalProps) {
  const [editedBooking, setEditedBooking] = useState<Booking>({
    _id: `BOOK-${Date.now()}`,
    type: 'mechanic',
    fullName: '',
    phoneNumber: '',
    vehicleBrand: '',
    vehicleModel: '',
    carPlateNumber: '',
    issue: '',
    serviceType: '',
    location: '',
    pickupLocation: '',
    totalPrice: '',
    status: 'pending',
  });

  useEffect(() => {
    if (booking) {
      if (mode === 'view') {
        // For view mode, just display the booking data
        setEditedBooking({ ...booking });
      } else if (mode === 'edit') {
        // For edit mode, allow editing the booking data
        setEditedBooking({ ...booking });
      }
    } else if (mode === 'add') {
      setEditedBooking({
        _id: `BOOK-${Date.now()}`,
        type: booking?.type || 'mechanic',
        fullName: '',
        phoneNumber: '',
        vehicleBrand: '',
        vehicleModel: '',
        carPlateNumber: '',
        issue: '',
        serviceType: '',
        location: '',
        pickupLocation: '',
        totalPrice: '',
        status: 'pending',
      });
    }
  }, [booking, mode]);

  const handleSave = () => {
    // Basic validation
    if (!editedBooking.fullName || !editedBooking.phoneNumber || !editedBooking.location || !editedBooking.totalPrice) {
      alert('Please fill in all required fields.');
      return;
    }

    // Type-specific validation
    if (editedBooking.type === 'mechanic') {
      if (!editedBooking.vehicleBrand || !editedBooking.issue) {
        alert('Please fill in vehicle brand and issue for mechanic services.');
        return;
      }
    } else if (editedBooking.type === 'towing') {
      if (!editedBooking.vehicleBrand || !editedBooking.vehicleModel || !editedBooking.carPlateNumber || !editedBooking.serviceType || !editedBooking.pickupLocation) {
        alert('Please fill in all required fields for towing services.');
        return;
      }
    }

    onSave(editedBooking);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[85vh] overflow-y-auto p-6 rounded-lg bg-white shadow-lg">
        <DialogHeader>
          <DialogTitle className="flex items-center justify-between text-xl font-bold text-gray-800">
            <div className="flex items-center space-x-2">
              <Car className="text-blue-600" size={24} />
              <span>
                {mode === 'view' ? 'View Booking Details' :
                 mode === 'edit' ? 'Edit Booking Details' :
                 'Add New Booking'}
              </span>
            </div>
          </DialogTitle>
          <DialogDescription>
            {mode === 'view' ? 'View complete booking information' :
             mode === 'edit' ? 'Edit booking details and save changes' :
             'Create a new booking entry'}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* Service Type Selection */}
          <div className="space-y-4 bg-blue-50 p-4 rounded-lg">
            <h3 className="text-lg font-semibold flex items-center space-x-2 text-gray-700">
              <Car className="text-blue-600" size={20} />
              <span>Service Type</span>
            </h3>
            <div>
              <Label className="text-sm font-medium text-gray-600">Select Service Type *</Label>
              <Select
                value={editedBooking.type}
                onValueChange={(value: 'mechanic' | 'towing') => setEditedBooking({ ...editedBooking, type: value })}
                disabled={mode === 'view'}
              >
                <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                  <SelectValue placeholder="Select service type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="mechanic">Mechanic Service</SelectItem>
                  <SelectItem value="towing">Towing Service</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Customer Information Section */}
          <div className="space-y-4 bg-gray-50 p-4 rounded-lg">
            <h3 className="text-lg font-semibold flex items-center space-x-2 text-gray-700">
              <User className="text-green-600" size={20} />
              <span>Customer Information</span>
            </h3>
            <div className="grid grid-cols-1 gap-4">
              <div>
                <Label className="text-sm font-medium text-gray-600">Customer Full Name *</Label>
                {mode === 'view' ? (
                  <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                    {editedBooking.fullName}
                  </div>
                ) : (
                  <Input
                    value={editedBooking.fullName}
                    onChange={(e) => setEditedBooking({ ...editedBooking, fullName: e.target.value })}
                    className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                    placeholder="Enter customer full name"
                    disabled={mode === 'view'}
                  />
                )}
              </div>
              <div>
                <Label className="flex items-center space-x-1 text-sm font-medium text-gray-600">
                  <Phone size={14} />
                  <span>Phone Number *</span>
                </Label>
                {mode === 'view' ? (
                  <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                    {editedBooking.phoneNumber}
                  </div>
                ) : (
                  <Input
                    value={editedBooking.phoneNumber}
                    onChange={(e) => setEditedBooking({ ...editedBooking, phoneNumber: e.target.value })}
                    className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                    placeholder="Enter phone number"
                    disabled={mode === 'view'}
                  />
                )}
              </div>
            </div>
          </div>

          <Separator className="my-4" />

          {/* Vehicle Information Section */}
          <div className="space-y-4 bg-gray-50 p-4 rounded-lg">
            <h3 className="text-lg font-semibold flex items-center space-x-2 text-gray-700">
              <Car className="text-blue-600" size={20} />
              <span>Vehicle Information</span>
            </h3>
            <div className="grid grid-cols-1 gap-4">
              {editedBooking.type === 'mechanic' ? (
                <>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Vehicle Brand</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.vehicleBrand || '-'}
                      </div>
                    ) : (
                      <Input
                        value={editedBooking.vehicleBrand || ''}
                        onChange={(e) => setEditedBooking({ ...editedBooking, vehicleBrand: e.target.value })}
                        className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                        placeholder="Enter vehicle brand"
                        disabled={mode === 'view'}
                      />
                    )}
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Vehicle Issue *</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.issue || '-'}
                      </div>
                    ) : (
                      <Select
                        value={editedBooking.issue}
                        onValueChange={(value) => setEditedBooking({ ...editedBooking, issue: value })}
                        disabled={mode === 'view'}
                      >
                        <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                          <SelectValue placeholder="Select vehicle issue" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Engine Problem">Engine Problem</SelectItem>
                          <SelectItem value="Brake Issue">Brake Issue</SelectItem>
                          <SelectItem value="Transmission">Transmission</SelectItem>
                          <SelectItem value="Electrical">Electrical</SelectItem>
                          <SelectItem value="Suspension">Suspension</SelectItem>
                          <SelectItem value="Tire/Wheel">Tire/Wheel</SelectItem>
                          <SelectItem value="Air Conditioning">Air Conditioning</SelectItem>
                          <SelectItem value="Exhaust">Exhaust</SelectItem>
                          <SelectItem value="Battery">Battery</SelectItem>
                          <SelectItem value="Oil Change">Oil Change</SelectItem>
                          <SelectItem value="Tuning">Tuning</SelectItem>
                          <SelectItem value="Body Work">Body Work</SelectItem>
                          <SelectItem value="Other">Other</SelectItem>
                        </SelectContent>
                      </Select>
                    )}
                  </div>
                </>
              ) : (
                <>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Vehicle Brand *</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.vehicleBrand || '-'}
                      </div>
                    ) : (
                      <Select
                        value={editedBooking.vehicleBrand}
                        onValueChange={(value) => setEditedBooking({ ...editedBooking, vehicleBrand: value, vehicleModel: '' })}
                        disabled={mode === 'view'}
                      >
                        <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                          <SelectValue placeholder="Select vehicle brand" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Toyota">Toyota</SelectItem>
                          <SelectItem value="Honda">Honda</SelectItem>
                          <SelectItem value="Ford">Ford</SelectItem>
                          <SelectItem value="Chevrolet">Chevrolet</SelectItem>
                          <SelectItem value="Nissan">Nissan</SelectItem>
                          <SelectItem value="BMW">BMW</SelectItem>
                          <SelectItem value="Mercedes-Benz">Mercedes-Benz</SelectItem>
                          <SelectItem value="Audi">Audi</SelectItem>
                          <SelectItem value="Volkswagen">Volkswagen</SelectItem>
                          <SelectItem value="Hyundai">Hyundai</SelectItem>
                          <SelectItem value="Kia">Kia</SelectItem>
                          <SelectItem value="Mazda">Mazda</SelectItem>
                          <SelectItem value="Subaru">Subaru</SelectItem>
                          <SelectItem value="Lexus">Lexus</SelectItem>
                          <SelectItem value="Acura">Acura</SelectItem>
                          <SelectItem value="Infiniti">Infiniti</SelectItem>
                          <SelectItem value="Tesla">Tesla</SelectItem>
                          <SelectItem value="Volvo">Volvo</SelectItem>
                          <SelectItem value="Jaguar">Jaguar</SelectItem>
                          <SelectItem value="Land Rover">Land Rover</SelectItem>
                          <SelectItem value="Porsche">Porsche</SelectItem>
                          <SelectItem value="Ferrari">Ferrari</SelectItem>
                          <SelectItem value="Lamborghini">Lamborghini</SelectItem>
                          <SelectItem value="Maserati">Maserati</SelectItem>
                          <SelectItem value="Bentley">Bentley</SelectItem>
                          <SelectItem value="Rolls-Royce">Rolls-Royce</SelectItem>
                          <SelectItem value="Aston Martin">Aston Martin</SelectItem>
                          <SelectItem value="McLaren">McLaren</SelectItem>
                          <SelectItem value="Bugatti">Bugatti</SelectItem>
                          <SelectItem value="Other">Other</SelectItem>
                        </SelectContent>
                      </Select>
                    )}
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Vehicle Model *</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.vehicleModel || '-'}
                      </div>
                    ) : (
                      <Select
                        value={editedBooking.vehicleModel}
                        onValueChange={(value) => setEditedBooking({ ...editedBooking, vehicleModel: value })}
                        disabled={mode === 'view' || !editedBooking.vehicleBrand}
                      >
                        <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                          <SelectValue placeholder={editedBooking.vehicleBrand ? "Select vehicle model" : "Select brand first"} />
                        </SelectTrigger>
                        <SelectContent>
                          {(vehicleModels[editedBooking.vehicleBrand] || []).map((model) => (
                            <SelectItem key={model} value={model}>
                              {model}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    )}
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Car Plate Number *</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.carPlateNumber || '-'}
                      </div>
                    ) : (
                      <Input
                        value={editedBooking.carPlateNumber}
                        onChange={(e) => setEditedBooking({ ...editedBooking, carPlateNumber: e.target.value })}
                        className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                        placeholder="Enter car plate number"
                        disabled={mode === 'view'}
                      />
                    )}
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Service Type *</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.serviceType || '-'}
                      </div>
                    ) : (
                      <Select
                        value={editedBooking.serviceType}
                        onValueChange={(value) => setEditedBooking({ ...editedBooking, serviceType: value })}
                        disabled={mode === 'view'}
                      >
                        <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                          <SelectValue placeholder="Select service type" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Standard Vehicle Towing">Standard Vehicle Towing</SelectItem>
                          <SelectItem value="Accident Recovery Towing">Accident Recovery Towing</SelectItem>
                          <SelectItem value="Long-Distance Towing">Long-Distance Towing</SelectItem>
                          <SelectItem value="Motorcycle Towing">Motorcycle Towing</SelectItem>
                          <SelectItem value="Battery Jump-Start & Fuel Delivery">Battery Jump-Start & Fuel Delivery</SelectItem>
                        </SelectContent>
                      </Select>
                    )}
                  </div>
                  <div>
                    <Label className="text-sm font-medium text-gray-600">Pickup Location *</Label>
                    {mode === 'view' ? (
                      <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                        {editedBooking.pickupLocation || '-'}
                      </div>
                    ) : (
                      <Input
                        value={editedBooking.pickupLocation}
                        onChange={(e) => setEditedBooking({ ...editedBooking, pickupLocation: e.target.value })}
                        className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                        placeholder="Enter pickup location"
                        disabled={mode === 'view'}
                      />
                    )}
                  </div>
                </>
              )}
              <div>
                <Label className="text-sm font-medium text-gray-600">Location for Service *</Label>
                {mode === 'view' ? (
                  <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                    {editedBooking.location}
                  </div>
                ) : (
                  <Input
                    value={editedBooking.location}
                    onChange={(e) => setEditedBooking({ ...editedBooking, location: e.target.value })}
                    className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                    placeholder="Enter service location"
                    disabled={mode === 'view'}
                  />
                )}
              </div>
              <div>
                <Label className="text-sm font-medium text-gray-600">Total Price *</Label>
                {mode === 'view' ? (
                  <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900">
                    {editedBooking.totalPrice}
                  </div>
                ) : (
                  <Input
                    value={editedBooking.totalPrice}
                    onChange={(e) => setEditedBooking({ ...editedBooking, totalPrice: e.target.value })}
                    className="mt-1 border-gray-300 focus:border-blue-500 transition-colors"
                    placeholder="Enter total price"
                    disabled={mode === 'view'}
                  />
                )}
              </div>
              <div>
                <Label className="text-sm font-medium text-gray-600">Status</Label>
                {mode === 'view' ? (
                  <div className="mt-1 p-3 bg-white border border-gray-300 rounded-md text-gray-900 capitalize">
                    {editedBooking.status}
                  </div>
                ) : (
                  <Select
                    value={editedBooking.status}
                    onValueChange={(value: 'pending' | 'completed' | 'cancelled') =>
                      setEditedBooking({ ...editedBooking, status: value })
                    }
                    disabled={mode === 'view'}
                  >
                    <SelectTrigger className="mt-1 border-gray-300 focus:border-blue-500">
                      <SelectValue placeholder="Select status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="pending">Pending</SelectItem>
                      <SelectItem value="completed">Completed</SelectItem>
                      <SelectItem value="cancelled">Cancelled</SelectItem>
                    </SelectContent>
                  </Select>
                )}
              </div>
            </div>
          </div>


          {/* Footer with Action Buttons */}
          <div className="bg-gray-50 p-4 rounded-lg flex justify-end space-x-2">
            {mode === 'view' ? (
              <Button
                onClick={onClose}
                variant="outline"
                size="sm"
                className="border-gray-300 hover:bg-gray-100"
              >
                Close
              </Button>
            ) : (
              <>
                <Button
                  onClick={onClose}
                  variant="outline"
                  size="sm"
                  className="border-gray-300 hover:bg-gray-100"
                >
                  Cancel
                </Button>
                <Button
                  onClick={handleSave}
                  size="sm"
                  className="bg-green-600 hover:bg-green-700 text-white transition-colors"
                >
                  <Save size={16} className="mr-1" />
                  {mode === 'add' ? 'Create Booking' : 'Save Changes'}
                </Button>
              </>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}