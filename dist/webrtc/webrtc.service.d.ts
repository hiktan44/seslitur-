import { OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import * as mediasoup from 'mediasoup';
export declare class WebrtcService implements OnModuleInit, OnModuleDestroy {
    private readonly logger;
    private mediasoupWorkers;
    private routers;
    private transports;
    private producers;
    private consumers;
    onModuleInit(): Promise<void>;
    onModuleDestroy(): Promise<void>;
    private initializeMediasoupWorkers;
    private closeMediasoupWorkers;
    createRouter(tourId: string): Promise<{
        routerId: string;
    }>;
    createWebRtcTransport(tourId: string, userId: string): Promise<{
        id: string;
        iceParameters: mediasoup.types.IceParameters;
        iceCandidates: mediasoup.types.IceCandidate[];
        dtlsParameters: mediasoup.types.DtlsParameters;
    }>;
    connectTransport(transportId: string, dtlsParameters: mediasoup.types.DtlsParameters): Promise<{
        connected: boolean;
    }>;
    createProducer(transportId: string, rtpParameters: mediasoup.types.RtpParameters, userId: string): Promise<{
        id: string;
    }>;
    createConsumer(tourId: string, transportId: string, producerId: string, rtpCapabilities: mediasoup.types.RtpCapabilities, userId: string): Promise<{
        id: string;
        producerId: string;
        kind: mediasoup.types.MediaKind;
        rtpParameters: mediasoup.types.RtpParameters;
        type: mediasoup.types.ConsumerType;
        producerPaused: boolean;
    }>;
    resumeConsumer(consumerId: string): Promise<{
        resumed: boolean;
    }>;
    closeProducer(producerId: string): Promise<{
        closed: boolean;
    }>;
    closeConsumer(consumerId: string): Promise<{
        closed: boolean;
    }>;
    closeTransport(transportId: string): Promise<{
        closed: boolean;
    }>;
    closeRouter(tourId: string): Promise<{
        closed: boolean;
    }>;
    private getLeastLoadedWorker;
}
