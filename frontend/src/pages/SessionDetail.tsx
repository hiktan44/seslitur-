import React, { useState, useEffect, useRef } from 'react';
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
} from '@mui/material';
import {
  Event as EventIcon,
  Group as GroupIcon,
  Person as PersonIcon,
  Mic as MicIcon,
  MicOff as MicOffIcon,
  VolumeUp as VolumeUpIcon,
  VolumeOff as VolumeOffIcon,
  PanTool as RaiseHandIcon,
  ArrowBack as ArrowBackIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  PlayArrow as StartIcon,
  Stop as EndIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import * as sessionService from '../services/session.service';
import * as groupService from '../services/group.service';
import { webRTCService } from '../services/webrtc.service';

/**
 * Oturum Detay Sayfası
 * 
 * Bir sesli iletişim oturumunun detaylarını ve katılımcılarını gösterir
 */
const SessionDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const navigate = useNavigate();
  
  const [session, setSession] = useState<sessionService.Session | null>(null);
  const [group, setGroup] = useState<groupService.Group | null>(null);
  const [participants, setParticipants] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [isModerator, setIsModerator] = useState<boolean>(false);
  const [isJoined, setIsJoined] = useState<boolean>(false);
  const [isMicrophoneActive, setIsMicrophoneActive] = useState<boolean>(false);
  const [isHandRaised, setIsHandRaised] = useState<boolean>(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState<boolean>(false);
  const [confirmAction, setConfirmAction] = useState<string>('');
  const [audioTracks, setAudioTracks] = useState<Map<string, MediaStreamTrack>>(new Map());
  const [participantVolumes, setParticipantVolumes] = useState<Map<string, number>>(new Map());
  
  // WebRTC bağlantısı
  const webRTCInitialized = useRef<boolean>(false);

  // Oturum ve katılımcı verilerini yükle
  useEffect(() => {
    const fetchData = async () => {
      if (!id) return;
      
      setIsLoading(true);
      setError(null);
      
      try {
        // Oturum bilgilerini getir
        const sessionData = await sessionService.getSessionById(id);
        setSession(sessionData);
        
        // Grup bilgilerini getir
        const groupData = await groupService.getGroupById(sessionData.groupId);
        setGroup(groupData);
        
        // Katılımcıları getir
        const participantsData = await sessionService.getSessionParticipants(id);
        setParticipants(participantsData);
        
        // Kullanıcı moderatör mü kontrol et
        setIsModerator(sessionData.moderatorId === user?.id);
        
        // Kullanıcı katılımcı mı kontrol et
        setIsJoined(participantsData.some(p => p.userId === user?.id));
      } catch (error) {
        console.error('Veri yükleme hatası:', error);
        setError('Veriler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchData();
  }, [id, user?.id]);

  // WebRTC bağlantısını başlat
  useEffect(() => {
    const initializeWebRTC = async () => {
      if (!id || !session || !isJoined || webRTCInitialized.current) return;
      
      try {
        // WebRTC servisini başlat
        await webRTCService.initialize(
          process.env.REACT_APP_SIGNALING_SERVER_URL || 'http://localhost:3001',
          id,
          user?.id || '',
          handleParticipantJoined,
          handleParticipantLeft,
          handleAudioTrack
        );
        
        // Odaya katıl
        await webRTCService.joinRoom();
        
        webRTCInitialized.current = true;
      } catch (error) {
        console.error('WebRTC başlatma hatası:', error);
        setError('Sesli iletişim başlatılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
      }
    };
    
    initializeWebRTC();
    
    // Temizleme işlemi
    return () => {
      if (webRTCInitialized.current) {
        webRTCService.leaveRoom().catch(console.error);
        webRTCService.disconnect();
        webRTCInitialized.current = false;
      }
    };
  }, [id, session, isJoined, user?.id]);

  // Yeni katılımcı olayı
  const handleParticipantJoined = (participantId: string) => {
    console.log(`Yeni katılımcı: ${participantId}`);
    // Katılımcı listesini güncelle
    sessionService.getSessionParticipants(id || '')
      .then(setParticipants)
      .catch(console.error);
  };

  // Katılımcı ayrılma olayı
  const handleParticipantLeft = (participantId: string) => {
    console.log(`Katılımcı ayrıldı: ${participantId}`);
    // Katılımcı listesini güncelle
    sessionService.getSessionParticipants(id || '')
      .then(setParticipants)
      .catch(console.error);
    
    // Ses izini kaldır
    setAudioTracks(prev => {
      const newTracks = new Map(prev);
      newTracks.delete(participantId);
      return newTracks;
    });
    
    // Ses seviyesini kaldır
    setParticipantVolumes(prev => {
      const newVolumes = new Map(prev);
      newVolumes.delete(participantId);
      return newVolumes;
    });
  };

  // Ses izi olayı
  const handleAudioTrack = (participantId: string, track: MediaStreamTrack) => {
    console.log(`Ses izi alındı: ${participantId}`);
    
    // Ses izini kaydet
    setAudioTracks(prev => {
      const newTracks = new Map(prev);
      newTracks.set(participantId, track);
      return newTracks;
    });
    
    // Ses seviyesini başlat
    setParticipantVolumes(prev => {
      const newVolumes = new Map(prev);
      newVolumes.set(participantId, 1.0); // Varsayılan ses seviyesi
      return newVolumes;
    });
  };

  // Oturuma katıl
  const handleJoinSession = async () => {
    if (!id) return;
    
    try {
      await sessionService.joinSession(id);
      setIsJoined(true);
      
      // Katılımcı listesini güncelle
      const participantsData = await sessionService.getSessionParticipants(id);
      setParticipants(participantsData);
    } catch (error) {
      console.error('Oturuma katılma hatası:', error);
      setError('Oturuma katılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // Oturumdan ayrıl
  const handleLeaveSession = async () => {
    if (!id) return;
    
    try {
      // Mikrofonu kapat
      if (isMicrophoneActive) {
        await handleToggleMicrophone();
      }
      
      // WebRTC bağlantısını kapat
      if (webRTCInitialized.current) {
        await webRTCService.leaveRoom();
        webRTCService.disconnect();
        webRTCInitialized.current = false;
      }
      
      await sessionService.leaveSession(id);
      setIsJoined(false);
      
      // Katılımcı listesini güncelle
      const participantsData = await sessionService.getSessionParticipants(id);
      setParticipants(participantsData);
    } catch (error) {
      console.error('Oturumdan ayrılma hatası:', error);
      setError('Oturumdan ayrılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // Mikrofonu aç/kapat
  const handleToggleMicrophone = async () => {
    try {
      if (isMicrophoneActive) {
        await webRTCService.unpublishMicrophone();
      } else {
        await webRTCService.publishMicrophone();
      }
      
      setIsMicrophoneActive(!isMicrophoneActive);
    } catch (error) {
      console.error('Mikrofon hatası:', error);
      setError('Mikrofon açılırken/kapatılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // El kaldır/indir
  const handleToggleRaiseHand = () => {
    setIsHandRaised(!isHandRaised);
    // Burada backend API'si ile el kaldırma/indirme işlemi yapılabilir
  };

  // Oturumu başlat
  const handleStartSession = async () => {
    if (!id) return;
    
    try {
      const updatedSession = await sessionService.startSession(id);
      setSession(updatedSession);
      setConfirmDialogOpen(false);
    } catch (error) {
      console.error('Oturum başlatma hatası:', error);
      setError('Oturum başlatılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // Oturumu sonlandır
  const handleEndSession = async () => {
    if (!id) return;
    
    try {
      const updatedSession = await sessionService.endSession(id);
      setSession(updatedSession);
      setConfirmDialogOpen(false);
    } catch (error) {
      console.error('Oturum sonlandırma hatası:', error);
      setError('Oturum sonlandırılırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  };

  // Oturumu sil
  const handleDeleteSession = async () => {
    if (!id) return;
    
    try {
      await sessionService.deleteSession(id);
      setConfirmDialogOpen(false);
      navigate('/sessions');
    } catch (error) {
      console.error('Oturum silme hatası:', error);
      setError('Oturum silinirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
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

  // Oturum bulunamadı
  if (!session) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          Oturum bulunamadı.
        </Typography>
        <Button variant="contained" onClick={() => navigate('/sessions')}>
          Oturumlara Dön
        </Button>
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
      
      <Grid container spacing={3}>
        {/* Oturum Bilgileri */}
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
              <Typography variant="h4" gutterBottom>
                <EventIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                {session.name}
              </Typography>
              <Chip
                label={getStatusText(session.status)}
                color={getStatusColor(session.status) as any}
                size="medium"
              />
            </Box>
            
            <Typography variant="body1" paragraph>
              {session.description || 'Açıklama yok'}
            </Typography>
            
            <Grid container spacing={2} sx={{ mb: 2 }}>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">
                  <strong>Grup:</strong> {group?.name || 'Bilinmiyor'}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  <strong>Başlangıç:</strong> {new Date(session.startTime).toLocaleString('tr-TR')}
                </Typography>
                {session.endTime && (
                  <Typography variant="body2" color="text.secondary">
                    <strong>Bitiş:</strong> {new Date(session.endTime).toLocaleString('tr-TR')}
                  </Typography>
                )}
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="body2" color="text.secondary">
                  <strong>Moderatör:</strong> {participants.find(p => p.userId === session.moderatorId)?.name || 'Bilinmiyor'}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  <strong>Katılımcılar:</strong> {session.currentParticipants} / {session.maxParticipants}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  <strong>Oluşturulma:</strong> {new Date(session.createdAt).toLocaleString('tr-TR')}
                </Typography>
              </Grid>
            </Grid>
            
            <Divider sx={{ my: 2 }} />
            
            {/* Oturum Kontrolleri */}
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
              {/* Moderatör Kontrolleri */}
              {isModerator && (
                <>
                  {session.status === 'scheduled' && (
                    <Button
                      variant="contained"
                      color="primary"
                      startIcon={<StartIcon />}
                      onClick={() => openConfirmDialog('start')}
                    >
                      Oturumu Başlat
                    </Button>
                  )}
                  
                  {session.status === 'active' && (
                    <Button
                      variant="contained"
                      color="error"
                      startIcon={<EndIcon />}
                      onClick={() => openConfirmDialog('end')}
                    >
                      Oturumu Sonlandır
                    </Button>
                  )}
                  
                  {session.status !== 'ended' && session.status !== 'cancelled' && (
                    <Button
                      variant="outlined"
                      color="primary"
                      startIcon={<EditIcon />}
                      onClick={() => navigate(`/sessions/edit/${id}`)}
                    >
                      Düzenle
                    </Button>
                  )}
                  
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
              
              {/* Katılımcı Kontrolleri */}
              {session.status === 'active' && (
                <>
                  {!isJoined ? (
                    <Button
                      variant="contained"
                      color="primary"
                      startIcon={<MicIcon />}
                      onClick={handleJoinSession}
                    >
                      Oturuma Katıl
                    </Button>
                  ) : (
                    <>
                      <Button
                        variant="contained"
                        color={isMicrophoneActive ? 'error' : 'primary'}
                        startIcon={isMicrophoneActive ? <MicOffIcon /> : <MicIcon />}
                        onClick={handleToggleMicrophone}
                      >
                        {isMicrophoneActive ? 'Mikrofonu Kapat' : 'Mikrofonu Aç'}
                      </Button>
                      
                      <Button
                        variant="outlined"
                        color={isHandRaised ? 'warning' : 'primary'}
                        startIcon={<RaiseHandIcon />}
                        onClick={handleToggleRaiseHand}
                      >
                        {isHandRaised ? 'El İndir' : 'El Kaldır'}
                      </Button>
                      
                      <Button
                        variant="outlined"
                        color="error"
                        onClick={handleLeaveSession}
                      >
                        Oturumdan Ayrıl
                      </Button>
                    </>
                  )}
                </>
              )}
              
              {session.status === 'scheduled' && !isJoined && (
                <Button
                  variant="outlined"
                  color="primary"
                  onClick={handleJoinSession}
                >
                  Katılımcı Listesine Ekle
                </Button>
              )}
            </Box>
          </Paper>
        </Grid>
        
        {/* Katılımcılar */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              <GroupIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
              Katılımcılar ({participants.length})
            </Typography>
            
            <List>
              {participants.map((participant) => (
                <ListItem
                  key={participant.userId}
                  secondaryAction={
                    participant.isSpeaking && (
                      <Tooltip title="Konuşuyor">
                        <IconButton edge="end" disabled>
                          <VolumeUpIcon color="primary" />
                        </IconButton>
                      </Tooltip>
                    )
                  }
                >
                  <ListItemAvatar>
                    <Avatar>
                      <PersonIcon />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText
                    primary={participant.name}
                    secondary={
                      <>
                        {participant.userId === session.moderatorId && (
                          <Chip label="Moderatör" size="small" color="primary" sx={{ mr: 1 }} />
                        )}
                        {participant.handRaised && (
                          <Chip label="El Kaldırdı" size="small" color="warning" sx={{ mr: 1 }} />
                        )}
                      </>
                    }
                  />
                </ListItem>
              ))}
              
              {participants.length === 0 && (
                <ListItem>
                  <ListItemText primary="Henüz katılımcı yok" />
                </ListItem>
              )}
            </List>
          </Paper>
        </Grid>
      </Grid>
      
      {/* Onay Diyaloğu */}
      <Dialog
        open={confirmDialogOpen}
        onClose={() => setConfirmDialogOpen(false)}
      >
        <DialogTitle>
          {confirmAction === 'start' && 'Oturumu Başlat'}
          {confirmAction === 'end' && 'Oturumu Sonlandır'}
          {confirmAction === 'delete' && 'Oturumu Sil'}
        </DialogTitle>
        <DialogContent>
          <DialogContentText>
            {confirmAction === 'start' && 'Bu oturumu başlatmak istediğinize emin misiniz?'}
            {confirmAction === 'end' && 'Bu oturumu sonlandırmak istediğinize emin misiniz? Tüm katılımcılar oturumdan çıkarılacaktır.'}
            {confirmAction === 'delete' && 'Bu oturumu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setConfirmDialogOpen(false)}>İptal</Button>
          <Button
            onClick={() => {
              if (confirmAction === 'start') handleStartSession();
              else if (confirmAction === 'end') handleEndSession();
              else if (confirmAction === 'delete') handleDeleteSession();
            }}
            color={confirmAction === 'delete' ? 'error' : 'primary'}
            variant="contained"
            autoFocus
          >
            {confirmAction === 'start' && 'Başlat'}
            {confirmAction === 'end' && 'Sonlandır'}
            {confirmAction === 'delete' && 'Sil'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default SessionDetail; 