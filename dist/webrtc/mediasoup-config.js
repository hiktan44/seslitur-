"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediasoupConfig = void 0;
const os = require("os");
class MediasoupConfig {
    static getAudioQualitySettings(quality) {
        switch (quality) {
            case 'low':
                return {
                    maxIncomingBitrate: 32000,
                    opusStereo: false,
                    opusDtx: true,
                    opusFec: true,
                    opusMaxPlaybackRate: 8000,
                };
            case 'medium':
                return {
                    maxIncomingBitrate: 64000,
                    opusStereo: false,
                    opusDtx: true,
                    opusFec: true,
                    opusMaxPlaybackRate: 16000,
                };
            case 'high':
                return {
                    maxIncomingBitrate: 128000,
                    opusStereo: true,
                    opusDtx: false,
                    opusFec: true,
                    opusMaxPlaybackRate: 48000,
                };
            default:
                return this.getAudioQualitySettings('medium');
        }
    }
}
exports.MediasoupConfig = MediasoupConfig;
MediasoupConfig.workerSettings = {
    logLevel: 'warn',
    logTags: [
        'info',
        'ice',
        'dtls',
        'rtp',
        'srtp',
        'rtcp',
        'rtx',
        'bwe',
        'score',
        'simulcast',
        'svc',
        'sctp'
    ],
    rtcMinPort: 10000,
    rtcMaxPort: 59999,
};
MediasoupConfig.routerOptions = {
    mediaCodecs: [
        {
            kind: 'audio',
            mimeType: 'audio/opus',
            clockRate: 48000,
            channels: 2,
            parameters: {
                minptime: 10,
                useinbandfec: 1,
            },
        },
    ],
};
MediasoupConfig.webRtcTransportOptions = {
    listenIps: [
        {
            ip: process.env.MEDIASOUP_LISTEN_IP || '0.0.0.0',
            announcedIp: process.env.MEDIASOUP_ANNOUNCED_IP || getLocalIp(),
        },
    ],
    initialAvailableOutgoingBitrate: 800000,
    maxSctpMessageSize: 262144,
    enableTcp: true,
    enableUdp: true,
    preferUdp: true,
    enableSctp: false,
};
MediasoupConfig.producerOptions = {
    codecOptions: {
        opusStereo: false,
        opusFec: true,
        opusDtx: true,
        opusMaxPlaybackRate: 48000,
    },
};
function getLocalIp() {
    const ifaces = os.networkInterfaces();
    let localIp = '127.0.0.1';
    Object.keys(ifaces).forEach((ifname) => {
        var _a;
        (_a = ifaces[ifname]) === null || _a === void 0 ? void 0 : _a.forEach((iface) => {
            if (iface.family === 'IPv4' && !iface.internal) {
                localIp = iface.address;
            }
        });
    });
    return localIp;
}
//# sourceMappingURL=mediasoup-config.js.map