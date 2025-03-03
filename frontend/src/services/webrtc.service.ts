import * as mediasoupClient from 'mediasoup-client';
import { io, Socket } from 'socket.io-client';

/**
 * WebRTC Servisi
 * 
 * WebRTC ve mediasoup ile sesli iletişim işlemlerini gerçekleştiren servis
 */
export class WebRTCService {
  private socket: Socket | null = null;
  private device: mediasoupClient.Device | null = null;
  private sendTransport: mediasoupClient.types.Transport | null = null;
  private recvTransport: mediasoupClient.types.Transport | null = null;
  private producer: mediasoupClient.types.Producer | null = null;
  private consumers: Map<string, mediasoupClient.types.Consumer> = new Map();
  private microphoneStream: MediaStream | null = null;
  private roomId: string | null = null;
  private userId: string | null = null;
  private onParticipantJoined: ((participantId: string) => void) | null = null;
  private onParticipantLeft: ((participantId: string) => void) | null = null;
  private onAudioTrack: ((participantId: string, track: MediaStreamTrack) => void) | null = null;

  /**
   * WebRTC servisini başlatır
   * 
   * @param serverUrl - Sinyal sunucusu URL'si
   * @param roomId - Oda ID'si
   * @param userId - Kullanıcı ID'si
   */
  async initialize(
    serverUrl: string,
    roomId: string,
    userId: string,
    onParticipantJoined?: (participantId: string) => void,
    onParticipantLeft?: (participantId: string) => void,
    onAudioTrack?: (participantId: string, track: MediaStreamTrack) => void
  ): Promise<void> {
    try {
      this.roomId = roomId;
      this.userId = userId;
      this.onParticipantJoined = onParticipantJoined || null;
      this.onParticipantLeft = onParticipantLeft || null;
      this.onAudioTrack = onAudioTrack || null;

      // Socket.io bağlantısı oluştur
      this.socket = io(serverUrl, {
        query: {
          roomId,
          userId,
        },
        transports: ['websocket'],
      });

      // Socket.io olay dinleyicileri
      this.setupSocketListeners();

      // mediasoup cihazını oluştur
      this.device = new mediasoupClient.Device();

      // Sunucudan RTP yeteneklerini al
      const routerRtpCapabilities = await this.request('getRouterRtpCapabilities');
      
      // Cihazı yükle
      await this.device.load({ routerRtpCapabilities });

      // Transport'ları oluştur
      await this.createSendTransport();
      await this.createRecvTransport();

      console.log('WebRTC servisi başarıyla başlatıldı');
    } catch (error) {
      console.error('WebRTC servisi başlatma hatası:', error);
      throw error;
    }
  }

  /**
   * Socket.io olay dinleyicilerini ayarlar
   */
  private setupSocketListeners(): void {
    if (!this.socket) return;

    // Yeni katılımcı olayı
    this.socket.on('newParticipant', async (participantId: string) => {
      console.log(`Yeni katılımcı: ${participantId}`);
      
      if (this.onParticipantJoined) {
        this.onParticipantJoined(participantId);
      }
      
      // Katılımcının ses akışını al
      await this.consumeAudio(participantId);
    });

    // Katılımcı ayrılma olayı
    this.socket.on('participantLeft', (participantId: string) => {
      console.log(`Katılımcı ayrıldı: ${participantId}`);
      
      // Tüketiciyi kapat
      const consumer = this.consumers.get(participantId);
      if (consumer) {
        consumer.close();
        this.consumers.delete(participantId);
      }
      
      if (this.onParticipantLeft) {
        this.onParticipantLeft(participantId);
      }
    });

    // Yeni tüketici olayı
    this.socket.on('newConsumer', async (data: any) => {
      const {
        peerId,
        producerId,
        id,
        kind,
        rtpParameters,
      } = data;

      // Ses tüketicisi oluştur
      const consumer = await this.consumeAudio(peerId, {
        id,
        producerId,
        kind,
        rtpParameters,
      });

      if (consumer && this.onAudioTrack) {
        this.onAudioTrack(peerId, consumer.track);
      }
    });
  }

