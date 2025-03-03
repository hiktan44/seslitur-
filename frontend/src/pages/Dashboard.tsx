import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Card,
  CardContent,
  CardActions,
  Button,
  Chip,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  Group as GroupIcon,
  Event as EventIcon,
  Mic as MicIcon,
  MicOff as MicOffIcon,
  ArrowForward as ArrowForwardIcon,
  Person as PersonIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

/**
 * Dashboard Sayfası
 * 
 * Kullanıcının ana sayfası, özet bilgileri ve hızlı erişim bağlantılarını içerir
 */
const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  
  // Örnek veriler
  const [userGroups, setUserGroups] = useState<any[]>([]);
  const [upcomingSessions, setUpcomingSessions] = useState<any[]>([]);
  const [activeSessions, setActiveSessions] = useState<any[]>([]);
  
  useEffect(() => {
    const fetchDashboardData = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          // Kullanıcının grupları
          setUserGroups([
            { id: '1', name: 'Yazılım Geliştirme', memberCount: 15 },
            { id: '2', name: 'Proje Yönetimi', memberCount: 8 },
            { id: '3', name: 'Pazarlama Stratejileri', memberCount: 12 },
          ]);
          
          // Yaklaşan oturumlar
          setUpcomingSessions([
            { 
              id: '1', 
              name: 'Haftalık Sprint Toplantısı', 
              groupName: 'Yazılım Geliştirme',
              startTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
              participantCount: 0,
              maxParticipants: 15
            },
            { 
              id: '2', 
              name: 'Ürün Tanıtımı', 
              groupName: 'Pazarlama Stratejileri',
              startTime: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
              participantCount: 0,
              maxParticipants: 25
            },
          ]);
          
          // Aktif oturumlar
          setActiveSessions([
            { 
              id: '3', 
              name: 'Müşteri Görüşmesi', 
              groupName: 'Proje Yönetimi',
              startTime: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
              participantCount: 8,
              maxParticipants: 10
            },
          ]);
          
          setLoading(false);
        }, 1000);
      } catch (error) {
        console.error('Dashboard verileri alınamadı:', error);
        setError('Veriler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchDashboardData();
  }, []);
  
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
        Hoş Geldiniz, {user?.firstName || 'Kullanıcı'}!
      </Typography>
      
      <Typography variant="subtitle1" color="text.secondary" paragraph>
        Sesli İletişim Platformu'nda bugün neler yapmak istersiniz?
      </Typography>
      
      <Grid container spacing={3}>
        {/* Aktif Oturumlar */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 2, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              <MicIcon sx={{ verticalAlign: 'middle', mr: 1 }} />
              Aktif Oturumlar
            </Typography>
            
            {activeSessions.length > 0 ? (
              <List>
                {activeSessions.map((session) => (
                  <ListItem key={session.id} divider>
                    <ListItemText
                      primary={session.name}
                      secondary={`${session.groupName} • ${session.participantCount}/${session.maxParticipants} katılımcı`}
                    />
                    <ListItemSecondaryAction>
                      <Button
                        variant="contained"
                        size="small"
                        color="primary"
                        onClick={() => navigate(`/sessions/${session.id}`)}
                        startIcon={<MicIcon />}
                      >
                        Katıl
                      </Button>
                    </ListItemSecondaryAction>
                  </ListItem>
                ))}
              </List>
            ) : (
              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Şu anda aktif oturum bulunmuyor.
              </Typography>
            )}
            
            <Box sx={{ mt: 2, textAlign: 'right' }}>
              <Button
                variant="outlined"
                size="small"
                onClick={() => navigate('/sessions')}
                endIcon={<ArrowForwardIcon />}
              >
                Tüm Oturumlar
              </Button>
            </Box>
          </Paper>
        </Grid>
        
        {/* Yaklaşan Oturumlar */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 2, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              <EventIcon sx={{ verticalAlign: 'middle', mr: 1 }} />
              Yaklaşan Oturumlar
            </Typography>
            
            {upcomingSessions.length > 0 ? (
              <List>
                {upcomingSessions.map((session) => (
                  <ListItem key={session.id} divider>
                    <ListItemText
                      primary={session.name}
                      secondary={`${session.groupName} • ${new Date(session.startTime).toLocaleString('tr-TR')}`}
                    />
                    <ListItemSecondaryAction>
                      <Button
                        variant="outlined"
                        size="small"
                        onClick={() => navigate(`/sessions/${session.id}`)}
                      >
                        Detaylar
                      </Button>
                    </ListItemSecondaryAction>
                  </ListItem>
                ))}
              </List>
            ) : (
              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Yaklaşan oturum bulunmuyor.
              </Typography>
            )}
            
            <Box sx={{ mt: 2, textAlign: 'right' }}>
              <Button
                variant="outlined"
                size="small"
                onClick={() => navigate('/sessions/create')}
                color="primary"
              >
                Yeni Oturum Oluştur
              </Button>
            </Box>
          </Paper>
        </Grid>
        
        {/* Gruplarım */}
        <Grid item xs={12}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              <GroupIcon sx={{ verticalAlign: 'middle', mr: 1 }} />
              Gruplarım
            </Typography>
            
            <Grid container spacing={2} sx={{ mt: 1 }}>
              {userGroups.length > 0 ? (
                userGroups.map((group) => (
                  <Grid item xs={12} sm={6} md={4} key={group.id}>
                    <Card>
                      <CardContent>
                        <Typography variant="h6" component="div">
                          {group.name}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          {group.memberCount} üye
                        </Typography>
                      </CardContent>
                      <CardActions>
                        <Button 
                          size="small" 
                          onClick={() => navigate(`/groups/${group.id}`)}
                        >
                          Detaylar
                        </Button>
                      </CardActions>
                    </Card>
                  </Grid>
                ))
              ) : (
                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">
                    Henüz bir gruba üye değilsiniz.
                  </Typography>
                </Grid>
              )}
            </Grid>
            
            <Box sx={{ mt: 3, textAlign: 'right' }}>
              <Button
                variant="contained"
                onClick={() => navigate('/groups/create')}
                sx={{ mr: 1 }}
              >
                Yeni Grup Oluştur
              </Button>
              <Button
                variant="outlined"
                onClick={() => navigate('/groups')}
                endIcon={<ArrowForwardIcon />}
              >
                Tüm Gruplar
              </Button>
            </Box>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard; 