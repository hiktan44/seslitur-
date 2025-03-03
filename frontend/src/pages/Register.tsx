import React, { useState } from 'react';
import { useNavigate, Link as RouterLink } from 'react-router-dom';
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
import { register, RegisterData } from '../services/auth.service';
import { useAuth } from '../contexts/AuthContext';

/**
 * Kayıt Sayfası
 * 
 * Kullanıcının uygulamaya kayıt olmasını sağlar
 */
const Register: React.FC = () => {
  const navigate = useNavigate();
  const auth = useAuth();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Başlangıç değerleri
  const initialValues: RegisterData & { confirmPassword: string; isAdmin: boolean } = {
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    confirmPassword: '',
    phoneNumber: '',
    isAdmin: false,
  };
  
  // Şifre görünürlüğünü değiştir
  const handleClickShowPassword = () => {
    setShowPassword(!showPassword);
  };
  
  // Şifre onayı görünürlüğünü değiştir
  const handleClickShowConfirmPassword = () => {
    setShowConfirmPassword(!showConfirmPassword);
  };
  
  // Form gönderimi
  const handleSubmit = async (
    values: RegisterData & { confirmPassword: string; isAdmin: boolean },
    { setSubmitting }: FormikHelpers<RegisterData & { confirmPassword: string; isAdmin: boolean }>
  ) => {
    setError(null);
    
    try {
      // Admin için şifre kontrolü
      if ((values.isAdmin || values.email === 'admin@example.com') && values.password !== '12345') {
        setError('Admin hesabı için şifre 12345 olmalıdır.');
        setSubmitting(false);
        return;
      }
      
      // Kayıt verilerini hazırla
      const registerData: RegisterData = {
        firstName: values.firstName,
        lastName: values.lastName,
        email: values.email,
        password: values.password,
        phoneNumber: values.phoneNumber || undefined,
        isAdmin: values.isAdmin,
      };
      
      // Kayıt ol
      const response = await register(registerData);
      
      // Kullanıcı bilgilerini güncelle
      auth.setUser(response.user);
      
      // Yönlendir
      navigate('/dashboard');
    } catch (error) {
      console.error('Kayıt hatası:', error);
      setError('Kayıt yapılamadı. Lütfen bilgilerinizi kontrol edin veya farklı bir e-posta adresi deneyin.');
      setSubmitting(false);
    }
  };
  
  return (
    <Container maxWidth="sm">
      <Box sx={{ mt: 8, mb: 4 }}>
        <Paper elevation={3} sx={{ p: 4 }}>
          <Box sx={{ textAlign: 'center', mb: 3 }}>
            <Typography variant="h4" component="h1" gutterBottom>
              Kayıt Ol
            </Typography>
            <Typography variant="body2" color="textSecondary">
              Sesli İletişim Platformuna Hoş Geldiniz
            </Typography>
          </Box>
          
          {/* Admin kayıt bilgileri */}
          <Alert severity="info" sx={{ mb: 3 }}>
            <Typography variant="subtitle2">Admin Kaydı İçin:</Typography>
            <Typography variant="body2">E-posta olarak "admin@example.com" kullanırsanız veya "Admin olarak kayıt ol" seçeneğini işaretlerseniz, şifre olarak "12345" kullanmalısınız.</Typography>
          </Alert>
          
          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}
          
          <Formik
            initialValues={initialValues}
            validationSchema={Yup.object({
              firstName: Yup.string()
                .required('Ad gereklidir')
                .min(2, 'Ad en az 2 karakter olmalıdır')
                .max(50, 'Ad en fazla 50 karakter olabilir'),
              lastName: Yup.string()
                .required('Soyad gereklidir')
                .min(2, 'Soyad en az 2 karakter olmalıdır')
                .max(50, 'Soyad en fazla 50 karakter olabilir'),
              email: Yup.string()
                .email('Geçerli bir e-posta adresi giriniz')
                .required('E-posta adresi gereklidir'),
              password: Yup.string()
                .required('Şifre gereklidir')
                .min(5, 'Şifre en az 5 karakter olmalıdır')
                .matches(
                  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{5,}$/,
                  'Şifre en az bir büyük harf, bir küçük harf ve bir rakam içermelidir'
                ),
              confirmPassword: Yup.string()
                .oneOf([Yup.ref('password')], 'Şifreler eşleşmiyor')
                .required('Şifre onayı gereklidir'),
              phoneNumber: Yup.string()
                .matches(/^[0-9]{10,11}$/, 'Geçerli bir telefon numarası giriniz (10-11 rakam)')
                .nullable(),
            })}
            onSubmit={handleSubmit}
          >
            {({ isSubmitting, errors, touched }) => (
              <Form>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <Field
                      as={TextField}
                      fullWidth
                      id="firstName"
                      name="firstName"
                      label="Ad"
                      variant="outlined"
                      error={touched.firstName && Boolean(errors.firstName)}
                      helperText={touched.firstName && errors.firstName}
                    />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Field
                      as={TextField}
                      fullWidth
                      id="lastName"
                      name="lastName"
                      label="Soyad"
                      variant="outlined"
                      error={touched.lastName && Boolean(errors.lastName)}
                      helperText={touched.lastName && errors.lastName}
                    />
                  </Grid>
                </Grid>
                
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
                
                <Field
                  as={TextField}
                  fullWidth
                  id="confirmPassword"
                  name="confirmPassword"
                  label="Şifre Onayı"
                  type={showConfirmPassword ? 'text' : 'password'}
                  variant="outlined"
                  margin="normal"
                  error={touched.confirmPassword && Boolean(errors.confirmPassword)}
                  helperText={touched.confirmPassword && errors.confirmPassword}
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          aria-label="şifre onayı görünürlüğünü değiştir"
                          onClick={handleClickShowConfirmPassword}
                          edge="end"
                        >
                          {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />
                
                <Field
                  as={TextField}
                  fullWidth
                  id="phoneNumber"
                  name="phoneNumber"
                  label="Telefon Numarası (İsteğe Bağlı)"
                  variant="outlined"
                  margin="normal"
                  error={touched.phoneNumber && Boolean(errors.phoneNumber)}
                  helperText={touched.phoneNumber && errors.phoneNumber}
                />
                
                <FormControlLabel
                  control={<Field as={Checkbox} name="isAdmin" color="primary" />}
                  label="Admin olarak kayıt ol"
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
                  {isSubmitting ? 'Kayıt Yapılıyor...' : 'Kayıt Ol'}
                </Button>
                
                <Grid container justifyContent="flex-end" sx={{ mt: 2 }}>
                  <Grid item>
                    <Link component={RouterLink} to="/login" variant="body2">
                      Zaten bir hesabınız var mı? Giriş yapın
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

export default Register; 