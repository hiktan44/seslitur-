import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TablePagination,
  IconButton,
  Button,
  TextField,
  InputAdornment,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  DialogTitle,
  FormControlLabel,
  Switch,
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  Search as SearchIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  AdminPanelSettings as AdminIcon,
  Person as PersonIcon,
} from '@mui/icons-material';
import { useAuth } from '../../contexts/AuthContext';
import { isAdmin } from '../../utils/auth.utils';

// Kullanıcı arayüzü
interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  isAdmin: boolean;
  createdAt: string;
  lastLogin?: string;
}

/**
 * Admin Kullanıcılar Sayfası
 * 
 * Sistem yöneticileri için kullanıcı yönetimi sayfası
 */
const AdminUsers: React.FC = () => {
  const { user } = useAuth();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState<string>('');
  
  // Sayfalama
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  
  // Dialog durumları
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [adminDialogOpen, setAdminDialogOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  
  // Sayfa yüklendiğinde kullanıcıları al
  useEffect(() => {
    const fetchUsers = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          const mockUsers: User[] = [
            {
              id: '1',
              firstName: 'Ahmet',
              lastName: 'Yılmaz',
              email: 'ahmet@example.com',
              isAdmin: true,
              createdAt: '2023-01-15',
              lastLogin: '2023-05-20',
            },
            {
              id: '2',
              firstName: 'Ayşe',
              lastName: 'Demir',
              email: 'ayse@example.com',
              isAdmin: false,
              createdAt: '2023-02-10',
              lastLogin: '2023-05-18',
            },
            {
              id: '3',
              firstName: 'Mehmet',
              lastName: 'Kaya',
              email: 'mehmet@example.com',
              isAdmin: false,
              createdAt: '2023-03-05',
              lastLogin: '2023-05-15',
            },
            {
              id: '4',
              firstName: 'Zeynep',
              lastName: 'Şahin',
              email: 'zeynep@example.com',
              isAdmin: false,
              createdAt: '2023-03-20',
              lastLogin: '2023-05-10',
            },
            {
              id: '5',
              firstName: 'Ali',
              lastName: 'Öztürk',
              email: 'ali@example.com',
              isAdmin: false,
              createdAt: '2023-04-12',
              lastLogin: '2023-05-05',
            },
          ];
          
          setUsers(mockUsers);
          setFilteredUsers(mockUsers);
          setLoading(false);
        }, 1000);
      } catch (error) {
        console.error('Kullanıcılar alınamadı:', error);
        setError('Kullanıcılar yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchUsers();
  }, []);
  
  // Arama işlemi
  useEffect(() => {
    const results = users.filter(user => 
      user.firstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.lastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredUsers(results);
    setPage(0);
  }, [searchTerm, users]);
  
  // Sayfa değişimi
  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };
  
  // Sayfa başına satır sayısı değişimi
  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };
  
  // Silme dialogunu aç
  const handleOpenDeleteDialog = (user: User) => {
    setSelectedUser(user);
    setDeleteDialogOpen(true);
  };
  
  // Silme dialogunu kapat
  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedUser(null);
  };
  
  // Admin dialogunu aç
  const handleOpenAdminDialog = (user: User) => {
    setSelectedUser(user);
    setAdminDialogOpen(true);
  };
  
  // Admin dialogunu kapat
  const handleCloseAdminDialog = () => {
    setAdminDialogOpen(false);
    setSelectedUser(null);
  };
  
  // Kullanıcıyı sil
  const handleDeleteUser = () => {
    if (selectedUser) {
      // Gerçek uygulamada API'ye silme isteği gönder
      setUsers(prevUsers => prevUsers.filter(u => u.id !== selectedUser.id));
      handleCloseDeleteDialog();
    }
  };
  
  // Admin yetkisi değiştir
  const handleToggleAdmin = () => {
    if (selectedUser) {
      // Gerçek uygulamada API'ye güncelleme isteği gönder
      setUsers(prevUsers => 
        prevUsers.map(u => 
          u.id === selectedUser.id ? { ...u, isAdmin: !u.isAdmin } : u
        )
      );
      handleCloseAdminDialog();
    }
  };
  
  // Admin değilse erişim engellendi mesajı göster
  if (!isAdmin(user)) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          Bu sayfaya erişim yetkiniz bulunmamaktadır. Sadece admin kullanıcılar erişebilir.
        </Alert>
      </Box>
    );
  }
  
  // Yükleniyor durumu
  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
        <CircularProgress />
      </Box>
    );
  }
  
  // Hata durumu
  if (error) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">{error}</Alert>
      </Box>
    );
  }
  
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Kullanıcı Yönetimi
      </Typography>
      
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <TextField
          label="Kullanıcı Ara"
          variant="outlined"
          size="small"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon />
              </InputAdornment>
            ),
          }}
          sx={{ width: 300 }}
        />
        
        <Button
          variant="contained"
          color="primary"
          startIcon={<AddIcon />}
          onClick={() => alert('Yeni kullanıcı ekleme özelliği henüz eklenmedi.')}
        >
          Yeni Kullanıcı
        </Button>
      </Box>
      
      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} aria-label="kullanıcılar tablosu">
          <TableHead>
            <TableRow>
              <TableCell>Ad Soyad</TableCell>
              <TableCell>E-posta</TableCell>
              <TableCell>Rol</TableCell>
              <TableCell>Kayıt Tarihi</TableCell>
              <TableCell>Son Giriş</TableCell>
              <TableCell align="right">İşlemler</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredUsers
              .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
              .map((user) => (
                <TableRow key={user.id}>
                  <TableCell component="th" scope="row">
                    {user.firstName} {user.lastName}
                  </TableCell>
                  <TableCell>{user.email}</TableCell>
                  <TableCell>
                    <Chip
                      icon={user.isAdmin ? <AdminIcon /> : <PersonIcon />}
                      label={user.isAdmin ? 'Admin' : 'Kullanıcı'}
                      color={user.isAdmin ? 'primary' : 'default'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{new Date(user.createdAt).toLocaleDateString('tr-TR')}</TableCell>
                  <TableCell>
                    {user.lastLogin ? new Date(user.lastLogin).toLocaleDateString('tr-TR') : '-'}
                  </TableCell>
                  <TableCell align="right">
                    <IconButton
                      color="primary"
                      onClick={() => handleOpenAdminDialog(user)}
                      title={user.isAdmin ? 'Admin yetkisini kaldır' : 'Admin yetkisi ver'}
                    >
                      <AdminIcon />
                    </IconButton>
                    <IconButton
                      color="error"
                      onClick={() => handleOpenDeleteDialog(user)}
                      title="Kullanıcıyı sil"
                    >
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            {filteredUsers.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  Kullanıcı bulunamadı.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>
      
      <TablePagination
        rowsPerPageOptions={[5, 10, 25]}
        component="div"
        count={filteredUsers.length}
        rowsPerPage={rowsPerPage}
        page={page}
        onPageChange={handleChangePage}
        onRowsPerPageChange={handleChangeRowsPerPage}
        labelRowsPerPage="Sayfa başına satır:"
        labelDisplayedRows={({ from, to, count }) => `${from}-${to} / ${count}`}
      />
      
      {/* Silme Dialog */}
      <Dialog
        open={deleteDialogOpen}
        onClose={handleCloseDeleteDialog}
        aria-labelledby="delete-dialog-title"
        aria-describedby="delete-dialog-description"
      >
        <DialogTitle id="delete-dialog-title">
          Kullanıcıyı Sil
        </DialogTitle>
        <DialogContent>
          <DialogContentText id="delete-dialog-description">
            {selectedUser && (
              <>
                <strong>{selectedUser.firstName} {selectedUser.lastName}</strong> adlı kullanıcıyı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.
              </>
            )}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDeleteDialog} color="primary">
            İptal
          </Button>
          <Button onClick={handleDeleteUser} color="error" variant="contained">
            Sil
          </Button>
        </DialogActions>
      </Dialog>
      
      {/* Admin Dialog */}
      <Dialog
        open={adminDialogOpen}
        onClose={handleCloseAdminDialog}
        aria-labelledby="admin-dialog-title"
        aria-describedby="admin-dialog-description"
      >
        <DialogTitle id="admin-dialog-title">
          Admin Yetkisi Değiştir
        </DialogTitle>
        <DialogContent>
          <DialogContentText id="admin-dialog-description">
            {selectedUser && (
              <>
                <strong>{selectedUser.firstName} {selectedUser.lastName}</strong> adlı kullanıcının admin yetkisini {selectedUser.isAdmin ? 'kaldırmak' : 'vermek'} istediğinizden emin misiniz?
              </>
            )}
          </DialogContentText>
          {selectedUser && (
            <FormControlLabel
              control={
                <Switch
                  checked={selectedUser.isAdmin}
                  onChange={() => {
                    if (selectedUser) {
                      setSelectedUser({ ...selectedUser, isAdmin: !selectedUser.isAdmin });
                    }
                  }}
                  color="primary"
                />
              }
              label={selectedUser.isAdmin ? 'Admin' : 'Kullanıcı'}
            />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAdminDialog} color="primary">
            İptal
          </Button>
          <Button onClick={handleToggleAdmin} color="primary" variant="contained">
            Kaydet
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AdminUsers; 