import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Phone, PhoneCall, PhoneOff, Clock, User } from 'lucide-react';

interface CallModalProps {
  isOpen: boolean;
  onClose: () => void;
  phoneNumber: string;
  contactName: string;
}

export default function CallModal({ isOpen, onClose, phoneNumber, contactName }: CallModalProps) {
  const [callStatus, setCallStatus] = useState<'dialing' | 'connected' | 'ended'>('dialing');
  const [callDuration, setCallDuration] = useState(0);

  useEffect(() => {
    if (isOpen) {
      setCallStatus('dialing');
      setCallDuration(0);
      
      // Simulate call connection after 3 seconds
      const dialingTimer = setTimeout(() => {
        setCallStatus('connected');
      }, 3000);

      return () => clearTimeout(dialingTimer);
    }
  }, [isOpen]);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (callStatus === 'connected') {
      interval = setInterval(() => {
        setCallDuration(prev => prev + 1);
      }, 1000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [callStatus]);

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleEndCall = () => {
    setCallStatus('ended');
    setTimeout(() => {
      onClose();
    }, 1000);
  };

  const getStatusColor = () => {
    switch (callStatus) {
      case 'dialing':
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'connected':
        return 'bg-green-100 text-green-800 border-green-200';
      case 'ended':
        return 'bg-red-100 text-red-800 border-red-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusText = () => {
    switch (callStatus) {
      case 'dialing':
        return 'Calling...';
      case 'connected':
        return 'Connected';
      case 'ended':
        return 'Call Ended';
      default:
        return 'Unknown';
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center space-x-2">
            <Phone className="text-blue-600" size={24} />
            <span>Voice Call</span>
          </DialogTitle>
        </DialogHeader>

        <div className="text-center space-y-6 py-8">
          {/* Contact Avatar */}
          <div className="flex justify-center">
            <div className="w-24 h-24 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white text-2xl font-semibold">
              {contactName.split(' ').map(n => n[0]).join('')}
            </div>
          </div>

          {/* Contact Info */}
          <div>
            <h3 className="text-xl font-semibold text-slate-800">{contactName}</h3>
            <p className="text-slate-600">{phoneNumber}</p>
          </div>

          {/* Call Status */}
          <div className="space-y-2">
            <Badge className={`${getStatusColor()} px-4 py-2 text-sm`}>
              {getStatusText()}
            </Badge>
            
            {callStatus === 'connected' && (
              <div className="flex items-center justify-center space-x-2 text-slate-600">
                <Clock size={16} />
                <span>{formatDuration(callDuration)}</span>
              </div>
            )}
          </div>

          {/* Call Animation */}
          <div className="flex justify-center">
            {callStatus === 'dialing' && (
              <div className="relative">
                <div className="w-16 h-16 bg-yellow-200 rounded-full flex items-center justify-center animate-pulse">
                  <PhoneCall className="text-yellow-600" size={24} />
                </div>
                <div className="absolute inset-0 w-16 h-16 bg-yellow-200 rounded-full animate-ping opacity-30"></div>
              </div>
            )}
            
            {callStatus === 'connected' && (
              <div className="relative">
                <div className="w-16 h-16 bg-green-200 rounded-full flex items-center justify-center">
                  <PhoneCall className="text-green-600" size={24} />
                </div>
                <div className="absolute inset-0 w-16 h-16 bg-green-200 rounded-full animate-pulse opacity-50"></div>
              </div>
            )}

            {callStatus === 'ended' && (
              <div className="w-16 h-16 bg-red-200 rounded-full flex items-center justify-center">
                <PhoneOff className="text-red-600" size={24} />
              </div>
            )}
          </div>

          {/* Call Controls */}
          <div className="flex justify-center space-x-4">
            {callStatus !== 'ended' && (
              <Button 
                onClick={handleEndCall}
                className="bg-red-600 hover:bg-red-700 rounded-full w-16 h-16 p-0"
              >
                <PhoneOff size={24} />
              </Button>
            )}
            
            {callStatus === 'ended' && (
              <Button onClick={onClose} className="px-8">
                Close
              </Button>
            )}
          </div>

          {/* Call Info */}
          <div className="text-xs text-slate-500 space-y-1">
            <p>🔒 This is a simulated call interface</p>
            <p>In a real system, this would integrate with VoIP services</p>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}