  /**
   * Gönderme transport'unu oluşturur
   */
  private async createSendTransport(): Promise<void> {
    try {
      // Sunucudan transport parametrelerini al
      const transportOptions = await this.request('createWebRtcTransport', {
        consuming: false,
        producing: true,
      });

      // Transport oluştur
      if (this.device) {
        this.sendTransport = this.device.createSendTransport(transportOptions);
      }

      if (!this.sendTransport) {
        throw new Error('Gönderme transport\'u oluşturulamadı');
      }

      // Transport olaylarını dinle
      this.sendTransport.on('connect', async ({ dtlsParameters }, callback, errback) => {
        try {
          // Transport'u sunucuya bağla
          await this.request('connectWebRtcTransport', {
            transportId: this.sendTransport?.id,
            dtlsParameters,
          });
          
          callback();
        } catch (error) {
          errback(error as Error);
        }
      });

      this.sendTransport.on('produce', async ({ kind, rtpParameters, appData }, callback, errback) => {
        try {
          // Sunucuda üretici oluştur
          const { id } = await this.request('produce', {
            transportId: this.sendTransport?.id,
            kind,
            rtpParameters,
            appData,
          });
          
          callback({ id });
        } catch (error) {
          errback(error as Error);
        }
      });
    } catch (error) {
      console.error('Gönderme transport\'u oluşturma hatası:', error);
      throw error;
    }
  }

  /**
   * Alma transport'unu oluşturur
   */
  private async createRecvTransport(): Promise<void> {
    try {
      // Sunucudan transport parametrelerini al
      const transportOptions = await this.request('createWebRtcTransport', {
        consuming: true,
        producing: false,
      });

      // Transport oluştur
      if (this.device) {
        this.recvTransport = this.device.createRecvTransport(transportOptions);
      }

      if (!this.recvTransport) {
        throw new Error('Alma transport\'u oluşturulamadı');
      }

      // Transport olaylarını dinle
      this.recvTransport.on('connect', async ({ dtlsParameters }, callback, errback) => {
        try {
          // Transport'u sunucuya bağla
          await this.request('connectWebRtcTransport', {
            transportId: this.recvTransport?.id,
            dtlsParameters,
          });
          
          callback();
        } catch (error) {
          errback(error as Error);
        }
      });
    } catch (error) {
      console.error('Alma transport\'u oluşturma hatası:', error);
      throw error;
    }
  }

  /**
   * Mikrofonu açar ve ses akışını gönderir
   */
  async publishMicrophone(): Promise<void> {
    try {
      // Mikrofon erişimi iste
      this.microphoneStream = await navigator.mediaDevices.getUserMedia({
        audio: true,
      });

      const audioTrack = this.microphoneStream.getAudioTracks()[0];

      if (!audioTrack) {
        throw new Error('Mikrofon erişimi başarısız');
      }

      // Ses üreticisi oluştur
      if (this.sendTransport) {
        this.producer = await this.sendTransport.produce({
          track: audioTrack,
          codecOptions: {
            opusStereo: false,
            opusDtx: true,
            opusFec: true,
            opusNack: true,
          },
        });
      }

      console.log('Mikrofon yayını başlatıldı');
    } catch (error) {
      console.error('Mikrofon yayını başlatma hatası:', error);
      throw error;
    }
  }

  /**
   * Mikrofonu kapatır
   */
  async unpublishMicrophone(): Promise<void> {
    try {
      // Üreticiyi kapat
      if (this.producer) {
        this.producer.close();
        this.producer = null;
      }

      // Mikrofon akışını kapat
      if (this.microphoneStream) {
        this.microphoneStream.getTracks().forEach(track => track.stop());
        this.microphoneStream = null;
      }

      console.log('Mikrofon yayını durduruldu');
    } catch (error) {
      console.error('Mikrofon yayını durdurma hatası:', error);
      throw error;
    }
  }

