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
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  Search as SearchIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Visibility as ViewIcon,
  Group as GroupIcon,
  Public as PublicIcon,
  Lock as LockIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { isAdmin } from '../../utils/auth.utils';

// Grup arayüzü
interface Group {
  id: string;
  name: string;
  description: string;
  memberCount: number;
  isPrivate: boolean;
  createdAt: string;
  createdBy: {
    id: string;
    name: string;
  };
}

/**
 * Admin Gruplar Sayfası
 * 
 * Sistem yöneticileri için grup yönetimi sayfası
 */
const AdminGroups: React.FC = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [groups, setGroups] = useState<Group[]>([]);
  const [filteredGroups, setFilteredGroups] = useState<Group[]>([]);
  const [searchTerm, setSearchTerm] = useState<string>('');
  
  // Sayfalama
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  
  // Dialog durumları
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedGroup, setSelectedGroup] = useState<Group | null>(null);
  
  // Sayfa yüklendiğinde grupları al
  useEffect(() => {
    const fetchGroups = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          const mockGroups: Group[] = [
            {
              id: '1',
              name: 'Yazılım Geliştirme',
              description: 'Yazılım geliştirme ekibi için grup',
              memberCount: 15,
              isPrivate: false,
              createdAt: '2023-01-15',
              createdBy: {
                id: '1',
                name: 'Ahmet Yılmaz',
              },
            },
            {
              id: '2',
              name: 'Proje Yönetimi',
              description: 'Proje yönetimi ekibi için grup',
              memberCount: 8,
              isPrivate: true,
              createdAt: '2023-02-10',
              createdBy: {
                id: '2',
                name: 'Ayşe Demir',
              },
            },
            {
              id: '3',
              name: 'Pazarlama Stratejileri',
              description: 'Pazarlama ekibi için grup',
              memberCount: 12,
              isPrivate: false,
              createdAt: '2023-03-05',
              createdBy: {
                id: '3',
                name: 'Mehmet Kaya',
              },
            },
            {
              id: '4',
              name: 'Müşteri İlişkileri',
              description: 'Müşteri ilişkileri ekibi için grup',
              memberCount: 6,
              isPrivate: true,
              createdAt: '2023-03-20',
              createdBy: {
                id: '4',
                name: 'Zeynep Şahin',
              },
            },
            {
              id: '5',
              name: 'Ürün Geliştirme',
              description: 'Ürün geliştirme ekibi için grup',
              memberCount: 10,
              isPrivate: false,
              createdAt: '2023-04-12',
              createdBy: {
                id: '5',
                name: 'Ali Öztürk',
              },
            },
          ];
          
          setGroups(mockGroups);
          setFilteredGroups(mockGroups);
          setLoading(false);
        }, 1000);
      } catch (error) {
        console.error('Gruplar alınamadı:', error);
        setError('Gruplar yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchGroups();
  }, []);
  
  // Arama işlemi
  useEffect(() => {
    const results = groups.filter(group => 
      group.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      group.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      group.createdBy.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredGroups(results);
    setPage(0);
  }, [searchTerm, groups]);
  
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
  const handleOpenDeleteDialog = (group: Group) => {
    setSelectedGroup(group);
    setDeleteDialogOpen(true);
  };
  
  // Silme dialogunu kapat
  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedGroup(null);
  };
  
  // Grubu sil
  const handleDeleteGroup = () => {
    if (selectedGroup) {
      // Gerçek uygulamada API'ye silme isteği gönder
      setGroups(prevGroups => prevGroups.filter(g => g.id !== selectedGroup.id));
      handleCloseDeleteDialog();
    }
  };
  
  // Grup detayına git
  const handleViewGroup = (groupId: string) => {
    navigate(`/groups/${groupId}`);
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
        Grup Yönetimi
      </Typography>
      
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <TextField
          label="Grup Ara"
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
          onClick={() => navigate('/groups/create')}
        >
          Yeni Grup
        </Button>
      </Box>
      
      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} aria-label="gruplar tablosu">
          <TableHead>
            <TableRow>
              <TableCell>Grup Adı</TableCell>
              <TableCell>Açıklama</TableCell>
              <TableCell>Üye Sayısı</TableCell>
              <TableCell>Tür</TableCell>
              <TableCell>Oluşturan</TableCell>
              <TableCell>Oluşturma Tarihi</TableCell>
              <TableCell align="right">İşlemler</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredGroups
              .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
              .map((group) => (
                <TableRow key={group.id}>
                  <TableCell component="th" scope="row">
                    {group.name}
                  </TableCell>
                  <TableCell>
                    {group.description.length > 50
                      ? `${group.description.substring(0, 50)}...`
                      : group.description}
                  </TableCell>
                  <TableCell>{group.memberCount}</TableCell>
                  <TableCell>
                    <Chip
                      icon={group.isPrivate ? <LockIcon /> : <PublicIcon />}
                      label={group.isPrivate ? 'Özel' : 'Açık'}
                      color={group.isPrivate ? 'secondary' : 'primary'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{group.createdBy.name}</TableCell>
                  <TableCell>{new Date(group.createdAt).toLocaleDateString('tr-TR')}</TableCell>
                  <TableCell align="right">
                    <IconButton
                      color="primary"
                      onClick={() => handleViewGroup(group.id)}
                      title="Grubu görüntüle"
                    >
                      <ViewIcon />
                    </IconButton>
                    <IconButton
                      color="error"
                      onClick={() => handleOpenDeleteDialog(group)}
                      title="Grubu sil"
                    >
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            {filteredGroups.length === 0 && (
              <TableRow>
                <TableCell colSpan={7} align="center">
                  Grup bulunamadı.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>
      
      <TablePagination
        rowsPerPageOptions={[5, 10, 25]}
        component="div"
        count={filteredGroups.length}
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
          Grubu Sil
        </DialogTitle>
        <DialogContent>
          <DialogContentText id="delete-dialog-description">
            {selectedGroup && (
              <>
                <strong>{selectedGroup.name}</strong> adlı grubu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve gruptaki tüm oturumlar da silinecektir.
              </>
            )}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDeleteDialog} color="primary">
            İptal
          </Button>
          <Button onClick={handleDeleteGroup} color="error" variant="contained">
            Sil
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AdminGroups; 