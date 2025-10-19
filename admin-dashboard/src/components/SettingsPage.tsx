import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Separator } from '@/components/ui/separator';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { User, Mail, Phone, MapPin, Palette, Bell, Shield, Save } from 'lucide-react';

export default function SettingsPage() {
  const [profile, setProfile] = useState({
    name: 'Admin User',
    email: 'admin@repairhub.com',
    phone: '+1 (555) 123-4567',
    location: 'New York, NY',
    role: 'Administrator'
  });

  const [preferences, setPreferences] = useState({
    theme: 'light',
    notifications: true,
    emailAlerts: true,
    soundAlerts: false,
    autoRefresh: true,
    language: 'en'
  });

  const handleProfileUpdate = () => {
    // Here you would typically save to backend
    console.log('Profile updated:', profile);
  };

  const handlePreferencesUpdate = () => {
    // Here you would typically save to backend
    console.log('Preferences updated:', preferences);
  };

  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 fade-in">
      <div>
        <h2 className="text-3xl font-bold text-slate-800 mb-2">Settings</h2>
        <p className="text-slate-600">Manage your account settings and preferences</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Profile Settings */}
        <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <User className="text-blue-600" size={20} />
              <span>Profile Information</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="flex items-center space-x-4 mb-6">
              <Avatar className="h-20 w-20 bg-gradient-to-r from-blue-500 to-purple-500">
                <AvatarFallback className="text-white font-semibold text-2xl">
                  {profile.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              <div>
                <h3 className="text-lg font-semibold">{profile.name}</h3>
                <Badge className="bg-blue-100 text-blue-800 border-blue-200">
                  {profile.role}
                </Badge>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <Label htmlFor="name">Full Name</Label>
                <Input
                  id="name"
                  value={profile.name}
                  onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                  className="mt-1"
                />
              </div>

              <div>
                <Label htmlFor="email">Email Address</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="email"
                    type="email"
                    value={profile.email}
                    onChange={(e) => setProfile({ ...profile, email: e.target.value })}
                    className="pl-10 mt-1"
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="phone">Phone Number</Label>
                <div className="relative">
                  <Phone className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="phone"
                    value={profile.phone}
                    onChange={(e) => setProfile({ ...profile, phone: e.target.value })}
                    className="pl-10 mt-1"
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="location">Location</Label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="location"
                    value={profile.location}
                    onChange={(e) => setProfile({ ...profile, location: e.target.value })}
                    className="pl-10 mt-1"
                  />
                </div>
              </div>
            </div>

            <Button 
              onClick={handleProfileUpdate}
              className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700"
            >
              <Save size={16} className="mr-2" />
              Update Profile
            </Button>
          </CardContent>
        </Card>

        {/* Preferences */}
        <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Palette className="text-purple-600" size={20} />
              <span>Preferences</span>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Theme Settings */}
            <div>
              <Label className="text-base font-medium">Theme</Label>
              <Select value={preferences.theme} onValueChange={(value) => setPreferences({ ...preferences, theme: value })}>
                <SelectTrigger className="mt-2">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="light">Light Mode</SelectItem>
                  <SelectItem value="dark">Dark Mode</SelectItem>
                  <SelectItem value="system">System Default</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Separator />

            {/* Notification Settings */}
            <div>
              <Label className="text-base font-medium flex items-center space-x-2 mb-4">
                <Bell className="text-orange-600" size={16} />
                <span>Notifications</span>
              </Label>
              
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label className="font-medium">Push Notifications</Label>
                    <p className="text-sm text-slate-600">Receive notifications in the app</p>
                  </div>
                  <Switch
                    checked={preferences.notifications}
                    onCheckedChange={(checked) => setPreferences({ ...preferences, notifications: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label className="font-medium">Email Alerts</Label>
                    <p className="text-sm text-slate-600">Get important updates via email</p>
                  </div>
                  <Switch
                    checked={preferences.emailAlerts}
                    onCheckedChange={(checked) => setPreferences({ ...preferences, emailAlerts: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label className="font-medium">Sound Alerts</Label>
                    <p className="text-sm text-slate-600">Play sound for notifications</p>
                  </div>
                  <Switch
                    checked={preferences.soundAlerts}
                    onCheckedChange={(checked) => setPreferences({ ...preferences, soundAlerts: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label className="font-medium">Auto Refresh</Label>
                    <p className="text-sm text-slate-600">Automatically refresh data</p>
                  </div>
                  <Switch
                    checked={preferences.autoRefresh}
                    onCheckedChange={(checked) => setPreferences({ ...preferences, autoRefresh: checked })}
                  />
                </div>
              </div>
            </div>

            <Separator />

            {/* Language Settings */}
            <div>
              <Label className="text-base font-medium">Language</Label>
              <Select value={preferences.language} onValueChange={(value) => setPreferences({ ...preferences, language: value })}>
                <SelectTrigger className="mt-2">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="en">English</SelectItem>
                  <SelectItem value="es">Spanish</SelectItem>
                  <SelectItem value="fr">French</SelectItem>
                  <SelectItem value="de">German</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <Button 
              onClick={handlePreferencesUpdate}
              className="w-full bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700"
            >
              <Save size={16} className="mr-2" />
              Save Preferences
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Security Section */}
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Shield className="text-red-600" size={20} />
            <span>Security</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Button variant="outline" className="hover:bg-blue-50 hover:border-blue-200">
              Change Password
            </Button>
            <Button variant="outline" className="hover:bg-green-50 hover:border-green-200">
              Two-Factor Authentication
            </Button>
            <Button variant="outline" className="hover:bg-yellow-50 hover:border-yellow-200">
              Login History
            </Button>
            <Button variant="outline" className="hover:bg-purple-50 hover:border-purple-200">
              API Keys
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}