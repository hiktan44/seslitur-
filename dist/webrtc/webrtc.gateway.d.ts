import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
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
export declare class WebrtcGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly webrtcService;
    private readonly voiceSessionsService;
    server: Server;
    private readonly logger;
    private rooms;
    private peers;
    private producerIdToUserIdMap;
    constructor(webrtcService: WebrtcService, voiceSessionsService: VoiceSessionsService);
    handleConnection(client: Socket): void;
    handleDisconnect(client: Socket): Promise<void>;
    handleJoinRoom(client: Socket, data: JoinRoomParams): Promise<{
        transport: {
            id: string;
            iceParameters: import("mediasoup/node/lib/WebRtcTransportTypes").IceParameters;
            iceCandidates: import("mediasoup/node/lib/WebRtcTransportTypes").IceCandidate[];
            dtlsParameters: import("mediasoup/node/lib/WebRtcTransportTypes").DtlsParameters;
        };
        peers: string[];
        producerIds: any[];
    }>;
    handleConnectTransport(client: Socket, data: ConnectTransportParams): Promise<{
        connected: boolean;
    } | {
        error: any;
    }>;
    handleProduce(client: Socket, data: ProduceParams): Promise<{
        id: string;
    } | {
        error: any;
    }>;
    handleConsume(client: Socket, data: ConsumeParams): Promise<{
        id: string;
        producerId: string;
        kind: import("mediasoup/node/lib/rtpParametersTypes").MediaKind;
        rtpParameters: import("mediasoup/node/lib/rtpParametersTypes").RtpParameters;
        type: import("mediasoup/node/lib/ConsumerTypes").ConsumerType;
        producerPaused: boolean;
    } | {
        error: any;
    }>;
    handleResumeConsumer(client: Socket, data: {
        consumerId: string;
    }): Promise<{
        resumed: boolean;
    } | {
        error: any;
    }>;
    handleCloseProducer(client: Socket, data: {
        producerId: string;
    }): Promise<{
        closed: boolean;
    } | {
        error: any;
    }>;
    handleLeaveRoom(client: Socket): Promise<{
        error: string;
        left?: undefined;
    } | {
        left: boolean;
        error?: undefined;
    }>;
}
export {};
