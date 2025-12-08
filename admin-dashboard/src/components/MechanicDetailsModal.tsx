import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { User, Phone, Mail, MapPin, Star, Briefcase, Calendar, Plus, X, Save, Trash2 } from 'lucide-react';

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

interface MechanicDetailsModalProps {
  mechanic: Mechanic | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (mechanic: Mechanic) => void;
  onDelete: (mechanicId: string) => void;
  onCall: (phone: string) => void;
  mode: 'view' | 'edit' | 'add';
}

const statusColors = {
  available: 'bg-green-100 text-green-800 border-green-200',
  busy: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  offline: 'bg-red-100 text-red-800 border-red-200'
};

export default function MechanicDetailsModal({ 
  mechanic, 
  isOpen, 
  onClose, 
  onSave, 
  onDelete, 
  onCall, 
  mode 
}: MechanicDetailsModalProps) {
  const [editedMechanic, setEditedMechanic] = useState<Mechanic | null>(null);
  const [isEditing, setIsEditing] = useState(mode === 'edit' || mode === 'add');
  const [newJob, setNewJob] = useState<Partial<Job>>({});
  const [showAddJob, setShowAddJob] = useState(false);

  useEffect(() => {
    if (mechanic) {
      setEditedMechanic({ ...mechanic });
    } else if (mode === 'add') {
      setEditedMechanic({
        id: `MECH-${Date.now()}`,
        name: '',
        phone: '',
        email: '',
        specialty: '',
        experience: '',
        status: 'available',
        rating: 0,
        completedJobs: 0,
        image: '',
        location: 'Rwanda',
        jobs: []
      });
    }
    setIsEditing(mode === 'edit' || mode === 'add');
  }, [mechanic, mode]);

  if (!editedMechanic) return null;

  const handleSave = () => {
    onSave(editedMechanic);
    setIsEditing(false);
    onClose();
  };

  const handleDelete = () => {
    if (confirm('Are you sure you want to delete this mechanic?')) {
      onDelete(editedMechanic.id);
      onClose();
    }
  };

  const handleCall = () => {
    onCall(editedMechanic.phone);
  };

  const addJob = () => {
    if (newJob.customerName && newJob.service && newJob.completedDate && newJob.rating) {
      const job: Job = {
        id: `JOB-${Date.now()}`,
        orderId: `ORD-${Date.now()}`,
        customerName: newJob.customerName,
        service: newJob.service,
        completedDate: newJob.completedDate,
        rating: newJob.rating,
        feedback: newJob.feedback || ''
      };
      
      setEditedMechanic({
        ...editedMechanic,
        jobs: [...editedMechanic.jobs, job],
        completedJobs: editedMechanic.completedJobs + 1,
        rating: ((editedMechanic.rating * editedMechanic.completedJobs) + newJob.rating) / (editedMechanic.completedJobs + 1)
      });
      
      setNewJob({});
      setShowAddJob(false);
    }
  };

  const removeJob = (jobId: string) => {
    const updatedJobs = editedMechanic.jobs.filter(job => job.id !== jobId);
    const newCompletedJobs = updatedJobs.length;
    const newRating = newCompletedJobs > 0 
      ? updatedJobs.reduce((sum, job) => sum + job.rating, 0) / newCompletedJobs 
      : 0;
    
    setEditedMechanic({
      ...editedMechanic,
      jobs: updatedJobs,
      completedJobs: newCompletedJobs,
      rating: newRating
    });
  };

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        size={16}
        className={i < rating ? 'text-yellow-400 fill-current' : 'text-gray-300'}
      />
    ));
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-6xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center justify-between">
            <span className="flex items-center space-x-2">
              <User className="text-blue-600" size={24} />
              <span>{mode === 'add' ? 'Add New Mechanic' : `Mechanic Details - ${editedMechanic.name}`}</span>
            </span>
            <div className="flex items-center space-x-2">
              {mode !== 'add' && !isEditing && (
                <Button onClick={handleCall} className="bg-green-600 hover:bg-green-700">
                  <Phone size={16} className="mr-1" />
                  Call
                </Button>
              )}
              {!isEditing ? (
                <Button onClick={() => setIsEditing(true)} size="sm">
                  Edit
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

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Basic Information */}
          <div className="lg:col-span-2 space-y-6">
            <div className="flex items-center space-x-4 p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg">
               <Avatar className="h-16 w-16 bg-gradient-to-r from-blue-500 to-purple-500">
                 <AvatarImage src={editedMechanic.image} alt={editedMechanic.name} />
                 <AvatarFallback className="text-white font-semibold text-xl">
                   {editedMechanic.name.split(' ').map(n => n[0]).join('') || 'M'}
                 </AvatarFallback>
               </Avatar>
              <div className="flex-1">
                <h3 className="text-xl font-semibold">{editedMechanic.name || 'New Mechanic'}</h3>
                <div className="flex items-center space-x-2 mt-1">
                  <div className="flex items-center space-x-1">
                    {renderStars(Math.round(editedMechanic.rating))}
                    <span className="text-sm text-slate-600">({editedMechanic.rating.toFixed(1)})</span>
                  </div>
                  <Badge className={statusColors[editedMechanic.status]}>
                    {editedMechanic.status}
                  </Badge>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
               <div>
                 <Label>Full Name</Label>
                 {isEditing ? (
                   <Input
                     value={editedMechanic.name}
                     onChange={(e) => setEditedMechanic({ ...editedMechanic, name: e.target.value })}
                     className="mt-1"
                   />
                 ) : (
                   <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.name}</p>
                 )}
               </div>

               <div>
                 <Label>Profile Image URL</Label>
                 {isEditing ? (
                   <Input
                     value={editedMechanic.image || ''}
                     onChange={(e) => setEditedMechanic({ ...editedMechanic, image: e.target.value })}
                     className="mt-1"
                     placeholder="https://example.com/image.jpg"
                   />
                 ) : (
                   <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.image || 'No image'}</p>
                 )}
               </div>

              <div>
                <Label>Phone</Label>
                {isEditing ? (
                  <Input
                    value={editedMechanic.phone}
                    onChange={(e) => setEditedMechanic({ ...editedMechanic, phone: e.target.value })}
                    className="mt-1"
                  />
                ) : (
                  <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.phone}</p>
                )}
              </div>

              <div>
                <Label>Email</Label>
                {isEditing ? (
                  <Input
                    value={editedMechanic.email}
                    onChange={(e) => setEditedMechanic({ ...editedMechanic, email: e.target.value })}
                    className="mt-1"
                  />
                ) : (
                  <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.email}</p>
                )}
              </div>

              <div>
                <Label>Status</Label>
                {isEditing ? (
                  <Select value={editedMechanic.status} onValueChange={(value: 'available' | 'busy' | 'offline') => setEditedMechanic({ ...editedMechanic, status: value })}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="available">Available</SelectItem>
                      <SelectItem value="busy">Busy</SelectItem>
                      <SelectItem value="offline">Offline</SelectItem>
                    </SelectContent>
                  </Select>
                ) : (
                  <Badge className={`mt-1 ${statusColors[editedMechanic.status]}`}>
                    {editedMechanic.status}
                  </Badge>
                )}
              </div>

              <div>
                <Label>Specialty</Label>
                {isEditing ? (
                  <Input
                    value={editedMechanic.specialty}
                    onChange={(e) => setEditedMechanic({ ...editedMechanic, specialty: e.target.value })}
                    className="mt-1"
                  />
                ) : (
                  <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.specialty}</p>
                )}
              </div>

              <div>
                <Label>Experience</Label>
                {isEditing ? (
                  <Input
                    value={editedMechanic.experience}
                    onChange={(e) => setEditedMechanic({ ...editedMechanic, experience: e.target.value })}
                    className="mt-1"
                  />
                ) : (
                  <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.experience}</p>
                )}
              </div>

              <div>
                <Label>Location</Label>
                {isEditing ? (
                  <Select value={editedMechanic.location} onValueChange={(value: 'Rwanda' | 'Kenya') => setEditedMechanic({ ...editedMechanic, location: value })}>
                    <SelectTrigger className="mt-1">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Rwanda">Rwanda</SelectItem>
                      <SelectItem value="Kenya">Kenya</SelectItem>
                    </SelectContent>
                  </Select>
                ) : (
                  <p className="mt-1 p-2 bg-slate-50 rounded">{editedMechanic.location}</p>
                )}
              </div>
            </div>
          </div>

          {/* Statistics */}
          <div className="space-y-4">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm">Statistics</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-600">{editedMechanic.completedJobs}</div>
                  <div className="text-sm text-slate-600">Completed Jobs</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center space-x-1">
                    {renderStars(Math.round(editedMechanic.rating))}
                  </div>
                  <div className="text-sm text-slate-600 mt-1">{editedMechanic.rating.toFixed(1)} Rating</div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        <Separator className="my-6" />

        {/* Jobs History */}
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold flex items-center space-x-2">
              <Briefcase className="text-purple-600" size={20} />
              <span>Job History</span>
            </h3>
            {isEditing && (
              <Button onClick={() => setShowAddJob(true)} size="sm">
                <Plus size={16} className="mr-1" />
                Add Job
              </Button>
            )}
          </div>

          {showAddJob && (
            <Card className="border-dashed border-2 border-blue-300">
              <CardContent className="p-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label>Customer Name</Label>
                    <Input
                      value={newJob.customerName || ''}
                      onChange={(e) => setNewJob({ ...newJob, customerName: e.target.value })}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label>Service</Label>
                    <Input
                      value={newJob.service || ''}
                      onChange={(e) => setNewJob({ ...newJob, service: e.target.value })}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label>Completed Date</Label>
                    <Input
                      type="date"
                      value={newJob.completedDate || ''}
                      onChange={(e) => setNewJob({ ...newJob, completedDate: e.target.value })}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label>Rating</Label>
                    <Select value={newJob.rating?.toString()} onValueChange={(value) => setNewJob({ ...newJob, rating: parseInt(value) })}>
                      <SelectTrigger className="mt-1">
                        <SelectValue placeholder="Select rating" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="1">1 Star</SelectItem>
                        <SelectItem value="2">2 Stars</SelectItem>
                        <SelectItem value="3">3 Stars</SelectItem>
                        <SelectItem value="4">4 Stars</SelectItem>
                        <SelectItem value="5">5 Stars</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
                <div className="mt-4">
                  <Label>Feedback</Label>
                  <Textarea
                    value={newJob.feedback || ''}
                    onChange={(e) => setNewJob({ ...newJob, feedback: e.target.value })}
                    className="mt-1"
                    rows={2}
                  />
                </div>
                <div className="flex space-x-2 mt-4">
                  <Button onClick={addJob} size="sm" className="bg-green-600 hover:bg-green-700">
                    Add Job
                  </Button>
                  <Button onClick={() => setShowAddJob(false)} variant="outline" size="sm">
                    Cancel
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {editedMechanic.jobs.map((job) => (
              <Card key={job.id} className="relative">
                <CardContent className="p-4">
                  {isEditing && (
                    <Button
                      onClick={() => removeJob(job.id)}
                      variant="ghost"
                      size="sm"
                      className="absolute top-2 right-2 h-6 w-6 p-0 text-red-600 hover:bg-red-100"
                    >
                      <Trash2 size={12} />
                    </Button>
                  )}
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <h4 className="font-medium">{job.customerName}</h4>
                      <div className="flex items-center space-x-1">
                        {renderStars(job.rating)}
                      </div>
                    </div>
                    <p className="text-sm text-slate-600">{job.service}</p>
                    <div className="flex items-center space-x-2 text-xs text-slate-500">
                      <Calendar size={12} />
                      <span>{job.completedDate}</span>
                    </div>
                    {job.feedback && (
                      <p className="text-xs text-slate-600 italic">"{job.feedback}"</p>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {editedMechanic.jobs.length === 0 && (
            <div className="text-center py-8 text-slate-500">
              <Briefcase size={48} className="mx-auto mb-4 text-slate-300" />
              <p>No job history available</p>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}