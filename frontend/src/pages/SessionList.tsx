import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CardActions,
  Button,
  TextField,
  InputAdornment,
  Chip,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  Search as SearchIcon,
  Add as AddIcon,
  Event as EventIcon,
  PlayArrow as ActiveIcon,
  Schedule as ScheduledIcon,
  CheckCircle as CompletedIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';

// Oturum durumu
enum SessionStatus {
  SCHEDULED = 'SCHEDULED',
  ACTIVE = 'ACTIVE',
  COMPLETED = 'COMPLETED',
}

/**
 * Oturumlar Sayfası
 * 
 * Kullanıcının katılabileceği oturumları listeler
 */
const SessionList: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');
  
  // Örnek veriler
  const [sessions, setSessions] = useState<any[]>([]);
  const [filteredSessions, setFilteredSessions] = useState<any[]>([]);
  
  // Oturumları yükle
  useEffect(() => {
    const fetchSessions = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          const mockSessions = [
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
        setError('Veriler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchSessions();
  }, []);
  
  // Arama işlemi
  useEffect(() => {
    if (searchTerm.trim() === '') {
      setFilteredSessions(sessions);
    } else {
      const filtered = sessions.filter(session => 
        session.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        session.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
        session.groupName.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredSessions(filtered);
    }
  }, [searchTerm, sessions]);
  
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
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">Oturumlar</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/sessions/create')}
        >
          Yeni Oturum Oluştur
        </Button>
      </Box>
      
      <TextField
        fullWidth
        variant="outlined"
        placeholder="Oturum ara..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        sx={{ mb: 3 }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SearchIcon />
            </InputAdornment>
          ),
        }}
      />
      
      {filteredSessions.length === 0 ? (
        <Alert severity="info">
          Arama kriterlerinize uygun oturum bulunamadı.
        </Alert>
      ) : (
        <Grid container spacing={3}>
          {filteredSessions.map((session) => (
            <Grid item xs={12} sm={6} md={4} key={session.id}>
              <Card>
                <CardContent>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                    <Typography variant="h6" component="div">
                      {session.name}
                    </Typography>
                    {renderStatusChip(session.status)}
                  </Box>
                  <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                    {session.description}
                  </Typography>
                  <Typography variant="body2" sx={{ mb: 1 }}>
                    <EventIcon fontSize="small" sx={{ verticalAlign: 'middle', mr: 0.5 }} />
                    {new Date(session.startTime).toLocaleString('tr-TR')}
                  </Typography>
                  <Typography variant="body2">
                    Grup: {session.groupName} • {session.participantCount}/{session.maxParticipants} katılımcı
                  </Typography>
                </CardContent>
                <CardActions>
                  {session.status === SessionStatus.ACTIVE ? (
                    <Button 
                      size="small" 
                      variant="contained" 
                      color="primary"
                      onClick={() => navigate(`/sessions/${session.id}`)}
                      startIcon={<ActiveIcon />}
                    >
                      Katıl
                    </Button>
                  ) : (
                    <Button 
                      size="small" 
                      onClick={() => navigate(`/sessions/${session.id}`)}
                    >
                      Detaylar
                    </Button>
                  )}
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}
    </Box>
  );
};

export default SessionList; 