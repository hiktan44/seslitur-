import React, { useState } from 'react';
import { useNavigate, useLocation, Link as RouterLink } from 'react-router-dom';
import { Formik, Form, Field, FormikHelpers } from 'formik';
import * as Yup from 'yup';
import {
  Container,
  Box,
  Typography,
  TextField,
  Button,
  Grid,
  Paper,
  Link,
  CircularProgress,
  Alert,
  IconButton,
  InputAdornment,
  FormControlLabel,
  Checkbox,
} from '@mui/material';
import { Visibility, VisibilityOff } from '@mui/icons-material';
import { login, LoginCredentials } from '../services/auth.service';
import { useAuth } from '../contexts/AuthContext';

/**
 * Giriş Sayfası
 * 
 * Kullanıcının uygulamaya giriş yapmasını sağlar
 */
const Login: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const auth = useAuth();
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Yönlendirme için "from" parametresini al
  const from = location.state?.from?.pathname || '/dashboard';
  
  // Başlangıç değerleri
  const initialValues: LoginCredentials & { isAdmin: boolean } = {
    email: '',
    password: '',
    isAdmin: false,
  };
  
  // Şifre görünürlüğünü değiştir
  const handleClickShowPassword = () => {
    setShowPassword(!showPassword);
  };
  
  // Form gönderimi
  const handleSubmit = async (
    values: LoginCredentials & { isAdmin: boolean },
    { setSubmitting }: FormikHelpers<LoginCredentials & { isAdmin: boolean }>
  ) => {
    setError(null);
    
    try {
      // Admin için şifre kontrolü
      if ((values.isAdmin || values.email === 'admin@example.com') && values.password !== '12345') {
        setError('Admin hesabı için şifre 12345 olmalıdır.');
        setSubmitting(false);
        return;
      }
      
      // Admin girişi kontrolü
      const loginData: LoginCredentials = {
        email: values.email,
        password: values.password,
        isAdmin: values.isAdmin,
      };
      
      // Giriş yap
      const response = await login(loginData);
      
      // Kullanıcı bilgilerini güncelle
      auth.setUser(response.user);
      
      // Yönlendir
      navigate(from, { replace: true });
    } catch (error) {
      console.error('Giriş hatası:', error);
      setError('Giriş yapılamadı. Lütfen e-posta ve şifrenizi kontrol edin.');
      setSubmitting(false);
    }
  };
  
  return (
    <Container maxWidth="sm">
      <Box sx={{ mt: 8, mb: 4 }}>
        <Paper elevation={3} sx={{ p: 4 }}>
          <Box sx={{ textAlign: 'center', mb: 3 }}>
            <Typography variant="h4" component="h1" gutterBottom>
              Giriş Yap
            </Typography>
            <Typography variant="body2" color="textSecondary">
              Sesli İletişim Platformuna Hoş Geldiniz
            </Typography>
          </Box>
          
          {/* Admin giriş bilgileri */}
          <Alert severity="info" sx={{ mb: 3 }}>
            <Typography variant="subtitle2">Admin Giriş Bilgileri:</Typography>
            <Typography variant="body2">E-posta: admin@example.com</Typography>
            <Typography variant="body2">Şifre: 12345</Typography>
          </Alert>
          
          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}
          
          <Formik
            initialValues={initialValues}
            validationSchema={Yup.object({
              email: Yup.string()
                .email('Geçerli bir e-posta adresi giriniz')
                .required('E-posta adresi gereklidir'),
              password: Yup.string()
                .required('Şifre gereklidir')
                .min(5, 'Şifre en az 5 karakter olmalıdır'),
            })}
            onSubmit={handleSubmit}
          >
            {({ isSubmitting, errors, touched }) => (
              <Form>
                <Field
                  as={TextField}
                  fullWidth
                  id="email"
                  name="email"
                  label="E-posta Adresi"
                  variant="outlined"
                  margin="normal"
                  error={touched.email && Boolean(errors.email)}
                  helperText={touched.email && errors.email}
                />
                
                <Field
                  as={TextField}
                  fullWidth
                  id="password"
                  name="password"
                  label="Şifre"
                  type={showPassword ? 'text' : 'password'}
                  variant="outlined"
                  margin="normal"
                  error={touched.password && Boolean(errors.password)}
                  helperText={touched.password && errors.password}
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          aria-label="şifre görünürlüğünü değiştir"
                          onClick={handleClickShowPassword}
                          edge="end"
                        >
                          {showPassword ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />
                
                <FormControlLabel
                  control={<Checkbox name="isAdmin" color="primary" />}
                  label="Admin olarak giriş yap"
                  sx={{ mt: 1, mb: 2 }}
                />
                
                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  color="primary"
                  size="large"
                  disabled={isSubmitting}
                  sx={{ mt: 2, mb: 2 }}
                  startIcon={isSubmitting ? <CircularProgress size={20} color="inherit" /> : null}
                >
                  {isSubmitting ? 'Giriş Yapılıyor...' : 'Giriş Yap'}
                </Button>
                
                <Grid container spacing={2} sx={{ mt: 2 }}>
                  <Grid item xs={12} sm={6}>
                    <Link component={RouterLink} to="/forgot-password" variant="body2">
                      Şifremi Unuttum
                    </Link>
                  </Grid>
                  <Grid item xs={12} sm={6} sx={{ textAlign: { sm: 'right' } }}>
                    <Link component={RouterLink} to="/register" variant="body2">
                      Hesabınız yok mu? Kayıt olun
                    </Link>
                  </Grid>
                </Grid>
              </Form>
            )}
          </Formik>
        </Paper>
      </Box>
    </Container>
  );
};

export default Login; 