  /**
   * Katılımcının ses akışını tüketir
   * 
   * @param participantId - Katılımcı ID'si
   * @param consumerOptions - Tüketici seçenekleri (isteğe bağlı)
   * @returns Tüketici
   */
  private async consumeAudio(
    participantId: string,
    consumerOptions?: any
  ): Promise<mediasoupClient.types.Consumer | null> {
    try {
      if (!this.device || !this.device.rtpCapabilities) {
        console.warn('Cihaz ses tüketemiyor');
        return null;
      }

      let consumerParams;

      // Tüketici seçenekleri verilmişse kullan, yoksa sunucudan al
      if (consumerOptions) {
        consumerParams = consumerOptions;
      } else {
        // Sunucudan tüketici parametrelerini al
        consumerParams = await this.request('consume', {
          rtpCapabilities: this.device.rtpCapabilities,
          producerId: participantId,
        });
      }

      // Tüketici oluştur
      const consumer = await this.recvTransport?.consume(consumerParams);

      if (!consumer) {
        throw new Error('Tüketici oluşturulamadı');
      }

      // Tüketiciyi kaydet
      this.consumers.set(participantId, consumer);

      // Sunucuya tüketim başladı bildir
      await this.request('resumeConsumer', { consumerId: consumer.id });

      return consumer;
    } catch (error) {
      console.error(`${participantId} katılımcısının ses akışını tüketme hatası:`, error);
      return null;
    }
  }

  /**
   * Sunucuya istek gönderir
   * 
   * @param method - İstek metodu
   * @param data - İstek verisi
   * @returns Yanıt
   */
  private request(method: string, data: any = {}): Promise<any> {
    return new Promise((resolve, reject) => {
      if (!this.socket) {
        reject(new Error('Socket bağlantısı yok'));
        return;
      }

      this.socket.emit('request', { method, data }, (response: any) => {
        if (response.error) {
          reject(new Error(response.error));
        } else {
          resolve(response.data);
        }
      });
    });
  }

  /**
   * Odaya katılır
   */
  async joinRoom(): Promise<void> {
    try {
      // Odaya katıl
      await this.request('joinRoom', {
        roomId: this.roomId,
        rtpCapabilities: this.device?.rtpCapabilities,
      });

      console.log(`${this.roomId} odasına katılındı`);
    } catch (error) {
      console.error('Odaya katılma hatası:', error);
      throw error;
    }
  }

  /**
   * Odadan ayrılır
   */
  async leaveRoom(): Promise<void> {
    try {
      // Mikrofonu kapat
      await this.unpublishMicrophone();

      // Tüm tüketicileri kapat
      this.consumers.forEach(consumer => {
        consumer.close();
      });
      this.consumers.clear();

      // Transport'ları kapat
      if (this.sendTransport) {
        this.sendTransport.close();
        this.sendTransport = null;
      }

      if (this.recvTransport) {
        this.recvTransport.close();
        this.recvTransport = null;
      }

      // Odadan ayrıl
      await this.request('leaveRoom', { roomId: this.roomId });

      console.log(`${this.roomId} odasından ayrılındı`);
    } catch (error) {
      console.error('Odadan ayrılma hatası:', error);
      throw error;
    }
  }

  /**
   * Bağlantıyı kapatır
   */
  disconnect(): void {
    try {
      // Socket bağlantısını kapat
      if (this.socket) {
        this.socket.disconnect();
        this.socket = null;
      }

      console.log('WebRTC servisi kapatıldı');
    } catch (error) {
      console.error('WebRTC servisi kapatma hatası:', error);
    }
  }
}

// Singleton örneği oluştur
export const webRTCService = new WebRTCService(); 