import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Card,
  CardContent,
  CardHeader,
  Divider,
  List,
  ListItem,
  ListItemText,
  ListItemAvatar,
  Avatar,
  CircularProgress,
  Alert,
} from '@mui/material';
import {
  Group as GroupIcon,
  Person as PersonIcon,
  Event as EventIcon,
  Mic as MicIcon,
} from '@mui/icons-material';
import { useAuth } from '../../contexts/AuthContext';
import { isAdmin } from '../../utils/auth.utils';

// İstatistik kartı arayüzü
interface StatCardProps {
  title: string;
  value: number | string;
  icon: React.ReactNode;
  color: string;
}

// İstatistik kartı bileşeni
const StatCard: React.FC<StatCardProps> = ({ title, value, icon, color }) => (
  <Card sx={{ height: '100%' }}>
    <CardContent>
      <Grid container spacing={2} alignItems="center">
        <Grid item>
          <Avatar sx={{ bgcolor: color, width: 56, height: 56 }}>
            {icon}
          </Avatar>
        </Grid>
        <Grid item xs>
          <Typography variant="h5" component="div">
            {value}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {title}
          </Typography>
        </Grid>
      </Grid>
    </CardContent>
  </Card>
);

/**
 * Admin Dashboard Sayfası
 * 
 * Sistem yöneticileri için genel istatistikleri ve özet bilgileri gösterir
 */
const AdminDashboard: React.FC = () => {
  const { user } = useAuth();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  
  // İstatistik verileri
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalGroups: 0,
    totalSessions: 0,
    activeUsers: 0,
    recentUsers: [] as Array<{
      id: string;
      name: string;
      email: string;
      createdAt: string;
    }>,
    recentGroups: [] as Array<{
      id: string;
      name: string;
      memberCount: number;
      createdAt: string;
    }>,
    recentSessions: [] as Array<{
      id: string;
      name: string;
      participantCount: number;
      startTime: string;
    }>,
  });
  
  // Sayfa yüklendiğinde istatistikleri al
  useEffect(() => {
    const fetchStats = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          setStats({
            totalUsers: 125,
            totalGroups: 48,
            totalSessions: 87,
            activeUsers: 32,
            recentUsers: [
              { id: '1', name: 'Ahmet Yılmaz', email: 'ahmet@example.com', createdAt: '2023-05-15' },
              { id: '2', name: 'Ayşe Demir', email: 'ayse@example.com', createdAt: '2023-05-14' },
              { id: '3', name: 'Mehmet Kaya', email: 'mehmet@example.com', createdAt: '2023-05-13' },
            ],
            recentGroups: [
              { id: '1', name: 'Yazılım Geliştirme', memberCount: 15, createdAt: '2023-05-15' },
              { id: '2', name: 'Proje Yönetimi', memberCount: 8, createdAt: '2023-05-14' },
              { id: '3', name: 'Pazarlama Stratejileri', memberCount: 12, createdAt: '2023-05-13' },
            ],
            recentSessions: [
              { id: '1', name: 'Haftalık Sprint Toplantısı', participantCount: 12, startTime: '2023-05-20T10:00:00' },
              { id: '2', name: 'Ürün Tanıtımı', participantCount: 25, startTime: '2023-05-21T14:00:00' },
              { id: '3', name: 'Eğitim Oturumu', participantCount: 18, startTime: '2023-05-22T09:00:00' },
            ],
          });
          setLoading(false);
        }, 1000);
      } catch (error) {
        console.error('İstatistik verileri alınamadı:', error);
        setError('İstatistik verileri yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchStats();
  }, []);
  
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
        Admin Paneli
      </Typography>
      
      <Typography variant="subtitle1" color="text.secondary" paragraph>
        Sistem istatistikleri ve özet bilgiler
      </Typography>
      
      {/* İstatistik Kartları */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Toplam Kullanıcı"
            value={stats.totalUsers}
            icon={<PersonIcon />}
            color="#1976d2"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Toplam Grup"
            value={stats.totalGroups}
            icon={<GroupIcon />}
            color="#2e7d32"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Toplam Oturum"
            value={stats.totalSessions}
            icon={<EventIcon />}
            color="#ed6c02"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Aktif Kullanıcı"
            value={stats.activeUsers}
            icon={<MicIcon />}
            color="#9c27b0"
          />
        </Grid>
      </Grid>
      
      {/* Son Etkinlikler */}
      <Grid container spacing={3}>
        {/* Son Kullanıcılar */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              Son Kaydolan Kullanıcılar
            </Typography>
            <Divider sx={{ mb: 2 }} />
            <List>
              {stats.recentUsers.map((user: any) => (
                <ListItem key={user.id} divider>
                  <ListItemAvatar>
                    <Avatar>
                      <PersonIcon />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText
                    primary={user.name}
                    secondary={`${user.email} - ${new Date(user.createdAt).toLocaleDateString('tr-TR')}`}
                  />
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>
        
        {/* Son Gruplar */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              Son Oluşturulan Gruplar
            </Typography>
            <Divider sx={{ mb: 2 }} />
            <List>
              {stats.recentGroups.map((group: any) => (
                <ListItem key={group.id} divider>
                  <ListItemAvatar>
                    <Avatar>
                      <GroupIcon />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText
                    primary={group.name}
                    secondary={`${group.memberCount} üye - ${new Date(group.createdAt).toLocaleDateString('tr-TR')}`}
                  />
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>
        
        {/* Son Oturumlar */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              Yaklaşan Oturumlar
            </Typography>
            <Divider sx={{ mb: 2 }} />
            <List>
              {stats.recentSessions.map((session: any) => (
                <ListItem key={session.id} divider>
                  <ListItemAvatar>
                    <Avatar>
                      <EventIcon />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText
                    primary={session.name}
                    secondary={`${session.participantCount} katılımcı - ${new Date(session.startTime).toLocaleString('tr-TR')}`}
                  />
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};

export default AdminDashboard; 