import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import MechanicDetailsModal from '@/components/MechanicDetailsModal';
import CallModal from '@/components/CallModal';
import { Phone, Star, Plus, Edit, Trash2, Eye, Loader2 } from 'lucide-react';
import { mechanicsApi } from '@/lib/api';

interface Job {
  id: string;
  orderId: string;
  customerName: string;
  service: string;
  completedDate: string;
  rating: number;
  feedback?: string;
}

interface Mechanic {
  id: string;
  name: string;
  phone: string;
  email: string;
  specialty: string;
  experience: string;
  status: 'available' | 'busy' | 'offline';
  rating: number;
  completedJobs: number;
  image?: string;
  location: 'Rwanda' | 'Kenya';
  jobs: Job[];
}

const statusColors = {
  available: 'bg-green-100 text-green-800 border-green-200',
  busy: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  offline: 'bg-red-100 text-red-800 border-red-200'
};

export default function MechanicsCard() {
  const [mechanics, setMechanics] = useState<Mechanic[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedMechanic, setSelectedMechanic] = useState<Mechanic | null>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit' | 'add'>('view');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isCallModalOpen, setIsCallModalOpen] = useState(false);
  const [callInfo, setCallInfo] = useState({ phone: '', name: '' });

  useEffect(() => {
    fetchMechanics();
  }, []);

  const fetchMechanics = async () => {
    try {
      setLoading(true);
      const data = await mechanicsApi.getAll();
      setMechanics(data);
      setError(null);
    } catch (err) {
      setError('Failed to load mechanics');
      console.error('Error fetching mechanics:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleView = (mechanic: Mechanic) => {
    setSelectedMechanic(mechanic);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEdit = (mechanic: Mechanic) => {
    setSelectedMechanic(mechanic);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setSelectedMechanic(null);
    setModalMode('add');
    setIsModalOpen(true);
  };

  const handleCall = (phone: string, name: string) => {
    setCallInfo({ phone, name });
    setIsCallModalOpen(true);
  };

  const handleSave = async (updatedMechanic: Mechanic) => {
    try {
      if (modalMode === 'add') {
        await mechanicsApi.create(updatedMechanic);
      } else {
        await mechanicsApi.update(updatedMechanic.id, updatedMechanic);
      }
      await fetchMechanics(); // Refresh the list
    } catch (err) {
      console.error('Error saving mechanic:', err);
      alert('Failed to save mechanic');
    }
  };

  const handleDelete = async (mechanicId: string) => {
    try {
      await mechanicsApi.delete(mechanicId);
      await fetchMechanics(); // Refresh the list
    } catch (err) {
      console.error('Error deleting mechanic:', err);
      alert('Failed to delete mechanic');
    }
  };

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        size={12}
        className={i < rating ? 'text-yellow-400 fill-current' : 'text-gray-300'}
      />
    ));
  };

  return (
    <>
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center space-x-2">
              <span className="text-xl font-bold">Mechanics Team</span>
              <Badge variant="secondary" className="ml-2">
                {mechanics.length}
              </Badge>
            </CardTitle>
            <Button onClick={handleAdd} className="bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-700 hover:to-blue-700">
              <Plus size={16} className="mr-2" />
              Add Mechanic
            </Button>
          </div>
        </CardHeader>
        
        <CardContent>
          {loading && (
            <div className="flex justify-center items-center py-12">
              <Loader2 className="h-8 w-8 animate-spin" />
              <span className="ml-2">Loading mechanics...</span>
            </div>
          )}
          {error && (
            <div className="text-center py-12">
              <p className="text-red-600">{error}</p>
              <Button onClick={fetchMechanics} className="mt-4">
                Try Again
              </Button>
            </div>
          )}
          {!loading && !error && (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-4">
              {mechanics.map((mechanic) => (
                <Card key={mechanic.id} className="relative group hover:shadow-lg transition-all duration-200 hover:scale-105">
                  <CardContent className="p-4">
                    <div className="flex items-center space-x-3 mb-3">
                       <Avatar className="h-12 w-12 bg-gradient-to-r from-blue-500 to-purple-500">
                         <AvatarImage src={mechanic.image} alt={mechanic.name} />
                         <AvatarFallback className="text-white font-semibold">
                           {mechanic.name.split(' ').map(n => n[0]).join('')}
                         </AvatarFallback>
                       </Avatar>
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-sm truncate">{mechanic.name}</h3>
                        <p className="text-xs text-slate-600 truncate">{mechanic.specialty}</p>
                      </div>
                    </div>

                    <div className="space-y-2 mb-3">
                      <div className="flex items-center justify-between">
                        <Badge className={`text-xs ${statusColors[mechanic.status]}`}>
                          {mechanic.status}
                        </Badge>
                        <div className="flex items-center space-x-1">
                          {renderStars(Math.round(mechanic.rating))}
                        </div>
                      </div>

                      <div className="text-xs text-slate-600">
                        <p>{mechanic.completedJobs} jobs completed</p>
                        <p>{mechanic.experience} experience</p>
                      </div>
                    </div>

                    <div className="flex space-x-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleView(mechanic)}
                        className="h-8 w-8 p-0 hover:bg-blue-100"
                      >
                        <Eye size={14} className="text-blue-600" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleEdit(mechanic)}
                        className="h-8 w-8 p-0 hover:bg-green-100"
                      >
                        <Edit size={14} className="text-green-600" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleCall(mechanic.phone, mechanic.name)}
                        className="h-8 w-8 p-0 hover:bg-green-100"
                      >
                        <Phone size={14} className="text-green-600" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleDelete(mechanic.id)}
                        className="h-8 w-8 p-0 hover:bg-red-100"
                      >
                        <Trash2 size={14} className="text-red-600" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}

              {mechanics.length === 0 && (
                <div className="text-center py-12 col-span-full">
                  <div className="text-slate-400 mb-4">
                    <Plus size={48} className="mx-auto" />
                  </div>
                  <p className="text-slate-600">No mechanics found. Add your first mechanic!</p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      <MechanicDetailsModal
        mechanic={selectedMechanic}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSave}
        onDelete={handleDelete}
        onCall={(phone) => handleCall(phone, selectedMechanic?.name || '')}
        mode={modalMode}
      />

      <CallModal
        isOpen={isCallModalOpen}
        onClose={() => setIsCallModalOpen(false)}
        phoneNumber={callInfo.phone}
        contactName={callInfo.name}
      />
    </>
  );
}