import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Car, Save, Loader2, DollarSign } from 'lucide-react';

interface DetailingPlans {
  basicPrice: number;
  standardPrice: number;
  premiumPrice: number;
  basicDescription: string;
  standardDescription: string;
  premiumDescription: string;
}

export default function DetailingServiceManager() {
  const [plans, setPlans] = useState<DetailingPlans>({
    basicPrice: 50,
    standardPrice: 100,
    premiumPrice: 200,
    basicDescription: 'Exterior cleaning only',
    standardDescription: 'Exterior + interior cleaning',
    premiumDescription: 'Full detailing (exterior, interior, waxing, vacuuming, polishing, etc.)'
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchDetailingPlans();
  }, []);

  const fetchDetailingPlans = async () => {
    try {
      setLoading(true);
      const response = await fetch('https://autorevop-backend.onrender.com/api/services/detailing-plans', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`,
        },
      });
      if (!response.ok) throw new Error('Failed to fetch detailing plans');
      const data = await response.json();
      
      // Handle both old and new response formats
      if (data.success !== undefined) {
        // New format with success field
        setPlans({
          basicPrice: data.basicPrice,
          standardPrice: data.standardPrice,
          premiumPrice: data.premiumPrice,
          basicDescription: data.basicDescription,
          standardDescription: data.standardDescription,
          premiumDescription: data.premiumDescription
        });
      } else {
        // Old format (direct data)
        setPlans(data);
      }
      setError(null);
    } catch (err) {
      setError('Failed to load detailing plans');
      console.error('Error fetching detailing plans:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      const response = await fetch('https://autorevop-backend.onrender.com/api/services/detailing-plans', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`,
        },
        body: JSON.stringify(plans),
      });

      if (!response.ok) throw new Error('Failed to update detailing plans');

      const updatedPlans = await response.json();
      setPlans(updatedPlans);
      alert('Detailing plans updated successfully!');
    } catch (err) {
      console.error('Error updating detailing plans:', err);
      alert('Failed to update detailing plans');
    } finally {
      setSaving(false);
    }
  };

  const updatePlan = (field: keyof DetailingPlans, value: string | number) => {
    setPlans(prev => ({
      ...prev,
      [field]: value
    }));
  };

  if (loading) {
    return (
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardContent className="flex justify-center items-center py-12">
          <Loader2 className="h-8 w-8 animate-spin" />
          <span className="ml-2">Loading detailing plans...</span>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm">
        <CardContent className="text-center py-12">
          <p className="text-red-600">{error}</p>
          <Button onClick={fetchDetailingPlans} className="mt-4">
            Try Again
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm animate-in slide-in-from-bottom-4 fade-in">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <Car className="text-blue-600" size={24} />
          <span className="text-xl font-bold">Detailing Service Plans</span>
        </CardTitle>
        <p className="text-sm text-slate-600">
          Configure pricing and descriptions for detailing service plans
        </p>
      </CardHeader>

      <CardContent className="space-y-6">

        {/* Basic Plan */}
        <Card className="border-green-200 bg-green-50">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg text-green-800">Basic Plan</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="basicPrice">Price</Label>
                <div className="relative">
                  <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="basicPrice"
                    type="number"
                    step="0.01"
                    value={plans.basicPrice}
                    onChange={(e) => updatePlan('basicPrice', parseFloat(e.target.value) || 0)}
                    className="pl-10"
                    placeholder="0.00"
                  />
                </div>
              </div>
              <div className="flex items-end">
                <span className="text-sm text-slate-600 bg-white px-3 py-2 rounded border">
                  {plans.basicPrice.toFixed(2)} USD
                </span>
              </div>
            </div>
            <div>
              <Label htmlFor="basicDescription">Description</Label>
              <Textarea
                id="basicDescription"
                value={plans.basicDescription}
                onChange={(e) => updatePlan('basicDescription', e.target.value)}
                placeholder="Describe what's included in the basic plan"
                rows={2}
              />
            </div>
          </CardContent>
        </Card>

        {/* Standard Plan */}
        <Card className="border-blue-200 bg-blue-50">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg text-blue-800">Standard Plan</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="standardPrice">Price</Label>
                <div className="relative">
                  <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="standardPrice"
                    type="number"
                    step="0.01"
                    value={plans.standardPrice}
                    onChange={(e) => updatePlan('standardPrice', parseFloat(e.target.value) || 0)}
                    className="pl-10"
                    placeholder="0.00"
                  />
                </div>
              </div>
              <div className="flex items-end">
                <span className="text-sm text-slate-600 bg-white px-3 py-2 rounded border">
                  {plans.standardPrice.toFixed(2)} USD
                </span>
              </div>
            </div>
            <div>
              <Label htmlFor="standardDescription">Description</Label>
              <Textarea
                id="standardDescription"
                value={plans.standardDescription}
                onChange={(e) => updatePlan('standardDescription', e.target.value)}
                placeholder="Describe what's included in the standard plan"
                rows={2}
              />
            </div>
          </CardContent>
        </Card>

        {/* Premium Plan */}
        <Card className="border-purple-200 bg-purple-50">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg text-purple-800">Premium Plan</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="premiumPrice">Price</Label>
                <div className="relative">
                  <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="premiumPrice"
                    type="number"
                    step="0.01"
                    value={plans.premiumPrice}
                    onChange={(e) => updatePlan('premiumPrice', parseFloat(e.target.value) || 0)}
                    className="pl-10"
                    placeholder="0.00"
                  />
                </div>
              </div>
              <div className="flex items-end">
                <span className="text-sm text-slate-600 bg-white px-3 py-2 rounded border">
                  {plans.premiumPrice.toFixed(2)} USD
                </span>
              </div>
            </div>
            <div>
              <Label htmlFor="premiumDescription">Description</Label>
              <Textarea
                id="premiumDescription"
                value={plans.premiumDescription}
                onChange={(e) => updatePlan('premiumDescription', e.target.value)}
                placeholder="Describe what's included in the premium plan"
                rows={2}
              />
            </div>
          </CardContent>
        </Card>

        {/* Save Button */}
        <div className="flex justify-end pt-4">
          <Button 
            onClick={handleSave} 
            disabled={saving}
            className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700"
          >
            {saving ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="mr-2 h-4 w-4" />
                Save Changes
              </>
            )}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}