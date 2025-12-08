import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Search, Eye, Edit, Trash2, Plus, Loader2 } from 'lucide-react';
import { usersApi, User } from '@/lib/api';

const roleColors = {
  admin: 'bg-red-100 text-red-800 border-red-200',
  mechanic: 'bg-blue-100 text-blue-800 border-blue-200',
  customer: 'bg-green-100 text-green-800 border-green-200',
};

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit' | 'add'>('view');
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await usersApi.getAll();
      console.log("Users response:", response);
      const safeUsers = Array.isArray(response?.data) ? response.data : [];
      setUsers(safeUsers);
      setError(null);
    } catch (err) {
      setError('Failed to load users');
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const safeUsers = Array.isArray(users) ? users : [];
  console.log("Users data for filtering:", safeUsers);

  const filteredUsers = safeUsers.filter((user) => {
    const matchesSearch =
      (user.name?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
      (user.email?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
      (user.phone?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
      (user.country?.toLowerCase() || '').includes(searchTerm.toLowerCase());
    return matchesSearch;
  });

  const handleView = (user: User) => {
    setSelectedUser(user);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEdit = (user: User) => {
    setSelectedUser(user);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleAdd = () => {
    setSelectedUser(null);
    setModalMode('add');
    setIsModalOpen(true);
  };

  const handleSave = async (updatedUser: User) => {
    try {
      if (modalMode === 'add') {
        await usersApi.create(updatedUser);
      } else {
        await usersApi.update(updatedUser._id!, updatedUser);
      }
      await fetchUsers(); // Refresh the list
    } catch (err) {
      console.error('Error saving user:', err);
      alert('Failed to save user');
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await usersApi.delete(id);
      await fetchUsers(); // Refresh the list
    } catch (err) {
      console.error('Error deleting user:', err);
      alert('Failed to delete user');
    }
  };

  return (
    <>
      <Card className="shadow-xl border-0 bg-white/80 backdrop-blur-sm animate-in slide-in-from-bottom-4 fade-in">
        <CardHeader>
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
            <CardTitle className="flex items-center space-x-2">
              <span className="text-xl font-bold">User Management</span>
              <Badge variant="secondary" className="ml-2">
                {filteredUsers.length}
              </Badge>
            </CardTitle>

            <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={16} />
                <Input
                  placeholder="Search Users..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 w-full sm:w-64"
                />
              </div>

              <Button onClick={handleAdd} className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700">
                <Plus size={16} className="mr-2" />
                Add User
              </Button>
            </div>
          </div>
        </CardHeader>

        <CardContent>
          {loading && (
            <div className="flex justify-center items-center py-12">
              <Loader2 className="h-8 w-8 animate-spin" />
              <span className="ml-2">Loading users...</span>
            </div>
          )}
          {error && (
            <div className="text-center py-12">
              <p className="text-red-600">{error}</p>
              <Button onClick={fetchUsers} className="mt-4">
                Try Again
              </Button>
            </div>
          )}
          {!loading && !error && (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                   <TableRow>
                     <TableHead>Country</TableHead>
                     <TableHead>Email</TableHead>
                     <TableHead className="hidden md:table-cell">Phone</TableHead>
                     <TableHead className="hidden sm:table-cell">Role</TableHead>
                     <TableHead className="hidden xl:table-cell">Created Date</TableHead>
                     <TableHead>Actions</TableHead>
                   </TableRow>
                 </TableHeader>
                <TableBody>
                  {filteredUsers.map((user) => (
                    <TableRow key={user._id} className="hover:bg-slate-50 transition-colors">
                      <TableCell className="font-medium">{user.country || '-'}</TableCell>
                      <TableCell>{user.email || '-'}</TableCell>
                      <TableCell className="hidden md:table-cell">{user.phone || '-'}</TableCell>
                      <TableCell className="hidden sm:table-cell">
                        <Badge className={roleColors[user.role] || roleColors.customer}>
                          {user.role?.replace('-', ' ') || 'customer'}
                        </Badge>
                      </TableCell>
                      <TableCell className="hidden xl:table-cell">
                        {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : '-'}
                      </TableCell>
                      <TableCell>
                        <div className="flex space-x-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleView(user)}
                            className="h-8 w-8 p-0 hover:bg-blue-100"
                          >
                            <Eye size={14} className="text-blue-600" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleEdit(user)}
                            className="h-8 w-8 p-0 hover:bg-green-100"
                          >
                            <Edit size={14} className="text-green-600" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(user._id!)}
                            className="h-8 w-8 p-0 hover:bg-red-100"
                          >
                            <Trash2 size={14} className="text-red-600" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {filteredUsers.length === 0 && (
                <div className="text-center py-12">
                  <div className="text-slate-400 mb-4">
                    <Search size={48} className="mx-auto" />
                  </div>
                  <p className="text-slate-600">No users found matching your criteria</p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </>
  );
}