import * as os from 'os';
import * as mediasoup from 'mediasoup';

/**
 * MediaSoup konfigürasyon ayarları
 */
export class MediasoupConfig {
  /**
   * mediasoup Worker ayarları.
   */
  public static workerSettings: mediasoup.types.WorkerSettings = {
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

  /**
   * mediasoup Router ayarları.
   */
  public static routerOptions: mediasoup.types.RouterOptions = {
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

  /**
   * WebRtcTransport yapılandırması için ayarlar
   */
  public static webRtcTransportOptions: mediasoup.types.WebRtcTransportOptions = {
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

  /**
   * Ses kalitesi ayarlarını döndürür
   * @param quality Ses kalitesi düzeyi
   */
  public static getAudioQualitySettings(quality: 'low' | 'medium' | 'high'): {
    maxIncomingBitrate: number;
    opusStereo: boolean;
    opusDtx: boolean;
    opusFec: boolean;
    opusMaxPlaybackRate: number;
  } {
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

  /**
   * WebRTC üretici için parametreler
   */
  public static producerOptions = {
    codecOptions: {
      opusStereo: false,
      opusFec: true,
      opusDtx: true,
      opusMaxPlaybackRate: 48000,
    },
  };
}

/**
 * Yerel IP adresini tespit eder
 * @returns Yerel IP adresi
 */
function getLocalIp(): string {
  const ifaces = os.networkInterfaces();
  let localIp = '127.0.0.1';

  Object.keys(ifaces).forEach((ifname) => {
    ifaces[ifname]?.forEach((iface) => {
      if (iface.family === 'IPv4' && !iface.internal) {
        localIp = iface.address;
      }
    });
  });

  return localIp;
} 