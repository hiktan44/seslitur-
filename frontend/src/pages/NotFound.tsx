import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Button,
  Paper,
  Container,
} from '@mui/material';
import {
  SentimentDissatisfied as SadIcon,
  Home as HomeIcon,
} from '@mui/icons-material';

/**
 * 404 Sayfası
 * 
 * Bulunamayan sayfalar için 404 hata sayfası
 */
const NotFound: React.FC = () => {
  const navigate = useNavigate();

  return (
    <Container maxWidth="md">
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          textAlign: 'center',
          py: 4,
        }}
      >
        <Paper
          elevation={3}
          sx={{
            p: 5,
            borderRadius: 2,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
          }}
        >
          <SadIcon sx={{ fontSize: 100, color: 'text.secondary', mb: 2 }} />
          
          <Typography variant="h1" component="h1" gutterBottom>
            404
          </Typography>
          
          <Typography variant="h4" component="h2" gutterBottom>
            Sayfa Bulunamadı
          </Typography>
          
          <Typography variant="body1" color="text.secondary" paragraph sx={{ maxWidth: 500 }}>
            Aradığınız sayfa mevcut değil veya taşınmış olabilir.
            Lütfen URL'yi kontrol edin veya ana sayfaya dönün.
          </Typography>
          
          <Button
            variant="contained"
            color="primary"
            size="large"
            startIcon={<HomeIcon />}
            onClick={() => navigate('/')}
            sx={{ mt: 3 }}
          >
            Ana Sayfaya Dön
          </Button>
        </Paper>
      </Box>
    </Container>
  );
};

export default NotFound; 