import { 
  WebSocketGateway, 
  WebSocketServer, 
  SubscribeMessage, 
  OnGatewayConnection, 
  OnGatewayDisconnect, 
  ConnectedSocket, 
  MessageBody 
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { WebrtcService } from './webrtc.service';
import { VoiceSessionsService } from '../voice-sessions/voice-sessions.service';

interface JoinRoomParams {
  tourId: string;
  userId: string;
  role: 'guide' | 'participant';
}

interface ConnectTransportParams {
  transportId: string;
  dtlsParameters: any;
}

interface ProduceParams {
  transportId: string;
  rtpParameters: any;
  userId: string;
}

interface ConsumeParams {
  tourId: string;
  transportId: string;
  producerId: string;
  rtpCapabilities: any;
  userId: string;
}

@WebSocketGateway({
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  namespace: 'webrtc',
})
export class WebrtcGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(WebrtcGateway.name);
  private rooms = new Map<string, Set<string>>(); // roomId -> Set<socketId>
  private peers = new Map<string, { socket: Socket; userId: string; roomId: string }>(); // socketId -> peer info
  private producerIdToUserIdMap = new Map<string, string>(); // producerId -> userId

  constructor(
    private readonly webrtcService: WebrtcService,
    private readonly voiceSessionsService: VoiceSessionsService,
  ) {}

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  async handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    const peerInfo = this.peers.get(client.id);
    
    if (peerInfo) {
      const { userId, roomId } = peerInfo;
      
      // Odadan çıkar
      const room = this.rooms.get(roomId);
      if (room) {
        room.delete(client.id);
        
        // Oda boşaldıysa odayı kapat
        if (room.size === 0) {
          this.rooms.delete(roomId);
          await this.webrtcService.closeRouter(roomId);
          this.logger.log(`Room ${roomId} closed because all peers left`);
        } else {
          // Diğer katılımcılara bildirim gönder
          client.to(roomId).emit('peer-left', { userId });
        }
      }
      
      // Katılımcı sayısını azalt
      try {
        await this.voiceSessionsService.decrementParticipantCount(roomId);
      } catch (error) {
        this.logger.error(`Error decrementing participant count: ${error.message}`);
      }
      
      this.peers.delete(client.id);
    }
  }

  @SubscribeMessage('join-room')
  async handleJoinRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: JoinRoomParams,
  ) {
    const { tourId, userId, role } = data;
    
    this.logger.log(`User ${userId} joining room ${tourId} as ${role}`);
    
    // Socket.IO odasına katıl
    client.join(tourId);
    
    // Kayıt yapma
    if (!this.rooms.has(tourId)) {
      this.rooms.set(tourId, new Set());
    }
    
    const room = this.rooms.get(tourId);
    if (!room) {
      throw new Error(`Room not found for tour ID: ${tourId}`);
    }
    
    room.add(client.id);
    this.peers.set(client.id, { socket: client, userId, roomId: tourId });
    
    try {
      // Router oluştur
      await this.webrtcService.createRouter(tourId);
      
      // Transport oluştur
      const transport = await this.webrtcService.createWebRtcTransport(tourId, userId);
      
      // Katılımcı sayısını artır
      await this.voiceSessionsService.incrementParticipantCount(tourId);
      
      // Diğer katılımcılara bildirim gönder
      client.to(tourId).emit('peer-joined', { userId, role });
      
      // Mevcut producer'ları gönder
      const producerIds = [];
      
      for (const [socketId, peer] of this.peers.entries()) {
        if (peer.roomId === tourId && socketId !== client.id) {
          // Burada normalde peer'ın producer ID'lerini toplamamız gerekir
          // Basitlik için şimdilik boş bırakıyoruz
        }
      }
      
      const roomPeers = room ? Array.from(room) : [];
      
      return { 
        transport, 
        peers: roomPeers
          .filter(id => id !== client.id)
          .map(id => {
            const peerInfo = this.peers.get(id);
            return peerInfo ? peerInfo.userId : null;
          })
          .filter(Boolean),
        producerIds,
      };
    } catch (error) {
      this.logger.error(`Error joining room: ${error.message}`);
      // Odadan çıkar
      room.delete(client.id);
      this.peers.delete(client.id);
      throw error;
    }
  }

  @SubscribeMessage('connect-transport')
  async handleConnectTransport(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ConnectTransportParams,
  ) {
    const { transportId, dtlsParameters } = data;
    
    this.logger.log(`Connecting transport: ${transportId}`);
    
    try {
      const result = await this.webrtcService.connectTransport(transportId, dtlsParameters);
      return result;
    } catch (error) {
      this.logger.error(`Error connecting transport: ${error.message}`);
      return { error: error.message };
    }
  }

  @SubscribeMessage('produce')
  async handleProduce(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ProduceParams,
  ) {
    const { transportId, rtpParameters, userId } = data;
    const peerInfo = this.peers.get(client.id);
    
    if (!peerInfo) {
      return { error: 'Peer not found' };
    }
    
    this.logger.log(`User ${userId} producing media`);
    
    try {
      const result = await this.webrtcService.createProducer(transportId, rtpParameters, userId);
      
      // Producer'ı kaydet
      this.producerIdToUserIdMap.set(result.id, userId);
      
      // Odadaki diğer kullanıcılara producer oluşturulduğunu bildir
      client.to(peerInfo.roomId).emit('new-producer', {
        producerId: result.id,
        userId,
      });
      
      return result;
    } catch (error) {
      this.logger.error(`Error producing: ${error.message}`);
      return { error: error.message };
    }
  }

  @SubscribeMessage('consume')
  async handleConsume(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: ConsumeParams,
  ) {
    const { tourId, transportId, producerId, rtpCapabilities, userId } = data;
    
    this.logger.log(`User ${userId} consuming producer ${producerId}`);
    
    try {
      const result = await this.webrtcService.createConsumer(
        tourId,
        transportId,
        producerId,
        rtpCapabilities,
        userId,
      );
      
      return result;
    } catch (error) {
      this.logger.error(`Error consuming: ${error.message}`);
      return { error: error.message };
    }
  }

  @SubscribeMessage('resume-consumer')
  async handleResumeConsumer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { consumerId: string },
  ) {
    const { consumerId } = data;
    
    this.logger.log(`Resuming consumer: ${consumerId}`);
    
    try {
      const result = await this.webrtcService.resumeConsumer(consumerId);
      return result;
    } catch (error) {
      this.logger.error(`Error resuming consumer: ${error.message}`);
      return { error: error.message };
    }
  }

  @SubscribeMessage('close-producer')
  async handleCloseProducer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { producerId: string },
  ) {
    const { producerId } = data;
    const peerInfo = this.peers.get(client.id);
    
    if (!peerInfo) {
      return { error: 'Peer not found' };
    }
    
    this.logger.log(`Closing producer: ${producerId}`);
    
    try {
      const result = await this.webrtcService.closeProducer(producerId);
      
      // Producer'ı sil
      this.producerIdToUserIdMap.delete(producerId);
      
      // Odadaki diğer kullanıcılara producer kapatıldığını bildir
      client.to(peerInfo.roomId).emit('producer-closed', {
        producerId,
        userId: peerInfo.userId,
      });
      
      return result;
    } catch (error) {
      this.logger.error(`Error closing producer: ${error.message}`);
      return { error: error.message };
    }
  }

  @SubscribeMessage('leave-room')
  async handleLeaveRoom(@ConnectedSocket() client: Socket) {
    const peerInfo = this.peers.get(client.id);
    
    if (!peerInfo) {
      return { error: 'Peer not found' };
    }
    
    const { userId, roomId } = peerInfo;
    
    this.logger.log(`User ${userId} leaving room ${roomId}`);
    
    // Odadan çıkar
    client.leave(roomId);
    
    const room = this.rooms.get(roomId);
    if (room) {
      room.delete(client.id);
      
      // Oda boşaldıysa odayı kapat
      if (room.size === 0) {
        this.rooms.delete(roomId);
        await this.webrtcService.closeRouter(roomId);
        this.logger.log(`Room ${roomId} closed because all peers left`);
      } else {
        // Diğer katılımcılara bildirim gönder
        client.to(roomId).emit('peer-left', { userId });
      }
    }
    
    // Katılımcı sayısını azalt
    try {
      await this.voiceSessionsService.decrementParticipantCount(roomId);
    } catch (error) {
      this.logger.error(`Error decrementing participant count: ${error.message}`);
    }
    
    this.peers.delete(client.id);
    
    return { left: true };
  }
} 