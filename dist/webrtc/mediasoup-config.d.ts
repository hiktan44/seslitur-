import * as mediasoup from 'mediasoup';
export declare class MediasoupConfig {
    static workerSettings: mediasoup.types.WorkerSettings;
    static routerOptions: mediasoup.types.RouterOptions;
    static webRtcTransportOptions: mediasoup.types.WebRtcTransportOptions;
    static getAudioQualitySettings(quality: 'low' | 'medium' | 'high'): {
        maxIncomingBitrate: number;
        opusStereo: boolean;
        opusDtx: boolean;
        opusFec: boolean;
        opusMaxPlaybackRate: number;
    };
    static producerOptions: {
        codecOptions: {
            opusStereo: boolean;
            opusFec: boolean;
            opusDtx: boolean;
            opusMaxPlaybackRate: number;
        };
    };
}
