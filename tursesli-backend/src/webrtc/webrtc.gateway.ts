import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { WebrtcService } from './webrtc.service';
import { VoiceSessionsService } from '../voice-sessions/voice-sessions.service';

// WebSocket mesaj parametreleri için arayüzler
interface JoinRoomParams {
  roomId: string;
  peerId: string;
  rtpCapabilities: any;
}

interface ConnectTransportParams {
  transportId: string;
  dtlsParameters: any;
}

interface ProduceParams {
  transportId: string;
  kind: 'audio';
  rtpParameters: any;
}

interface ConsumeParams {
  roomId: string;
  transportId: string;
  producerId: string;
}

@WebSocketGateway({
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  namespace: 'webrtc',
})
export class WebrtcGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(WebrtcGateway.name);
  
  // Odalar ve katılımcılar için veri yapıları
  private rooms = new Map<string, Set<string>>();
  private peers = new Map<string, {
    socket: Socket;
    roomId?: string;
    transports: string[];
    producers: string[];
    consumers: string[];
  }>();

  @WebSocketServer()
  server: Server;

  constructor(
    private readonly webrtcService: WebrtcService,
    private readonly voiceSessionsService: VoiceSessionsService,
  ) {}

  // Bağlantı kurulduğunda
  async handleConnection(@ConnectedSocket() client: Socket) {
    const peerId = client.id;
    this.logger.log(`Client bağlandı: ${peerId}`);
    
    this.peers.set(peerId, {
      socket: client,
      transports: [],
      producers: [],
      consumers: [],
    });
  }

  // Bağlantı kesildiğinde
  async handleDisconnect(@ConnectedSocket() client: Socket) {
    const peerId = client.id;
    this.logger.log(`Client bağlantısı kesildi: ${peerId}`);
    
    const peer = this.peers.get(peerId);
    if (peer && peer.roomId) {
      await this.handleLeaveRoom(client, { roomId: peer.roomId });
    }
    
    this.peers.delete(peerId);
  }

  // Odaya katılma
  @SubscribeMessage('joinRoom')
  async handleJoinRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: JoinRoomParams,
  ) {
    const { roomId, peerId, rtpCapabilities } = data;
    this.logger.log(`Client odaya katılıyor: ${peerId}, oda: ${roomId}`);
    
    // Oda yoksa oluştur
    if (!this.rooms.has(roomId)) {
      this.rooms.set(roomId, new Set());
      
      // Router oluştur
      await this.webrtcService.createRouter(roomId);
    }
    
    // Odaya katıl
    const room = this.rooms.get(roomId);
    if (!room) {
      throw new Error(`Oda bulunamadı: ${roomId}`);
    }
    room.add(peerId);
    
    // Peer bilgilerini güncelle
    const peer = this.peers.get(peerId);
    if (!peer) {
      throw new Error(`Peer bulunamadı: ${peerId}`);
    }
    peer.roomId = roomId;
    
    // Sesli oturum katılımcı sayısını artır
    try {
      await this.voiceSessionsService.incrementParticipantCount(roomId);
    } catch (error) {
      this.logger.error(`Katılımcı sayısı artırılamadı: ${error.message}`);
    }
    
    // Üretici ve tüketici transportları oluştur
    const producerTransport = await this.webrtcService.createWebRtcTransport(
      roomId,
      peerId,
      false,
    );
    
    const consumerTransport = await this.webrtcService.createWebRtcTransport(
      roomId,
      peerId,
      true,
    );
    
    // Transport ID'lerini kaydet
    peer.transports.push(producerTransport.params.id);
    peer.transports.push(consumerTransport.params.id);
    
    // Diğer katılımcılara yeni katılımcıyı bildir
    client.to(roomId).emit('newPeer', { peerId });
    
    // Odadaki diğer katılımcıların ID'lerini gönder
    const peerIds = Array.from(room).filter(id => id !== peerId);
    
    return {
      producerTransportOptions: producerTransport.params,
      consumerTransportOptions: consumerTransport.params,
      peers: peerIds,
    };
  }

  // Transport bağlantısı
  @SubscribeMessage('connectTransport')
  async handleConnectTransport(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ConnectTransportParams,
  ) {
    const { transportId, dtlsParameters } = data;
    this.logger.log(`Transport bağlanıyor: ${transportId}`);
    
    await this.webrtcService.connectTransport(transportId, dtlsParameters);
    
    return { connected: true };
  }

  // Medya üretme (yayın yapma)
  @SubscribeMessage('produce')
  async handleProduce(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ProduceParams,
  ) {
    const { transportId, kind, rtpParameters } = data;
    const peerId = client.id;
    this.logger.log(`Medya üretiliyor: ${peerId}, tür: ${kind}`);
    
    const peer = this.peers.get(peerId);
    if (!peer || !peer.roomId) {
      throw new Error('Peer bir odaya katılmamış');
    }
    
    const { producerId } = await this.webrtcService.createProducer(
      transportId,
      rtpParameters,
      kind,
    );
    
    // Producer ID'sini kaydet
    peer.producers.push(producerId);
    
    // Odadaki diğer katılımcılara yeni producer'ı bildir
    client.to(peer.roomId).emit('newProducer', {
      peerId,
      producerId,
      kind,
    });
    
    return { id: producerId };
  }

  // Medya tüketme (dinleme)
  @SubscribeMessage('consume')
  async handleConsume(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ConsumeParams,
  ) {
    const { roomId, transportId, producerId } = data;
    const peerId = client.id;
    this.logger.log(`Medya tüketiliyor: ${peerId}, producer: ${producerId}`);
    
    const peer = this.peers.get(peerId);
    if (!peer) {
      throw new Error('Peer bulunamadı');
    }
    
    // RTP yeteneklerini al (client tarafından gönderilmeli)
    const rtpCapabilities = client.handshake.auth.rtpCapabilities;
    if (!rtpCapabilities) {
      throw new Error('RTP yetenekleri bulunamadı');
    }
    
    const consumerData = await this.webrtcService.createConsumer(
      roomId,
      transportId,
      producerId,
      rtpCapabilities,
    );
    
    // Consumer ID'sini kaydet
    peer.consumers.push(consumerData.consumerId);
    
    return {
      id: consumerData.consumerId,
      producerId: consumerData.producerId,
      kind: consumerData.kind,
      rtpParameters: consumerData.rtpParameters,
    };
  }

  // Consumer'ı devam ettirme
  @SubscribeMessage('resumeConsumer')
  async handleResumeConsumer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { consumerId: string },
  ) {
    const { consumerId } = data;
    this.logger.log(`Consumer devam ettiriliyor: ${consumerId}`);
    
    await this.webrtcService.resumeConsumer(consumerId);
    
    return { resumed: true };
  }

  // Producer'ı kapatma
  @SubscribeMessage('closeProducer')
  async handleCloseProducer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { producerId: string },
  ) {
    const { producerId } = data;
    const peerId = client.id;
    this.logger.log(`Producer kapatılıyor: ${producerId}`);
    
    const peer = this.peers.get(peerId);
    if (!peer || !peer.roomId) {
      throw new Error('Peer bir odaya katılmamış');
    }
    
    // Producer'ı kapat
    await this.webrtcService.closeProducer(producerId);
    
    // Producer ID'sini listeden çıkar
    peer.producers = peer.producers.filter(id => id !== producerId);
    
    // Odadaki diğer katılımcılara producer'ın kapandığını bildir
    client.to(peer.roomId).emit('producerClosed', {
      peerId,
      producerId,
    });
    
    return { closed: true };
  }

  // Odadan ayrılma
  @SubscribeMessage('leaveRoom')
  async handleLeaveRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const { roomId } = data;
    const peerId = client.id;
    this.logger.log(`Client odadan ayrılıyor: ${peerId}, oda: ${roomId}`);
    
    const peer = this.peers.get(peerId);
    if (!peer) {
      return { left: true };
    }
    
    // Tüm producer'ları kapat
    for (const producerId of peer.producers) {
      await this.webrtcService.closeProducer(producerId);
    }
    peer.producers = [];
    
    // Tüm consumer'ları kapat
    for (const consumerId of peer.consumers) {
      await this.webrtcService.closeConsumer(consumerId);
    }
    peer.consumers = [];
    
    // Tüm transport'ları kapat
    for (const transportId of peer.transports) {
      await this.webrtcService.closeTransport(transportId);
    }
    peer.transports = [];
    
    // Odadan çıkar
    const room = this.rooms.get(roomId);
    if (room) {
      room.delete(peerId);
      
      // Oda boşsa router'ı kapat
      if (room.size === 0) {
        await this.webrtcService.closeRouter(roomId);
        this.rooms.delete(roomId);
      } else {
        // Odadaki diğer katılımcılara ayrılan katılımcıyı bildir
        client.to(roomId).emit('peerLeft', { peerId });
      }
    }
    
    // Sesli oturum katılımcı sayısını azalt
    try {
      await this.voiceSessionsService.decrementParticipantCount(roomId);
    } catch (error) {
      this.logger.error(`Katılımcı sayısı azaltılamadı: ${error.message}`);
    }
    
    // Peer bilgilerini güncelle
    peer.roomId = undefined;
    
    return { left: true };
  }
} 