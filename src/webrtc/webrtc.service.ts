import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import * as mediasoup from 'mediasoup';
import { Worker, Router, WebRtcTransport, Producer, Consumer } from 'mediasoup/node/lib/types';
import { MediasoupConfig } from './mediasoup-config';

@Injectable()
export class WebrtcService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(WebrtcService.name);
  private mediasoupWorkers: Worker[] = [];
  private routers: Map<string, Router> = new Map(); // tourId -> Router
  private transports: Map<string, WebRtcTransport> = new Map(); // transportId -> Transport
  private producers: Map<string, Producer> = new Map(); // producerId -> Producer
  private consumers: Map<string, Consumer> = new Map(); // consumerId -> Consumer

  /**
   * NestJS lifecycle hook - Uygulama başladığında çalışır
   */
  async onModuleInit() {
    await this.initializeMediasoupWorkers();
    this.logger.log('MediaSoup işçileri başlatıldı');
  }

  /**
   * NestJS lifecycle hook - Uygulama kapandığında çalışır
   */
  async onModuleDestroy() {
    await this.closeMediasoupWorkers();
    this.logger.log('MediaSoup işçileri kapatıldı');
  }

  /**
   * MediaSoup işçilerini başlatır
   * @param workersCount İşçi sayısı
   */
  private async initializeMediasoupWorkers(workersCount = 1) {
    this.logger.log(`${workersCount} MediaSoup işçisi başlatılıyor...`);

    for (let i = 0; i < workersCount; i++) {
      try {
        const worker = await mediasoup.createWorker(MediasoupConfig.workerSettings);

        worker.on('died', () => {
          this.logger.error(`MediaSoup işçisi öldü, PID: ${worker.pid}`);
          // İşçi öldüğünde yerine yenisini oluştur
          this.mediasoupWorkers = this.mediasoupWorkers.filter((w) => w.pid !== worker.pid);
          this.initializeMediasoupWorkers(1);
        });

        this.mediasoupWorkers.push(worker);
        this.logger.log(`MediaSoup işçisi başlatıldı, PID: ${worker.pid}`);
      } catch (error) {
        this.logger.error(`MediaSoup işçisi başlatılamadı: ${error.message}`);
      }
    }
  }

  /**
   * Tüm MediaSoup işçilerini kapatır
   */
  private async closeMediasoupWorkers() {
    for (const worker of this.mediasoupWorkers) {
      await worker.close();
    }
    this.mediasoupWorkers = [];
  }

  /**
   * Belirli bir tur için router oluşturur
   * @param tourId Tur ID
   * @returns Router bilgileri
   */
  async createRouter(tourId: string) {
    try {
      if (this.routers.has(tourId)) {
        return { routerId: tourId };
      }

      const worker = this.getLeastLoadedWorker();
      if (!worker) {
        throw new Error('Kullanılabilir MediaSoup işçisi bulunamadı');
      }

      const router = await worker.createRouter(MediasoupConfig.routerOptions);
      this.routers.set(tourId, router);
      this.logger.log(`Router oluşturuldu, Tur ID: ${tourId}`);

      return { routerId: tourId };
    } catch (error) {
      this.logger.error(`Router oluşturulamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * WebRTC transport oluşturur
   * @param tourId Tur ID
   * @param userId Kullanıcı ID
   * @returns Transport bilgileri
   */
  async createWebRtcTransport(tourId: string, userId: string) {
    try {
      // Eğer router yoksa, oluştur
      if (!this.routers.has(tourId)) {
        await this.createRouter(tourId);
      }

      const router = this.routers.get(tourId);
      if (!router) {
        throw new Error(`Tur ID: ${tourId} için router bulunamadı`);
      }

      // Transport oluştur
      const transport = await router.createWebRtcTransport(MediasoupConfig.webRtcTransportOptions);

      const transportId = transport.id;
      this.transports.set(transportId, transport);
      
      this.logger.log(`WebRTC transport oluşturuldu, ID: ${transportId}, Kullanıcı: ${userId}`);

      // Transport hatalarını dinle
      transport.on('dtlsstatechange', (dtlsState) => {
        if (dtlsState === 'closed' || dtlsState === 'failed') {
          this.logger.warn(`Transport dtls durum değişimi: ${dtlsState}, ID: ${transportId}`);
        }
      });

      transport.on('@close', () => {
        this.logger.log(`Transport kapandı, ID: ${transportId}`);
        this.transports.delete(transportId);
      });

      // Transpor bilgilerini döndür
      return {
        id: transportId,
        iceParameters: transport.iceParameters,
        iceCandidates: transport.iceCandidates,
        dtlsParameters: transport.dtlsParameters,
      };
    } catch (error) {
      this.logger.error(`WebRTC transport oluşturulamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Transport bağlantısını kurar
   * @param transportId Transport ID
   * @param dtlsParameters DTLS parametreleri
   */
  async connectTransport(transportId: string, dtlsParameters: mediasoup.types.DtlsParameters) {
    try {
      const transport = this.transports.get(transportId);
      if (!transport) {
        throw new Error(`Transport bulunamadı, ID: ${transportId}`);
      }

      await transport.connect({ dtlsParameters });
      this.logger.log(`Transport bağlandı, ID: ${transportId}`);
      return { connected: true };
    } catch (error) {
      this.logger.error(`Transport bağlanamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Üretici (Producer) oluşturur
   * @param transportId Transport ID
   * @param rtpParameters RTP parametreleri
   * @param userId Kullanıcı ID
   * @returns Producer bilgileri
   */
  async createProducer(transportId: string, rtpParameters: mediasoup.types.RtpParameters, userId: string) {
    try {
      const transport = this.transports.get(transportId);
      if (!transport) {
        throw new Error(`Transport bulunamadı, ID: ${transportId}`);
      }

      // Producer oluştur
      const producer = await transport.produce({
        kind: 'audio',
        rtpParameters,
        ...MediasoupConfig.producerOptions
      });

      const producerId = producer.id;
      this.producers.set(producerId, producer);
      
      this.logger.log(`Producer oluşturuldu, ID: ${producerId}, Kullanıcı: ${userId}`);

      // Producer hatalarını dinle
      producer.on('transportclose', () => {
        this.logger.log(`Producer'ın transportu kapandı, ID: ${producerId}`);
        this.producers.delete(producerId);
      });

      producer.on('score', (score) => {
        this.logger.debug(`Producer skor güncellendi, ID: ${producerId}, skor: ${JSON.stringify(score)}`);
      });

      return {
        id: producerId,
      };
    } catch (error) {
      this.logger.error(`Producer oluşturulamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Tüketici (Consumer) oluşturur
   * @param tourId Tur ID
   * @param transportId Transport ID
   * @param producerId Producer ID
   * @param rtpCapabilities RTP özellikleri
   * @param userId Kullanıcı ID
   * @returns Consumer bilgileri
   */
  async createConsumer(
    tourId: string, 
    transportId: string, 
    producerId: string, 
    rtpCapabilities: mediasoup.types.RtpCapabilities,
    userId: string,
  ) {
    try {
      const router = this.routers.get(tourId);
      if (!router) {
        throw new Error(`Router bulunamadı, Tur ID: ${tourId}`);
      }

      const transport = this.transports.get(transportId);
      if (!transport) {
        throw new Error(`Transport bulunamadı, ID: ${transportId}`);
      }

      const producer = this.producers.get(producerId);
      if (!producer) {
        throw new Error(`Producer bulunamadı, ID: ${producerId}`);
      }

      // Consumer oluşturulabilir mi kontrol et
      if (!router.canConsume({
        producerId: producerId,
        rtpCapabilities,
      })) {
        throw new Error(`RTP özellikleri yeterli değil, Consumer oluşturulamıyor`);
      }

      // Consumer oluştur
      const consumer = await transport.consume({
        producerId,
        rtpCapabilities,
        paused: true, // Başlangıçta duraklatılmış olarak oluştur
      });

      const consumerId = consumer.id;
      this.consumers.set(consumerId, consumer);
      
      this.logger.log(`Consumer oluşturuldu, ID: ${consumerId}, Kullanıcı: ${userId}`);

      // Consumer hatalarını dinle
      consumer.on('transportclose', () => {
        this.logger.log(`Consumer'ın transportu kapandı, ID: ${consumerId}`);
        this.consumers.delete(consumerId);
      });

      consumer.on('producerclose', () => {
        this.logger.log(`Consumer'ın producer'ı kapandı, ID: ${consumerId}`);
        this.consumers.delete(consumerId);
      });

      return {
        id: consumerId,
        producerId,
        kind: consumer.kind,
        rtpParameters: consumer.rtpParameters,
        type: consumer.type,
        producerPaused: consumer.producerPaused,
      };
    } catch (error) {
      this.logger.error(`Consumer oluşturulamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Consumer'ı devam ettirir
   * @param consumerId Consumer ID
   */
  async resumeConsumer(consumerId: string) {
    try {
      const consumer = this.consumers.get(consumerId);
      if (!consumer) {
        throw new Error(`Consumer bulunamadı, ID: ${consumerId}`);
      }

      await consumer.resume();
      this.logger.log(`Consumer devam ettirildi, ID: ${consumerId}`);
      return { resumed: true };
    } catch (error) {
      this.logger.error(`Consumer devam ettirilemedi: ${error.message}`);
      throw error;
    }
  }

  /**
   * Producer'ı kapatır
   * @param producerId Producer ID
   */
  async closeProducer(producerId: string) {
    try {
      const producer = this.producers.get(producerId);
      if (!producer) {
        throw new Error(`Producer bulunamadı, ID: ${producerId}`);
      }

      await producer.close();
      this.producers.delete(producerId);
      this.logger.log(`Producer kapatıldı, ID: ${producerId}`);
      return { closed: true };
    } catch (error) {
      this.logger.error(`Producer kapatılamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Consumer'ı kapatır
   * @param consumerId Consumer ID
   */
  async closeConsumer(consumerId: string) {
    try {
      const consumer = this.consumers.get(consumerId);
      if (!consumer) {
        throw new Error(`Consumer bulunamadı, ID: ${consumerId}`);
      }

      await consumer.close();
      this.consumers.delete(consumerId);
      this.logger.log(`Consumer kapatıldı, ID: ${consumerId}`);
      return { closed: true };
    } catch (error) {
      this.logger.error(`Consumer kapatılamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Transport'u kapatır
   * @param transportId Transport ID
   */
  async closeTransport(transportId: string) {
    try {
      const transport = this.transports.get(transportId);
      if (!transport) {
        throw new Error(`Transport bulunamadı, ID: ${transportId}`);
      }

      await transport.close();
      this.transports.delete(transportId);
      this.logger.log(`Transport kapatıldı, ID: ${transportId}`);
      return { closed: true };
    } catch (error) {
      this.logger.error(`Transport kapatılamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * Router'ı kapatır
   * @param tourId Tur ID
   */
  async closeRouter(tourId: string) {
    try {
      const router = this.routers.get(tourId);
      if (!router) {
        throw new Error(`Router bulunamadı, Tur ID: ${tourId}`);
      }

      await router.close();
      this.routers.delete(tourId);
      this.logger.log(`Router kapatıldı, Tur ID: ${tourId}`);
      return { closed: true };
    } catch (error) {
      this.logger.error(`Router kapatılamadı: ${error.message}`);
      throw error;
    }
  }

  /**
   * En az yüklü işçiyi döndürür
   * @returns İşçi
   */
  private getLeastLoadedWorker(): Worker {
    // Basit bir load-balancing: en az bağlantı sayısına sahip işçiyi seç
    if (this.mediasoupWorkers.length === 0) {
      return null;
    }
    return this.mediasoupWorkers[0]; // Gerçek uygulamada daha gelişmiş bir algoritma kullanılabilir
  }
} 