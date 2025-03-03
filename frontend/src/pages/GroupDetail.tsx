import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Button,
  Divider,
  List,
  ListItem,
  ListItemText,
  ListItemAvatar,
  ListItemSecondaryAction,
  Avatar,
  Chip,
  CircularProgress,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
  Alert,
  Tooltip,
  TextField,
  Tab,
  Tabs,
  InputAdornment,
} from '@mui/material';
import {
  Group as GroupIcon,
  Person as PersonIcon,
  Event as EventIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  ContentCopy as CopyIcon,
  Add as AddIcon,
  ArrowBack as ArrowBackIcon,
  MoreVert as MoreVertIcon,
  ExitToApp as LeaveIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import * as groupService from '../services/group.service';
import * as sessionService from '../services/session.service';

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
      id={`group-tabpanel-${index}`}
      aria-labelledby={`group-tab-${index}`}
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

/**
 * Grup Detay Sayfası
 * 
 * Bir grubun detaylarını, katılımcılarını ve oturumlarını gösterir
 */
const GroupDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const navigate = useNavigate();
  
  const [group, setGroup] = useState<groupService.Group | null>(null);
  const [participants, setParticipants] = useState<any[]>([]);
  const [sessions, setSessions] = useState<sessionService.Session[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [isOwner, setIsOwner] = useState<boolean>(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState<boolean>(false);
  const [confirmAction, setConfirmAction] = useState<string>('');
  const [tabValue, setTabValue] = useState<number>(0);
  const [copySuccess, setCopySuccess] = useState<boolean>(false);
  
  // Verileri yükle
  useEffect(() => {
    const fetchData = async () => {
      if (!id) return;
      
      setIsLoading(true);
      setError(null);
      
      try {
        // Grup bilgilerini getir
        const groupData = await groupService.getGroupById(id);
        setGroup(groupData);
        
        // Kullanıcı grup sahibi mi kontrol et
        setIsOwner(groupData.ownerId === user?.id);
        
        // Katılımcıları getir
        const participantsData = await groupService.getGroupParticipants(id);
        setParticipants(participantsData);
        
        // Oturumları getir
        const sessionsData = await groupService.getGroupSessions(id);
        setSessions(sessionsData);
      } catch (error) {
        console.error('Veri yükleme hatası:', error);
        setError('Veriler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchData();
  }, [id, user?.id]);

  // Tab değişikliği
  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
  };

  // Grup davet bağlantısını kopyala
  const copyInviteLink = () => {
    const inviteLink = `${window.location.origin}/groups/join/${id}`;
    navigator.clipboard.writeText(inviteLink);
    setCopySuccess(true);
    setTimeout(() => setCopySuccess(false), 2000);
  };

  // Gruptan ayrıl
  const handleLeaveGroup = async () => {
    if (!id) return;
    
    try {
      await groupService.leaveGroup(id);
      setConfirmDialogOpen(false);
      navigate('/groups');
    } catch (error) {
      console.error('Gruptan ayrılma hatası:', error);
      setError('Gruptan ayrılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // Grubu sil
  const handleDeleteGroup = async () => {
    if (!id) return;
    
    try {
      await groupService.deleteGroup(id);
      setConfirmDialogOpen(false);
      navigate('/groups');
    } catch (error) {
      console.error('Grup silme hatası:', error);
      setError('Grup silinirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // Onay diyaloğunu aç
  const openConfirmDialog = (action: string) => {
    setConfirmAction(action);
    setConfirmDialogOpen(true);
  };

  // Oturum durumuna göre renk döndür
  const getStatusColor = (status: string): string => {
    switch (status) {
      case 'active':
        return 'success';
      case 'scheduled':
        return 'info';
      case 'ended':
        return 'default';
      case 'cancelled':
        return 'error';
      default:
        return 'default';
    }
  };

  // Oturum durumunu Türkçe olarak döndür
  const getStatusText = (status: string): string => {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'scheduled':
        return 'Planlandı';
      case 'ended':
        return 'Sonlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
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

  // Hata durumu
  if (error) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography color="error" variant="h6" gutterBottom>
          {error}
        </Typography>
        <Button variant="contained" onClick={() => window.location.reload()}>
          Yeniden Dene
        </Button>
      </Box>
    );
  }

  // Grup bulunamadı
  if (!group) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          Grup bulunamadı.
        </Typography>
        <Button variant="contained" onClick={() => navigate('/groups')}>
          Gruplara Dön
        </Button>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate('/groups')}
        sx={{ mb: 3 }}
      >
        Gruplara Dön
      </Button>
      
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
          <Box>
            <Typography variant="h4" gutterBottom>
              <GroupIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
              {group.name}
            </Typography>
            <Typography variant="body1" paragraph>
              {group.description || 'Açıklama yok'}
            </Typography>
          </Box>
          
          <Box sx={{ display: 'flex', gap: 1 }}>
            {isOwner && (
              <>
                <Button
                  variant="outlined"
                  color="primary"
                  startIcon={<EditIcon />}
                  onClick={() => navigate(`/groups/edit/${id}`)}
                >
                  Düzenle
                </Button>
                <Button
                  variant="outlined"
                  color="error"
                  startIcon={<DeleteIcon />}
                  onClick={() => openConfirmDialog('delete')}
                >
                  Sil
                </Button>
              </>
            )}
            
            {!isOwner && (
              <Button
                variant="outlined"
                color="error"
                startIcon={<LeaveIcon />}
                onClick={() => openConfirmDialog('leave')}
              >
                Gruptan Ayrıl
              </Button>
            )}
          </Box>
        </Box>
        
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={12} sm={6}>
            <Typography variant="body2" color="text.secondary">
              <strong>Katılımcılar:</strong> {group.currentParticipants} / {group.maxParticipants}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>Oluşturulma:</strong> {new Date(group.createdAt).toLocaleString('tr-TR')}
            </Typography>
          </Grid>
          <Grid item xs={12} sm={6}>
            <Typography variant="body2" color="text.secondary">
              <strong>Grup Sahibi:</strong> {participants.find(p => p.userId === group.ownerId)?.name || 'Bilinmiyor'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              <strong>Grup Tipi:</strong> {group.isPrivate ? 'Özel' : 'Herkese Açık'} {group.isProtected && '(Şifre Korumalı)'}
            </Typography>
          </Grid>
        </Grid>
        
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
          <Typography variant="body1" sx={{ mr: 2 }}>
            Davet Bağlantısı:
          </Typography>
          <TextField
            size="small"
            value={`${window.location.origin}/groups/join/${id}`}
            InputProps={{
              readOnly: true,
              endAdornment: (
                <InputAdornment position="end">
                  <Tooltip title={copySuccess ? 'Kopyalandı!' : 'Kopyala'}>
                    <IconButton edge="end" onClick={copyInviteLink}>
                      <CopyIcon color={copySuccess ? 'success' : 'inherit'} />
                    </IconButton>
                  </Tooltip>
                </InputAdornment>
              ),
            }}
            sx={{ flexGrow: 1 }}
          />
        </Box>
        
        <Tabs value={tabValue} onChange={handleTabChange} aria-label="group tabs">
          <Tab label="Katılımcılar" id="group-tab-0" aria-controls="group-tabpanel-0" />
          <Tab label="Oturumlar" id="group-tab-1" aria-controls="group-tabpanel-1" />
        </Tabs>
        
        {/* Katılımcılar Sekmesi */}
        <TabPanel value={tabValue} index={0}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6">
              Katılımcılar ({participants.length})
            </Typography>
          </Box>
          
          <List>
            {participants.map((participant) => (
              <ListItem key={participant.userId} divider>
                <ListItemAvatar>
                  <Avatar>
                    <PersonIcon />
                  </Avatar>
                </ListItemAvatar>
                <ListItemText
                  primary={participant.name}
                  secondary={
                    participant.userId === group.ownerId && (
                      <Chip label="Grup Sahibi" size="small" color="primary" />
                    )
                  }
                />
                {isOwner && participant.userId !== user?.id && (
                  <ListItemSecondaryAction>
                    <IconButton edge="end" aria-label="more">
                      <MoreVertIcon />
                    </IconButton>
                  </ListItemSecondaryAction>
                )}
              </ListItem>
            ))}
            
            {participants.length === 0 && (
              <ListItem>
                <ListItemText primary="Henüz katılımcı yok" />
              </ListItem>
            )}
          </List>
        </TabPanel>
        
        {/* Oturumlar Sekmesi */}
        <TabPanel value={tabValue} index={1}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6">
              Oturumlar ({sessions.length})
            </Typography>
            <Button
              variant="contained"
              startIcon={<AddIcon />}
              onClick={() => navigate('/sessions/create', { state: { groupId: id } })}
            >
              Yeni Oturum Oluştur
            </Button>
          </Box>
          
          <Grid container spacing={3}>
            {sessions.length > 0 ? (
              sessions.map((session) => (
                <Grid item xs={12} sm={6} md={4} key={session.id}>
                  <Paper elevation={2} sx={{ p: 2 }}>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                      <Typography variant="h6" component="div">
                        {session.name}
                      </Typography>
                      <Chip
                        label={getStatusText(session.status)}
                        color={getStatusColor(session.status) as any}
                        size="small"
                      />
                    </Box>
                    <Typography variant="body2" color="text.secondary" gutterBottom>
                      {session.description || 'Açıklama yok'}
                    </Typography>
                    <Typography variant="body2" gutterBottom>
                      Başlangıç: {new Date(session.startTime).toLocaleString('tr-TR')}
                    </Typography>
                    <Typography variant="body2" gutterBottom>
                      Katılımcılar: {session.currentParticipants} / {session.maxParticipants}
                    </Typography>
                    <Box sx={{ mt: 2 }}>
                      <Button
                        size="small"
                        variant="contained"
                        startIcon={<EventIcon />}
                        onClick={() => navigate(`/sessions/${session.id}`)}
                      >
                        {session.status === 'active' ? 'Katıl' : 'Görüntüle'}
                      </Button>
                    </Box>
                  </Paper>
                </Grid>
              ))
            ) : (
              <Grid item xs={12}>
                <Typography variant="body1">
                  Bu grupta henüz oturum oluşturulmamış.
                </Typography>
              </Grid>
            )}
          </Grid>
        </TabPanel>
      </Paper>
      
      {/* Onay Diyaloğu */}
      <Dialog
        open={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
      >
        <DialogTitle>
          {confirmAction === 'delete' && 'Grubu Sil'}
          {confirmAction === 'leave' && 'Gruptan Ayrıl'}
        </DialogTitle>
        <DialogContent>
          <DialogContentText>
            {confirmAction === 'delete' && 'Bu grubu silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm oturumlar silinecektir.'}
            {confirmAction === 'leave' && 'Bu gruptan ayrılmak istediğinize emin misiniz?'}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setConfirmDialogOpen(false)}>İptal</Button>
          <Button
            onClick={() => {
              if (confirmAction === 'delete') handleDeleteGroup();
              else if (confirmAction === 'leave') handleLeaveGroup();
            }}
            color="error"
            variant="contained"
            autoFocus
          >
            {confirmAction === 'delete' && 'Sil'}
            {confirmAction === 'leave' && 'Ayrıl'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default GroupDetail; 