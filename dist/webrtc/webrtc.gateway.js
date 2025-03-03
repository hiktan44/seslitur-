"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var WebrtcGateway_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.WebrtcGateway = void 0;
const websockets_1 = require("@nestjs/websockets");
const socket_io_1 = require("socket.io");
const common_1 = require("@nestjs/common");
const webrtc_service_1 = require("./webrtc.service");
const voice_sessions_service_1 = require("../voice-sessions/voice-sessions.service");
let WebrtcGateway = WebrtcGateway_1 = class WebrtcGateway {
    constructor(webrtcService, voiceSessionsService) {
        this.webrtcService = webrtcService;
        this.voiceSessionsService = voiceSessionsService;
        this.logger = new common_1.Logger(WebrtcGateway_1.name);
        this.rooms = new Map();
        this.peers = new Map();
        this.producerIdToUserIdMap = new Map();
    }
    handleConnection(client) {
        this.logger.log(`Client connected: ${client.id}`);
    }
    async handleDisconnect(client) {
        this.logger.log(`Client disconnected: ${client.id}`);
        const peerInfo = this.peers.get(client.id);
        if (peerInfo) {
            const { userId, roomId } = peerInfo;
            const room = this.rooms.get(roomId);
            if (room) {
                room.delete(client.id);
                if (room.size === 0) {
                    this.rooms.delete(roomId);
                    await this.webrtcService.closeRouter(roomId);
                    this.logger.log(`Room ${roomId} closed because all peers left`);
                }
                else {
                    client.to(roomId).emit('peer-left', { userId });
                }
            }
            try {
                await this.voiceSessionsService.decrementParticipantCount(roomId);
            }
            catch (error) {
                this.logger.error(`Error decrementing participant count: ${error.message}`);
            }
            this.peers.delete(client.id);
        }
    }
    async handleJoinRoom(client, data) {
        const { tourId, userId, role } = data;
        this.logger.log(`User ${userId} joining room ${tourId} as ${role}`);
        client.join(tourId);
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
            await this.webrtcService.createRouter(tourId);
            const transport = await this.webrtcService.createWebRtcTransport(tourId, userId);
            await this.voiceSessionsService.incrementParticipantCount(tourId);
            client.to(tourId).emit('peer-joined', { userId, role });
            const producerIds = [];
            for (const [socketId, peer] of this.peers.entries()) {
                if (peer.roomId === tourId && socketId !== client.id) {
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
        }
        catch (error) {
            this.logger.error(`Error joining room: ${error.message}`);
            room.delete(client.id);
            this.peers.delete(client.id);
            throw error;
        }
    }
    async handleConnectTransport(client, data) {
        const { transportId, dtlsParameters } = data;
        this.logger.log(`Connecting transport: ${transportId}`);
        try {
            const result = await this.webrtcService.connectTransport(transportId, dtlsParameters);
            return result;
        }
        catch (error) {
            this.logger.error(`Error connecting transport: ${error.message}`);
            return { error: error.message };
        }
    }
    async handleProduce(client, data) {
        const { transportId, rtpParameters, userId } = data;
        const peerInfo = this.peers.get(client.id);
        if (!peerInfo) {
            return { error: 'Peer not found' };
        }
        this.logger.log(`User ${userId} producing media`);
        try {
            const result = await this.webrtcService.createProducer(transportId, rtpParameters, userId);
            this.producerIdToUserIdMap.set(result.id, userId);
            client.to(peerInfo.roomId).emit('new-producer', {
                producerId: result.id,
                userId,
            });
            return result;
        }
        catch (error) {
            this.logger.error(`Error producing: ${error.message}`);
            return { error: error.message };
        }
    }
    async handleConsume(client, data) {
        const { tourId, transportId, producerId, rtpCapabilities, userId } = data;
        this.logger.log(`User ${userId} consuming producer ${producerId}`);
        try {
            const result = await this.webrtcService.createConsumer(tourId, transportId, producerId, rtpCapabilities, userId);
            return result;
        }
        catch (error) {
            this.logger.error(`Error consuming: ${error.message}`);
            return { error: error.message };
        }
    }
    async handleResumeConsumer(client, data) {
        const { consumerId } = data;
        this.logger.log(`Resuming consumer: ${consumerId}`);
        try {
            const result = await this.webrtcService.resumeConsumer(consumerId);
            return result;
        }
        catch (error) {
            this.logger.error(`Error resuming consumer: ${error.message}`);
            return { error: error.message };
        }
    }
    async handleCloseProducer(client, data) {
        const { producerId } = data;
        const peerInfo = this.peers.get(client.id);
        if (!peerInfo) {
            return { error: 'Peer not found' };
        }
        this.logger.log(`Closing producer: ${producerId}`);
        try {
            const result = await this.webrtcService.closeProducer(producerId);
            this.producerIdToUserIdMap.delete(producerId);
            client.to(peerInfo.roomId).emit('producer-closed', {
                producerId,
                userId: peerInfo.userId,
            });
            return result;
        }
        catch (error) {
            this.logger.error(`Error closing producer: ${error.message}`);
            return { error: error.message };
        }
    }
    async handleLeaveRoom(client) {
        const peerInfo = this.peers.get(client.id);
        if (!peerInfo) {
            return { error: 'Peer not found' };
        }
        const { userId, roomId } = peerInfo;
        this.logger.log(`User ${userId} leaving room ${roomId}`);
        client.leave(roomId);
        const room = this.rooms.get(roomId);
        if (room) {
            room.delete(client.id);
            if (room.size === 0) {
                this.rooms.delete(roomId);
                await this.webrtcService.closeRouter(roomId);
                this.logger.log(`Room ${roomId} closed because all peers left`);
            }
            else {
                client.to(roomId).emit('peer-left', { userId });
            }
        }
        try {
            await this.voiceSessionsService.decrementParticipantCount(roomId);
        }
        catch (error) {
            this.logger.error(`Error decrementing participant count: ${error.message}`);
        }
        this.peers.delete(client.id);
        return { left: true };
    }
};
exports.WebrtcGateway = WebrtcGateway;
__decorate([
    (0, websockets_1.WebSocketServer)(),
    __metadata("design:type", socket_io_1.Server)
], WebrtcGateway.prototype, "server", void 0);
__decorate([
    (0, websockets_1.SubscribeMessage)('join-room'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleJoinRoom", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('connect-transport'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleConnectTransport", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('produce'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleProduce", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('consume'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleConsume", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('resume-consumer'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleResumeConsumer", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('close-producer'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __param(1, (0, websockets_1.MessageBody)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket, Object]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleCloseProducer", null);
__decorate([
    (0, websockets_1.SubscribeMessage)('leave-room'),
    __param(0, (0, websockets_1.ConnectedSocket)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [socket_io_1.Socket]),
    __metadata("design:returntype", Promise)
], WebrtcGateway.prototype, "handleLeaveRoom", null);
exports.WebrtcGateway = WebrtcGateway = WebrtcGateway_1 = __decorate([
    (0, websockets_1.WebSocketGateway)({
        cors: {
            origin: '*',
            methods: ['GET', 'POST'],
        },
        namespace: 'webrtc',
    }),
    __metadata("design:paramtypes", [webrtc_service_1.WebrtcService,
        voice_sessions_service_1.VoiceSessionsService])
], WebrtcGateway);
//# sourceMappingURL=webrtc.gateway.js.map