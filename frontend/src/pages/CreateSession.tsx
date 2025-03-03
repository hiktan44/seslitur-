import React, { useState, useEffect } from 'react';
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
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormHelperText,
  CircularProgress,
  Alert,
  IconButton,
  InputAdornment,
  Tooltip,
  Autocomplete,
} from '@mui/material';
import {
  Info as InfoIcon,
  ArrowBack as ArrowBackIcon,
  Event as EventIcon,
} from '@mui/icons-material';
import { DateTimePicker } from '@mui/x-date-pickers/DateTimePicker';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { tr } from 'date-fns/locale';
import * as sessionService from '../services/session.service';
import * as groupService from '../services/group.service';

// Form değerleri için arayüz
interface CreateSessionFormValues {
  name: string;
  description: string;
  groupId: string;
  startTime: Date;
  maxParticipants: number;
}

// Doğrulama şeması
const validationSchema = Yup.object({
  name: Yup.string()
    .required('Oturum adı gereklidir')
    .min(3, 'Oturum adı en az 3 karakter olmalıdır')
    .max(50, 'Oturum adı en fazla 50 karakter olabilir'),
  description: Yup.string()
    .max(500, 'Açıklama en fazla 500 karakter olabilir'),
  groupId: Yup.string()
    .required('Grup seçimi gereklidir'),
  startTime: Yup.date()
    .required('Başlangıç zamanı gereklidir')
    .min(new Date(), 'Başlangıç zamanı şu andan sonra olmalıdır'),
  maxParticipants: Yup.number()
    .required('Maksimum katılımcı sayısı gereklidir')
    .min(2, 'En az 2 katılımcı olmalıdır')
    .max(300, 'En fazla 300 katılımcı olabilir')
    .integer('Tam sayı olmalıdır'),
});

/**
 * Oturum Oluşturma Sayfası
 * 
 * Kullanıcının yeni bir sesli iletişim oturumu oluşturmasını sağlar
 */
const CreateSession: React.FC = () => {
  const navigate = useNavigate();
  const [userGroups, setUserGroups] = useState<groupService.Group[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Kullanıcının gruplarını yükle
  useEffect(() => {
    const fetchUserGroups = async () => {
      setIsLoading(true);
      setError(null);
      
      try {
        const groups = await groupService.getUserGroups();
        setUserGroups(groups);
      } catch (error) {
        console.error('Grup yükleme hatası:', error);
        setError('Gruplar yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchUserGroups();
  }, []);

  // Başlangıç değerleri
  const initialValues: CreateSessionFormValues = {
    name: '',
    description: '',
    groupId: '',
    startTime: new Date(Date.now() + 30 * 60000), // 30 dakika sonrası
    maxParticipants: 100,
  };

  // Form gönderimi
  const handleSubmit = async (
    values: CreateSessionFormValues,
    { setSubmitting }: FormikHelpers<CreateSessionFormValues>
  ) => {
    setError(null);
    
    try {
      const createSessionDto: sessionService.CreateSessionDto = {
        name: values.name,
        description: values.description,
        groupId: values.groupId,
        startTime: values.startTime.toISOString(),
        maxParticipants: values.maxParticipants,
      };
      
      const createdSession = await sessionService.createSession(createSessionDto);
      
      // Başarılı oluşturma sonrası oturum sayfasına yönlendir
      navigate(`/sessions/${createdSession.id}`);
    } catch (error) {
      console.error('Oturum oluşturma hatası:', error);
      setError('Oturum oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      setSubmitting(false);
    }
  };

  // Yükleniyor durumu
  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate('/sessions')}
        sx={{ mb: 3 }}
      >
        Oturumlara Dön
      </Button>
      
      <Typography variant="h4" gutterBottom>
        <EventIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
        Yeni Oturum Oluştur
      </Typography>
      
      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}
      
      {userGroups.length === 0 ? (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Oturum oluşturmak için önce bir gruba katılmanız veya grup oluşturmanız gerekmektedir.
          <Button
            variant="outlined"
            size="small"
            onClick={() => navigate('/groups/create')}
            sx={{ ml: 2 }}
          >
            Grup Oluştur
          </Button>
        </Alert>
      ) : (
        <Paper sx={{ p: 3 }}>
          <LocalizationProvider dateAdapter={AdapterDateFns}>
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
                        label="Oturum Adı"
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
                        label="Oturum Açıklaması"
                        variant="outlined"
                        multiline
                        rows={4}
                        error={touched.description && Boolean(errors.description)}
                        helperText={touched.description && errors.description}
                      />
                    </Grid>
                    
                    <Grid item xs={12}>
                      <FormControl fullWidth error={touched.groupId && Boolean(errors.groupId)}>
                        <InputLabel id="group-select-label">Grup</InputLabel>
                        <Select
                          labelId="group-select-label"
                          id="groupId"
                          name="groupId"
                          value={values.groupId}
                          label="Grup"
                          onChange={handleChange}
                        >
                          {userGroups.map((group) => (
                            <MenuItem key={group.id} value={group.id}>
                              {group.name}
                            </MenuItem>
                          ))}
                        </Select>
                        {touched.groupId && errors.groupId && (
                          <FormHelperText>{errors.groupId}</FormHelperText>
                        )}
                      </FormControl>
                    </Grid>
                    
                    <Grid item xs={12} sm={6}>
                      <DateTimePicker
                        label="Başlangıç Zamanı"
                        value={values.startTime}
                        onChange={(newValue) => {
                          setFieldValue('startTime', newValue);
                        }}
                        slotProps={{
                          textField: {
                            fullWidth: true,
                            variant: 'outlined',
                            error: touched.startTime && Boolean(errors.startTime),
                            helperText: touched.startTime && errors.startTime as string,
                          },
                        }}
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
                              <Tooltip title="Oturum için izin verilen maksimum katılımcı sayısı. Sistem 300 katılımcıya kadar desteklemektedir.">
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
                    
                    <Grid item xs={12} sx={{ mt: 2 }}>
                      <Button
                        type="submit"
                        variant="contained"
                        color="primary"
                        size="large"
                        disabled={isSubmitting}
                        startIcon={isSubmitting ? <CircularProgress size={20} /> : null}
                      >
                        {isSubmitting ? 'Oluşturuluyor...' : 'Oturum Oluştur'}
                      </Button>
                    </Grid>
                  </Grid>
                </Form>
              )}
            </Formik>
          </LocalizationProvider>
        </Paper>
      )}
    </Box>
  );
};

export default CreateSession; 