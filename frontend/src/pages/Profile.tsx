import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Formik, Form, Field, FormikHelpers } from 'formik';
import * as Yup from 'yup';
import {
  Box,
  Typography,
  TextField,
  Button,
  Paper,
  Grid,
  Avatar,
  Divider,
  IconButton,
  InputAdornment,
  CircularProgress,
  Alert,
  Tabs,
  Tab,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
} from '@mui/material';
import {
  Person as PersonIcon,
  Edit as EditIcon,
  Save as SaveIcon,
  Visibility as VisibilityIcon,
  VisibilityOff as VisibilityOffIcon,
  VpnKey as PasswordIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import * as authService from '../services/auth.service';

// Tab panel bileşeni
interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

const TabPanel = (props: TabPanelProps) => {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`profile-tabpanel-${index}`}
      aria-labelledby={`profile-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ pt: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
};

// Profil formu değerleri
interface ProfileFormValues {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
}

// Parola değiştirme formu değerleri
interface PasswordFormValues {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

// Profil formu doğrulama şeması
const profileValidationSchema = Yup.object({
  firstName: Yup.string()
    .required('Ad gereklidir')
    .max(50, 'Ad en fazla 50 karakter olabilir'),
  lastName: Yup.string()
    .required('Soyad gereklidir')
    .max(50, 'Soyad en fazla 50 karakter olabilir'),
  email: Yup.string()
    .email('Geçerli bir e-posta adresi giriniz')
    .required('E-posta adresi gereklidir'),
  phoneNumber: Yup.string()
    .matches(/^[0-9]{10}$/, 'Telefon numarası 10 haneli olmalıdır (Örn: 5XX1234567)')
    .notRequired(),
});

// Parola değiştirme formu doğrulama şeması
const passwordValidationSchema = Yup.object({
  currentPassword: Yup.string()
    .required('Mevcut parola gereklidir'),
  newPassword: Yup.string()
    .required('Yeni parola gereklidir')
    .min(8, 'Parola en az 8 karakter olmalıdır')
    .matches(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
      'Parola en az bir büyük harf, bir küçük harf, bir rakam ve bir özel karakter içermelidir'
    ),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('newPassword'), undefined], 'Parolalar eşleşmiyor')
    .required('Parola onayı gereklidir'),
});

/**
 * Profil Sayfası
 * 
 * Kullanıcının profil bilgilerini görüntülemesini ve düzenlemesini sağlar
 */
const Profile: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  
  const [tabValue, setTabValue] = useState<number>(0);
  const [isEditing, setIsEditing] = useState<boolean>(false);
  const [showCurrentPassword, setShowCurrentPassword] = useState<boolean>(false);
  const [showNewPassword, setShowNewPassword] = useState<boolean>(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState<boolean>(false);

  // Tab değişikliği
  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
  };

  // Profil formu başlangıç değerleri
  const initialProfileValues: ProfileFormValues = {
    firstName: user?.firstName || '',
    lastName: user?.lastName || '',
    email: user?.email || '',
    phoneNumber: '',
  };

  // Parola değiştirme formu başlangıç değerleri
  const initialPasswordValues: PasswordFormValues = {
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  };

  // Profil formu gönderimi
  const handleProfileSubmit = async (
    values: ProfileFormValues,
    { setSubmitting }: FormikHelpers<ProfileFormValues>
  ) => {
    setError(null);
    setSuccess(null);
    
    try {
      // Burada backend API'si ile profil güncelleme işlemi yapılabilir
      // Örnek: await api.put('/users/profile', values);
      
      // Başarılı güncelleme sonrası
      setSuccess('Profil bilgileriniz başarıyla güncellendi.');
      setIsEditing(false);
    } catch (error) {
      console.error('Profil güncelleme hatası:', error);
      setError('Profil güncellenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setSubmitting(false);
    }
  };

  // Parola değiştirme formu gönderimi
  const handlePasswordSubmit = async (
    values: PasswordFormValues,
    { setSubmitting, resetForm }: FormikHelpers<PasswordFormValues>
  ) => {
    setError(null);
    setSuccess(null);
    
    try {
      // Burada backend API'si ile parola değiştirme işlemi yapılabilir
      // Örnek: await api.put('/users/password', values);
      
      // Başarılı değiştirme sonrası
      setSuccess('Parolanız başarıyla değiştirildi.');
      resetForm();
    } catch (error) {
      console.error('Parola değiştirme hatası:', error);
      setError('Parola değiştirilirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setSubmitting(false);
    }
  };

  // Hesap silme işlemi
  const handleDeleteAccount = async () => {
    try {
      // Burada backend API'si ile hesap silme işlemi yapılabilir
      // Örnek: await api.delete('/users/account');
      
      // Başarılı silme sonrası
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Hesap silme hatası:', error);
      setError('Hesap silinirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      setConfirmDialogOpen(false);
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        <PersonIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
        Profil
      </Typography>
      
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
          <Avatar
            sx={{ width: 100, height: 100, mr: 3 }}
          >
            {user?.firstName?.charAt(0)}{user?.lastName?.charAt(0)}
          </Avatar>
          <Box>
            <Typography variant="h5">
              {user?.firstName} {user?.lastName}
            </Typography>
            <Typography variant="body1" color="text.secondary">
              {user?.email}
            </Typography>
          </Box>
        </Box>
        
        <Tabs value={tabValue} onChange={handleTabChange} aria-label="profile tabs">
          <Tab label="Profil Bilgileri" id="profile-tab-0" aria-controls="profile-tabpanel-0" />
          <Tab label="Parola Değiştir" id="profile-tab-1" aria-controls="profile-tabpanel-1" />
          <Tab label="Hesap Ayarları" id="profile-tab-2" aria-controls="profile-tabpanel-2" />
        </Tabs>
        
        {/* Profil Bilgileri Sekmesi */}
        <TabPanel value={tabValue} index={0}>
          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}
          
          {success && (
            <Alert severity="success" sx={{ mb: 3 }}>
              {success}
            </Alert>
          )}
          
          <Formik
            initialValues={initialProfileValues}
            validationSchema={profileValidationSchema}
            onSubmit={handleProfileSubmit}
          >
            {({ values, errors, touched, isSubmitting, handleChange }) => (
              <Form>
                <Grid container spacing={3}>
                  <Grid item xs={12} sm={6}>
                    <Field
                      as={TextField}
                      fullWidth
                      id="firstName"
                      name="firstName"
                      label="Ad"
                      variant="outlined"
                      disabled={!isEditing}
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
                      disabled={!isEditing}
                      error={touched.lastName && Boolean(errors.lastName)}
                      helperText={touched.lastName && errors.lastName}
                    />
                  </Grid>
                  
                  <Grid item xs={12}>
                    <Field
                      as={TextField}
                      fullWidth
                      id="email"
                      name="email"
                      label="E-posta Adresi"
                      variant="outlined"
                      disabled={!isEditing}
                      error={touched.email && Boolean(errors.email)}
                      helperText={touched.email && errors.email}
                    />
                  </Grid>
                  
                  <Grid item xs={12}>
                    <Field
                      as={TextField}
                      fullWidth
                      id="phoneNumber"
                      name="phoneNumber"
                      label="Telefon Numarası (İsteğe Bağlı)"
                      variant="outlined"
                      disabled={!isEditing}
                      error={touched.phoneNumber && Boolean(errors.phoneNumber)}
                      helperText={touched.phoneNumber && errors.phoneNumber}
                      placeholder="5XX1234567"
                    />
                  </Grid>
                  
                  <Grid item xs={12}>
                    {!isEditing ? (
                      <Button
                        variant="contained"
                        color="primary"
                        startIcon={<EditIcon />}
                        onClick={() => setIsEditing(true)}
                      >
                        Düzenle
                      </Button>
                    ) : (
                      <Box sx={{ display: 'flex', gap: 2 }}>
                        <Button
                          type="submit"
                          variant="contained"
                          color="primary"
                          startIcon={isSubmitting ? <CircularProgress size={20} /> : <SaveIcon />}
                          disabled={isSubmitting}
                        >
                          Kaydet
                        </Button>
                        <Button
                          variant="outlined"
                          onClick={() => setIsEditing(false)}
                          disabled={isSubmitting}
                        >
                          İptal
                        </Button>
                      </Box>
                    )}
                  </Grid>
                </Grid>
              </Form>
            )}
          </Formik>
        </TabPanel>
        
        {/* Parola Değiştir Sekmesi */}
        <TabPanel value={tabValue} index={1}>
          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}
          
          {success && (
            <Alert severity="success" sx={{ mb: 3 }}>
              {success}
            </Alert>
          )}
          
          <Formik
            initialValues={initialPasswordValues}
            validationSchema={passwordValidationSchema}
            onSubmit={handlePasswordSubmit}
          >
            {({ values, errors, touched, isSubmitting, handleChange }) => (
              <Form>
                <Grid container spacing={3}>
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      id="currentPassword"
                      name="currentPassword"
                      label="Mevcut Parola"
                      variant="outlined"
                      type={showCurrentPassword ? 'text' : 'password'}
                      value={values.currentPassword}
                      onChange={handleChange}
                      error={touched.currentPassword && Boolean(errors.currentPassword)}
                      helperText={touched.currentPassword && errors.currentPassword}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <IconButton
                              onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                              edge="end"
                            >
                              {showCurrentPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                            </IconButton>
                          </InputAdornment>
                        ),
                      }}
                    />
                  </Grid>
                  
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      id="newPassword"
                      name="newPassword"
                      label="Yeni Parola"
                      variant="outlined"
                      type={showNewPassword ? 'text' : 'password'}
                      value={values.newPassword}
                      onChange={handleChange}
                      error={touched.newPassword && Boolean(errors.newPassword)}
                      helperText={touched.newPassword && errors.newPassword}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <IconButton
                              onClick={() => setShowNewPassword(!showNewPassword)}
                              edge="end"
                            >
                              {showNewPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                            </IconButton>
                          </InputAdornment>
                        ),
                      }}
                    />
                  </Grid>
                  
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      id="confirmPassword"
                      name="confirmPassword"
                      label="Yeni Parola Onayı"
                      variant="outlined"
                      type={showConfirmPassword ? 'text' : 'password'}
                      value={values.confirmPassword}
                      onChange={handleChange}
                      error={touched.confirmPassword && Boolean(errors.confirmPassword)}
                      helperText={touched.confirmPassword && errors.confirmPassword}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <IconButton
                              onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                              edge="end"
                            >
                              {showConfirmPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                            </IconButton>
                          </InputAdornment>
                        ),
                      }}
                    />
                  </Grid>
                  
                  <Grid item xs={12}>
                    <Button
                      type="submit"
                      variant="contained"
                      color="primary"
                      startIcon={isSubmitting ? <CircularProgress size={20} /> : <PasswordIcon />}
                      disabled={isSubmitting}
                    >
                      Parolayı Değiştir
                    </Button>
                  </Grid>
                </Grid>
              </Form>
            )}
          </Formik>
        </TabPanel>
        
        {/* Hesap Ayarları Sekmesi */}
        <TabPanel value={tabValue} index={2}>
          <Typography variant="h6" gutterBottom>
            Hesap Ayarları
          </Typography>
          
          <Divider sx={{ my: 2 }} />
          
          <Box sx={{ mt: 3 }}>
            <Typography variant="subtitle1" gutterBottom>
              Hesabı Sil
            </Typography>
            <Typography variant="body2" color="text.secondary" paragraph>
              Hesabınızı sildiğinizde, tüm verileriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz.
            </Typography>
            <Button
              variant="outlined"
              color="error"
              onClick={() => setConfirmDialogOpen(true)}
            >
              Hesabımı Sil
            </Button>
          </Box>
        </TabPanel>
      </Paper>
      
      {/* Hesap Silme Onay Diyaloğu */}
      <Dialog
        open={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
      >
        <DialogTitle>
          Hesabınızı Silmek İstediğinize Emin Misiniz?
        </DialogTitle>
        <DialogContent>
          <DialogContentText>
            Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz kalıcı olarak silinecektir.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setConfirmDialogOpen(false)}>İptal</Button>
          <Button onClick={handleDeleteAccount} color="error" variant="contained">
            Hesabımı Sil
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Profile; 