import React, { useState } from 'react';
import { useParams, useNavigate, Link as RouterLink } from 'react-router-dom';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import {
  Container,
  Box,
  Typography,
  TextField,
  Button,
  Link,
  Paper,
  CircularProgress,
  Alert,
  InputAdornment,
  IconButton,
} from '@mui/material';
import {
  Visibility as VisibilityIcon,
  VisibilityOff as VisibilityOffIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';

/**
 * Şifre Sıfırlama Sayfası
 * 
 * Kullanıcının şifresini sıfırlamasını sağlar
 */
const ResetPassword: React.FC = () => {
  const { token } = useParams<{ token: string }>();
  const { resetPassword } = useAuth();
  const navigate = useNavigate();
  
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState<boolean>(false);

  // Formik ile form yönetimi
  const formik = useFormik({
    initialValues: {
      password: '',
      confirmPassword: '',
    },
    validationSchema: Yup.object({
      password: Yup.string()
        .required('Yeni parola gereklidir')
        .min(8, 'Parola en az 8 karakter olmalıdır')
        .matches(
          /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
          'Parola en az bir büyük harf, bir küçük harf, bir rakam ve bir özel karakter içermelidir'
        ),
      confirmPassword: Yup.string()
        .oneOf([Yup.ref('password'), undefined], 'Parolalar eşleşmiyor')
        .required('Parola onayı gereklidir'),
    }),
    onSubmit: async (values) => {
      if (!token) {
        setError('Geçersiz veya eksik sıfırlama token\'ı.');
        return;
      }
      
      setIsSubmitting(true);
      setError(null);
      
      try {
        await resetPassword(token, values.password);
        // Başarılı sıfırlama sonrası giriş sayfasına yönlendir
        navigate('/login', { state: { message: 'Parolanız başarıyla sıfırlandı. Lütfen yeni parolanızla giriş yapın.' } });
      } catch (error: any) {
        console.error('Şifre sıfırlama hatası:', error);
        setError(error.response?.data?.message || 'Şifre sıfırlama başarısız. Lütfen daha sonra tekrar deneyin.');
      } finally {
        setIsSubmitting(false);
      }
    },
  });

  // Parola görünürlüğünü değiştir
  const handleTogglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  // Parola onayı görünürlüğünü değiştir
  const handleToggleConfirmPasswordVisibility = () => {
    setShowConfirmPassword(!showConfirmPassword);
  };

  // Token yoksa hata göster
  if (!token) {
    return (
      <Container maxWidth="sm">
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '100vh',
            py: 4,
          }}
        >
          <Paper
            elevation={3}
            sx={{
              p: 4,
              width: '100%',
              borderRadius: 2,
            }}
          >
            <Typography component="h1" variant="h5" gutterBottom>
              Geçersiz Sıfırlama Bağlantısı
            </Typography>
            <Typography variant="body1" paragraph>
              Sıfırlama bağlantısı geçersiz veya süresi dolmuş olabilir. Lütfen yeni bir şifre sıfırlama bağlantısı talep edin.
            </Typography>
            <Button
              component={RouterLink}
              to="/forgot-password"
              fullWidth
              variant="contained"
              sx={{ mt: 2 }}
            >
              Şifremi Unuttum
            </Button>
          </Paper>
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="sm">
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          py: 4,
        }}
      >
        <Paper
          elevation={3}
          sx={{
            p: 4,
            width: '100%',
            borderRadius: 2,
          }}
        >
          <Box
            sx={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              mb: 3,
            }}
          >
            <Typography component="h1" variant="h4" gutterBottom>
              Sesli İletişim Sistemi
            </Typography>
            <Typography component="h2" variant="h5">
              Şifre Sıfırlama
            </Typography>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}

          <Typography variant="body1" paragraph>
            Lütfen yeni parolanızı girin.
          </Typography>

          <Box component="form" onSubmit={formik.handleSubmit} noValidate>
            <TextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Yeni Parola"
              type={showPassword ? 'text' : 'password'}
              id="password"
              autoComplete="new-password"
              value={formik.values.password}
              onChange={formik.handleChange}
              onBlur={formik.handleBlur}
              error={formik.touched.password && Boolean(formik.errors.password)}
              helperText={formik.touched.password && formik.errors.password}
              disabled={isSubmitting}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle password visibility"
                      onClick={handleTogglePasswordVisibility}
                      edge="end"
                    >
                      {showPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="confirmPassword"
              label="Yeni Parola Onayı"
              type={showConfirmPassword ? 'text' : 'password'}
              id="confirmPassword"
              autoComplete="new-password"
              value={formik.values.confirmPassword}
              onChange={formik.handleChange}
              onBlur={formik.handleBlur}
              error={formik.touched.confirmPassword && Boolean(formik.errors.confirmPassword)}
              helperText={formik.touched.confirmPassword && formik.errors.confirmPassword}
              disabled={isSubmitting}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle confirm password visibility"
                      onClick={handleToggleConfirmPasswordVisibility}
                      edge="end"
                    >
                      {showConfirmPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={isSubmitting}
            >
              {isSubmitting ? <CircularProgress size={24} /> : 'Parolayı Sıfırla'}
            </Button>
            <Box sx={{ textAlign: 'center' }}>
              <Link component={RouterLink} to="/login" variant="body2">
                Giriş sayfasına dön
              </Link>
            </Box>
          </Box>
        </Paper>
      </Box>
    </Container>
  );
};

export default ResetPassword; 