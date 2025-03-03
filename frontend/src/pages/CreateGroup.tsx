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
  FormControlLabel,
  Switch,
  FormHelperText,
  CircularProgress,
  Alert,
  IconButton,
  InputAdornment,
  Tooltip,
} from '@mui/material';
import {
  Visibility as VisibilityIcon,
  VisibilityOff as VisibilityOffIcon,
  Info as InfoIcon,
  ArrowBack as ArrowBackIcon,
} from '@mui/icons-material';
import * as groupService from '../services/group.service';

// Form değerleri için arayüz
interface CreateGroupFormValues {
  name: string;
  description: string;
  maxParticipants: number;
  isProtected: boolean;
  password: string;
  confirmPassword: string;
}

// Doğrulama şeması
const validationSchema = Yup.object({
  name: Yup.string()
    .required('Grup adı gereklidir')
    .min(3, 'Grup adı en az 3 karakter olmalıdır')
    .max(50, 'Grup adı en fazla 50 karakter olabilir'),
  description: Yup.string()
    .max(500, 'Açıklama en fazla 500 karakter olabilir'),
  maxParticipants: Yup.number()
    .required('Maksimum katılımcı sayısı gereklidir')
    .min(2, 'En az 2 katılımcı olmalıdır')
    .max(300, 'En fazla 300 katılımcı olabilir')
    .integer('Tam sayı olmalıdır'),
  isProtected: Yup.boolean(),
  password: Yup.string()
    .when('isProtected', {
      is: true,
      then: (schema) => schema
        .required('Şifre korumalı grup için şifre gereklidir')
        .min(6, 'Şifre en az 6 karakter olmalıdır'),
      otherwise: (schema) => schema,
    }),
  confirmPassword: Yup.string()
    .when('isProtected', {
      is: true,
      then: (schema) => schema
        .required('Şifreyi onaylayın')
        .oneOf([Yup.ref('password')], 'Şifreler eşleşmiyor'),
      otherwise: (schema) => schema,
    }),
});

/**
 * Grup Oluşturma Sayfası
 * 
 * Kullanıcının yeni bir grup oluşturmasını sağlar
 */
const CreateGroup: React.FC = () => {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // Başlangıç değerleri
  const initialValues: CreateGroupFormValues = {
    name: '',
    description: '',
    maxParticipants: 100,
    isProtected: false,
    password: '',
    confirmPassword: '',
  };

  // Form gönderimi
  const handleSubmit = async (
    values: CreateGroupFormValues,
    { setSubmitting }: FormikHelpers<CreateGroupFormValues>
  ) => {
    setError(null);
    
    try {
      const createGroupDto: groupService.CreateGroupDto = {
        name: values.name,
        description: values.description,
        maxParticipants: values.maxParticipants,
        isProtected: values.isProtected,
        isPrivate: false, // Varsayılan olarak herkese açık
        password: values.isProtected ? values.password : undefined,
      };
      
      const createdGroup = await groupService.createGroup(createGroupDto);
      
      // Başarılı oluşturma sonrası grup sayfasına yönlendir
      navigate(`/groups/${createdGroup.id}`);
    } catch (error) {
      console.error('Grup oluşturma hatası:', error);
      setError('Grup oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      setSubmitting(false);
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate('/groups')}
        sx={{ mb: 3 }}
      >
        Gruplara Dön
      </Button>
      
      <Typography variant="h4" gutterBottom>
        Yeni Grup Oluştur
      </Typography>
      
      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}
      
      <Paper sx={{ p: 3 }}>
        <Formik
          initialValues={initialValues}
          validationSchema={validationSchema}
          onSubmit={handleSubmit}
        >
          {({ values, errors, touched, isSubmitting, handleChange, setFieldValue }) => (
            <Form>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <Field
                    as={TextField}
                    fullWidth
                    id="name"
                    name="name"
                    label="Grup Adı"
                    variant="outlined"
                    error={touched.name && Boolean(errors.name)}
                    helperText={touched.name && errors.name}
                  />
                </Grid>
                
                <Grid item xs={12}>
                  <Field
                    as={TextField}
                    fullWidth
                    id="description"
                    name="description"
                    label="Grup Açıklaması"
                    variant="outlined"
                    multiline
                    rows={4}
                    error={touched.description && Boolean(errors.description)}
                    helperText={touched.description && errors.description}
                  />
                </Grid>
                
                <Grid item xs={12} sm={6}>
                  <Field
                    as={TextField}
                    fullWidth
                    id="maxParticipants"
                    name="maxParticipants"
                    label="Maksimum Katılımcı Sayısı"
                    variant="outlined"
                    type="number"
                    InputProps={{
                      inputProps: { min: 2, max: 300 },
                      endAdornment: (
                        <InputAdornment position="end">
                          <Tooltip title="Grup için izin verilen maksimum katılımcı sayısı. Sistem 300 katılımcıya kadar desteklemektedir.">
                            <IconButton edge="end">
                              <InfoIcon />
                            </IconButton>
                          </Tooltip>
                        </InputAdornment>
                      ),
                    }}
                    error={touched.maxParticipants && Boolean(errors.maxParticipants)}
                    helperText={touched.maxParticipants && errors.maxParticipants}
                  />
                </Grid>
                
                <Grid item xs={12}>
                  <FormControlLabel
                    control={
                      <Switch
                        checked={values.isProtected}
                        onChange={(e) => {
                          setFieldValue('isProtected', e.target.checked);
                          if (!e.target.checked) {
                            setFieldValue('password', '');
                            setFieldValue('confirmPassword', '');
                          }
                        }}
                        name="isProtected"
                        color="primary"
                      />
                    }
                    label="Şifre Korumalı Grup"
                  />
                  <FormHelperText>
                    Şifre korumalı gruplara sadece şifreyi bilen kullanıcılar katılabilir
                  </FormHelperText>
                </Grid>
                
                {values.isProtected && (
                  <>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        id="password"
                        name="password"
                        label="Grup Şifresi"
                        variant="outlined"
                        type={showPassword ? 'text' : 'password'}
                        value={values.password}
                        onChange={handleChange}
                        error={touched.password && Boolean(errors.password)}
                        helperText={touched.password && errors.password}
                        InputProps={{
                          endAdornment: (
                            <InputAdornment position="end">
                              <IconButton
                                onClick={() => setShowPassword(!showPassword)}
                                edge="end"
                              >
                                {showPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                              </IconButton>
                            </InputAdornment>
                          ),
                        }}
                      />
                    </Grid>
                    
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        id="confirmPassword"
                        name="confirmPassword"
                        label="Şifreyi Onayla"
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
                  </>
                )}
                
                <Grid item xs={12} sx={{ mt: 2 }}>
                  <Button
                    type="submit"
                    variant="contained"
                    color="primary"
                    size="large"
                    disabled={isSubmitting}
                    startIcon={isSubmitting ? <CircularProgress size={20} /> : null}
                  >
                    {isSubmitting ? 'Oluşturuluyor...' : 'Grup Oluştur'}
                  </Button>
                </Grid>
              </Grid>
            </Form>
          )}
        </Formik>
      </Paper>
    </Box>
  );
};

export default CreateGroup; 