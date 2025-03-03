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
  Public as PublicIcon,
  Lock as LockIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';

/**
 * Gruplar Sayfası
 * 
 * Kullanıcının katılabileceği grupları listeler
 */
const Groups: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');
  
  // Örnek veriler
  const [groups, setGroups] = useState<any[]>([]);
  const [filteredGroups, setFilteredGroups] = useState<any[]>([]);
  
  // Grupları yükle
  useEffect(() => {
    const fetchGroups = async () => {
      setLoading(true);
      setError(null);
      
      try {
        // Gerçek uygulamada API'den verileri alın
        // Şimdilik örnek veriler kullanıyoruz
        setTimeout(() => {
          const mockGroups = [
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
        setError('Veriler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
        setLoading(false);
      }
    };
    
    fetchGroups();
  }, []);
  
  // Arama işlemi
  useEffect(() => {
    if (searchTerm.trim() === '') {
      setFilteredGroups(groups);
    } else {
      const filtered = groups.filter(group => 
        group.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        group.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredGroups(filtered);
    }
  }, [searchTerm, groups]);
  
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
        <Typography variant="h4">Gruplar</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/groups/create')}
        >
          Yeni Grup Oluştur
        </Button>
      </Box>
      
      <TextField
        fullWidth
        variant="outlined"
        placeholder="Grup ara..."
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
      
      {filteredGroups.length === 0 ? (
        <Alert severity="info">
          Arama kriterlerinize uygun grup bulunamadı.
        </Alert>
      ) : (
        <Grid container spacing={3}>
          {filteredGroups.map((group) => (
            <Grid item xs={12} sm={6} md={4} key={group.id}>
              <Card>
                <CardContent>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                    <Typography variant="h6" component="div">
                      {group.name}
                    </Typography>
                    <Chip
                      icon={group.isPrivate ? <LockIcon /> : <PublicIcon />}
                      label={group.isPrivate ? 'Özel' : 'Açık'}
                      color={group.isPrivate ? 'secondary' : 'primary'}
                      size="small"
                    />
                  </Box>
                  <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                    {group.description}
                  </Typography>
                  <Typography variant="body2">
                    {group.memberCount} üye • Oluşturan: {group.createdBy.name}
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => navigate(`/groups/${group.id}`)}>
                    Detaylar
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}
    </Box>
  );
};

export default Groups; 