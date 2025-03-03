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
  Event as EventIcon,
  PlayArrow as ActiveIcon,
  Schedule as ScheduledIcon,
  CheckCircle as CompletedIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { isAdmin } from '../../utils/auth.utils';

// Oturum durumu
enum SessionStatus {
  SCHEDULED = 'SCHEDULED',
  ACTIVE = 'ACTIVE',
  COMPLETED = 'COMPLETED',
}

// Oturum arayüzü
interface Session {
  id: string;
  name: string;
  description: string;
  groupId: string;
  groupName: string;
  status: SessionStatus;
  participantCount: number;
  maxParticipants: number;
  startTime: string;
  endTime?: string;
  createdBy: {
    id: string;
    name: string;
  };
}

/**
 * Admin Oturumlar Sayfası
 * 
 * Sistem yöneticileri için oturum yönetimi sayfası
 */
const AdminSessions: React.FC = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [sessions, setSessions] = useState<Session[]>([]);
  const [filteredSessions, setFilteredSessions] = useState<Session[]>([]);
  const [searchTerm, setSearchTerm] = useState<string>('');
  
  // Sayfalama
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  
  // Dialog durumları
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedSession, setSelectedSession] = useState<Session | null>(null);
  
  // Sayfa yüklendiğinde oturumları al
  useEffect(() => {
    const fetchSessions = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          const mockSessions: Session[] = [
            {
              id: '1',
              name: 'Haftalık Sprint Toplantısı',
              description: 'Haftalık sprint değerlendirme toplantısı',
              groupId: '1',
              groupName: 'Yazılım Geliştirme',
              status: SessionStatus.SCHEDULED,
              participantCount: 0,
              maxParticipants: 15,
              startTime: '2023-06-01T10:00:00',
              createdBy: {
                id: '1',
                name: 'Ahmet Yılmaz',
              },
            },
            {
              id: '2',
              name: 'Ürün Tanıtımı',
              description: 'Yeni ürün tanıtım toplantısı',
              groupId: '2',
              groupName: 'Pazarlama Stratejileri',
              status: SessionStatus.ACTIVE,
              participantCount: 8,
              maxParticipants: 25,
              startTime: '2023-05-28T14:00:00',
              createdBy: {
                id: '2',
                name: 'Ayşe Demir',
              },
            },
            {
              id: '3',
              name: 'Eğitim Oturumu',
              description: 'Yeni teknolojiler hakkında eğitim',
              groupId: '1',
              groupName: 'Yazılım Geliştirme',
              status: SessionStatus.COMPLETED,
              participantCount: 12,
              maxParticipants: 20,
              startTime: '2023-05-20T09:00:00',
              endTime: '2023-05-20T11:00:00',
              createdBy: {
                id: '3',
                name: 'Mehmet Kaya',
              },
            },
            {
              id: '4',
              name: 'Müşteri Görüşmesi',
              description: 'Önemli müşteri ile görüşme',
              groupId: '4',
              groupName: 'Müşteri İlişkileri',
              status: SessionStatus.SCHEDULED,
              participantCount: 0,
              maxParticipants: 10,
              startTime: '2023-06-05T15:00:00',
              createdBy: {
                id: '4',
                name: 'Zeynep Şahin',
              },
            },
            {
              id: '5',
              name: 'Proje Planlama',
              description: 'Yeni proje planlama toplantısı',
              groupId: '2',
              groupName: 'Proje Yönetimi',
              status: SessionStatus.COMPLETED,
              participantCount: 8,
              maxParticipants: 10,
              startTime: '2023-05-15T13:00:00',
              endTime: '2023-05-15T15:00:00',
              createdBy: {
                id: '5',
                name: 'Ali Öztürk',
              },
            },
          ];
          
          setSessions(mockSessions);
          setFilteredSessions(mockSessions);
          setLoading(false);
        }, 1000);
      } catch (error) {
        console.error('Oturumlar alınamadı:', error);
        setError('Oturumlar yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchSessions();
  }, []);
  
  // Arama işlemi
  useEffect(() => {
    const results = sessions.filter(session => 
      session.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      session.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      session.groupName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      session.createdBy.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredSessions(results);
    setPage(0);
  }, [searchTerm, sessions]);
  
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
  const handleOpenDeleteDialog = (session: Session) => {
    setSelectedSession(session);
    setDeleteDialogOpen(true);
  };
  
  // Silme dialogunu kapat
  const handleCloseDeleteDialog = () => {
    setDeleteDialogOpen(false);
    setSelectedSession(null);
  };
  
  // Oturumu sil
  const handleDeleteSession = () => {
    if (selectedSession) {
      // Gerçek uygulamada API'ye silme isteği gönder
      setSessions(prevSessions => prevSessions.filter(s => s.id !== selectedSession.id));
      handleCloseDeleteDialog();
    }
  };
  
  // Oturum detayına git
  const handleViewSession = (sessionId: string) => {
    navigate(`/sessions/${sessionId}`);
  };
  
  // Durum çipi render et
  const renderStatusChip = (status: SessionStatus) => {
    switch (status) {
      case SessionStatus.SCHEDULED:
        return (
          <Chip
            icon={<ScheduledIcon />}
            label="Planlandı"
            color="info"
            size="small"
          />
        );
      case SessionStatus.ACTIVE:
        return (
          <Chip
            icon={<ActiveIcon />}
            label="Aktif"
            color="success"
            size="small"
          />
        );
      case SessionStatus.COMPLETED:
        return (
          <Chip
            icon={<CompletedIcon />}
            label="Tamamlandı"
            color="default"
            size="small"
          />
        );
      default:
        return null;
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
        Oturum Yönetimi
      </Typography>
      
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <TextField
          label="Oturum Ara"
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
          onClick={() => navigate('/sessions/create')}
        >
          Yeni Oturum
        </Button>
      </Box>
      
      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} aria-label="oturumlar tablosu">
          <TableHead>
            <TableRow>
              <TableCell>Oturum Adı</TableCell>
              <TableCell>Grup</TableCell>
              <TableCell>Durum</TableCell>
              <TableCell>Katılımcı</TableCell>
              <TableCell>Başlangıç Zamanı</TableCell>
              <TableCell>Oluşturan</TableCell>
              <TableCell align="right">İşlemler</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredSessions
              .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
              .map((session) => (
                <TableRow key={session.id}>
                  <TableCell component="th" scope="row">
                    {session.name}
                  </TableCell>
                  <TableCell>{session.groupName}</TableCell>
                  <TableCell>{renderStatusChip(session.status)}</TableCell>
                  <TableCell>
                    {session.participantCount} / {session.maxParticipants}
                  </TableCell>
                  <TableCell>
                    {new Date(session.startTime).toLocaleString('tr-TR')}
                  </TableCell>
                  <TableCell>{session.createdBy.name}</TableCell>
                  <TableCell align="right">
                    <IconButton
                      color="primary"
                      onClick={() => handleViewSession(session.id)}
                      title="Oturumu görüntüle"
                    >
                      <ViewIcon />
                    </IconButton>
                    <IconButton
                      color="error"
                      onClick={() => handleOpenDeleteDialog(session)}
                      title="Oturumu sil"
                      disabled={session.status === SessionStatus.ACTIVE}
                    >
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            {filteredSessions.length === 0 && (
              <TableRow>
                <TableCell colSpan={7} align="center">
                  Oturum bulunamadı.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>
      
      <TablePagination
        rowsPerPageOptions={[5, 10, 25]}
        component="div"
        count={filteredSessions.length}
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
          Oturumu Sil
        </DialogTitle>
        <DialogContent>
          <DialogContentText id="delete-dialog-description">
            {selectedSession && (
              <>
                <strong>{selectedSession.name}</strong> adlı oturumu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.
              </>
            )}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDeleteDialog} color="primary">
            İptal
          </Button>
          <Button onClick={handleDeleteSession} color="error" variant="contained">
            Sil
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AdminSessions; 