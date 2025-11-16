import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Eye, EyeOff, Lock, Mail, AlertCircle } from 'lucide-react';
import { adminApi } from '@/lib/api';

interface SignInPageProps {
  onSignIn: (credentials: { email: string; password: string }) => void;
}

export default function SignInPage({ onSignIn }: SignInPageProps) {
  const [credentials, setCredentials] = useState({
    email: '',
    password: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    // Simple validation
    if (!credentials.email || !credentials.password) {
      setError('Please fill in all fields');
      setIsLoading(false);
      return;
    }

    try {
      console.log("Attempting login with:", credentials.email);
      const data = await adminApi.login(credentials.email, credentials.password);
      console.log("Login response:", data);

      // Store the token
      localStorage.setItem('adminToken', data.token);
      console.log("Token stored, calling onSignIn");
      onSignIn(credentials);
    } catch (error) {
      console.error("Login error:", error);
      setError(error.message || 'Network error. Please check if the server is running.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-900 to-purple-900 p-6">
      <div className="w-full max-w-md">
        <div className="text-center mb-8 animate-in slide-in-from-top-4 fade-in">
          <img src="/ic_launcher.png" className="w-16 h-16 mb-1 object-contain mx-auto" alt="Auto RevOp Logo" />
          <h1 className="text-3xl font-bold text-white mb-2">Auto RevOp</h1>
          <p className="text-blue-200">Sign in to access the dashboard</p>
        </div>

        <Card className="shadow-2xl border-0 bg-white/10 backdrop-blur-md animate-in slide-in-from-bottom-4 fade-in" style={{ animationDelay: '200ms' }}>
          <CardHeader className="text-center pb-2">
            <CardTitle className="text-2xl text-white">Welcome Back</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <Label htmlFor="email" className="text-white">Email Address</Label>
                <div className="relative mt-1">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="email"
                    type="email"
                    value={credentials.email}
                    onChange={(e) => setCredentials({ ...credentials, email: e.target.value })}
                    placeholder="admin@repairhub.com"
                    className="pl-10 bg-white/20 border-white/30 text-white placeholder:text-slate-300"
                    disabled={isLoading}
                  />
                </div>
              </div>

              <div>
                <Label htmlFor="password" className="text-white">Password</Label>
                <div className="relative mt-1">
                  <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    value={credentials.password}
                    onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                    placeholder="Enter your password"
                    className="pl-10 pr-10 bg-white/20 border-white/30 text-white placeholder:text-slate-300"
                    disabled={isLoading}
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-1 top-1/2 transform -translate-y-1/2 h-8 w-8 p-0 text-slate-400 hover:text-white"
                    disabled={isLoading}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </Button>
                </div>
              </div>

              {error && (
                <Alert className="bg-red-500/20 border-red-500/50 animate-in slide-in-from-top-2 fade-in">
                  <AlertCircle className="h-4 w-4 text-red-400" />
                  <AlertDescription className="text-red-200">
                    {error}
                  </AlertDescription>
                </Alert>
              )}

              <Button
                type="submit"
                className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-semibold py-3"
                disabled={isLoading}
              >
                {isLoading ? (
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    <span>Signing in...</span>
                  </div>
                ) : (
                  'Sign In'
                )}
              </Button>
            </form>
          </CardContent>
        </Card>

        <div className="text-center mt-6 text-blue-200 text-sm animate-in slide-in-from-bottom-2 fade-in" style={{ animationDelay: '400ms' }}>
          <p>© 2025 Auto Revop. All rights reserved.</p>
        </div>
      </div>
    </div>
  );
}