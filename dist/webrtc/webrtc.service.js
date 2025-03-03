"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var WebrtcService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.WebrtcService = void 0;
const common_1 = require("@nestjs/common");
const mediasoup = require("mediasoup");
const mediasoup_config_1 = require("./mediasoup-config");
let WebrtcService = WebrtcService_1 = class WebrtcService {
    constructor() {
        this.logger = new common_1.Logger(WebrtcService_1.name);
        this.mediasoupWorkers = [];
        this.routers = new Map();
        this.transports = new Map();
        this.producers = new Map();
        this.consumers = new Map();
    }
    async onModuleInit() {
        await this.initializeMediasoupWorkers();
        this.logger.log('MediaSoup işçileri başlatıldı');
    }
    async onModuleDestroy() {
        await this.closeMediasoupWorkers();
        this.logger.log('MediaSoup işçileri kapatıldı');
    }
    async initializeMediasoupWorkers(workersCount = 1) {
        this.logger.log(`${workersCount} MediaSoup işçisi başlatılıyor...`);
        for (let i = 0; i < workersCount; i++) {
            try {
                const worker = await mediasoup.createWorker(mediasoup_config_1.MediasoupConfig.workerSettings);
                worker.on('died', () => {
                    this.logger.error(`MediaSoup işçisi öldü, PID: ${worker.pid}`);
                    this.mediasoupWorkers = this.mediasoupWorkers.filter((w) => w.pid !== worker.pid);
                    this.initializeMediasoupWorkers(1);
                });
                this.mediasoupWorkers.push(worker);
                this.logger.log(`MediaSoup işçisi başlatıldı, PID: ${worker.pid}`);
            }
            catch (error) {
                this.logger.error(`MediaSoup işçisi başlatılamadı: ${error.message}`);
            }
        }
    }
    async closeMediasoupWorkers() {
        for (const worker of this.mediasoupWorkers) {
            await worker.close();
        }
        this.mediasoupWorkers = [];
    }
    async createRouter(tourId) {
        try {
            if (this.routers.has(tourId)) {
                return { routerId: tourId };
            }
            const worker = this.getLeastLoadedWorker();
            if (!worker) {
                throw new Error('Kullanılabilir MediaSoup işçisi bulunamadı');
            }
            const router = await worker.createRouter(mediasoup_config_1.MediasoupConfig.routerOptions);
            this.routers.set(tourId, router);
            this.logger.log(`Router oluşturuldu, Tur ID: ${tourId}`);
            return { routerId: tourId };
        }
        catch (error) {
            this.logger.error(`Router oluşturulamadı: ${error.message}`);
            throw error;
        }
    }
    async createWebRtcTransport(tourId, userId) {
        try {
            if (!this.routers.has(tourId)) {
                await this.createRouter(tourId);
            }
            const router = this.routers.get(tourId);
            if (!router) {
                throw new Error(`Tur ID: ${tourId} için router bulunamadı`);
            }
            const transport = await router.createWebRtcTransport(mediasoup_config_1.MediasoupConfig.webRtcTransportOptions);
            const transportId = transport.id;
            this.transports.set(transportId, transport);
            this.logger.log(`WebRTC transport oluşturuldu, ID: ${transportId}, Kullanıcı: ${userId}`);
            transport.on('dtlsstatechange', (dtlsState) => {
                if (dtlsState === 'closed' || dtlsState === 'failed') {
                    this.logger.warn(`Transport dtls durum değişimi: ${dtlsState}, ID: ${transportId}`);
                }
            });
            transport.on('@close', () => {
                this.logger.log(`Transport kapandı, ID: ${transportId}`);
                this.transports.delete(transportId);
            });
            return {
                id: transportId,
                iceParameters: transport.iceParameters,
                iceCandidates: transport.iceCandidates,
                dtlsParameters: transport.dtlsParameters,
            };
        }
        catch (error) {
            this.logger.error(`WebRTC transport oluşturulamadı: ${error.message}`);
            throw error;
        }
    }
    async connectTransport(transportId, dtlsParameters) {
        try {
            const transport = this.transports.get(transportId);
            if (!transport) {
                throw new Error(`Transport bulunamadı, ID: ${transportId}`);
            }
            await transport.connect({ dtlsParameters });
            this.logger.log(`Transport bağlandı, ID: ${transportId}`);
            return { connected: true };
        }
        catch (error) {
            this.logger.error(`Transport bağlanamadı: ${error.message}`);
            throw error;
        }
    }
    async createProducer(transportId, rtpParameters, userId) {
        try {
            const transport = this.transports.get(transportId);
            if (!transport) {
                throw new Error(`Transport bulunamadı, ID: ${transportId}`);
            }
            const producer = await transport.produce(Object.assign({ kind: 'audio', rtpParameters }, mediasoup_config_1.MediasoupConfig.producerOptions));
            const producerId = producer.id;
            this.producers.set(producerId, producer);
            this.logger.log(`Producer oluşturuldu, ID: ${producerId}, Kullanıcı: ${userId}`);
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
        }
        catch (error) {
            this.logger.error(`Producer oluşturulamadı: ${error.message}`);
            throw error;
        }
    }
    async createConsumer(tourId, transportId, producerId, rtpCapabilities, userId) {
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
            if (!router.canConsume({
                producerId: producerId,
                rtpCapabilities,
            })) {
                throw new Error(`RTP özellikleri yeterli değil, Consumer oluşturulamıyor`);
            }
            const consumer = await transport.consume({
                producerId,
                rtpCapabilities,
                paused: true,
            });
            const consumerId = consumer.id;
            this.consumers.set(consumerId, consumer);
            this.logger.log(`Consumer oluşturuldu, ID: ${consumerId}, Kullanıcı: ${userId}`);
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
        }
        catch (error) {
            this.logger.error(`Consumer oluşturulamadı: ${error.message}`);
            throw error;
        }
    }
    async resumeConsumer(consumerId) {
        try {
            const consumer = this.consumers.get(consumerId);
            if (!consumer) {
                throw new Error(`Consumer bulunamadı, ID: ${consumerId}`);
            }
            await consumer.resume();
            this.logger.log(`Consumer devam ettirildi, ID: ${consumerId}`);
            return { resumed: true };
        }
        catch (error) {
            this.logger.error(`Consumer devam ettirilemedi: ${error.message}`);
            throw error;
        }
    }
    async closeProducer(producerId) {
        try {
            const producer = this.producers.get(producerId);
            if (!producer) {
                throw new Error(`Producer bulunamadı, ID: ${producerId}`);
            }
            await producer.close();
            this.producers.delete(producerId);
            this.logger.log(`Producer kapatıldı, ID: ${producerId}`);
            return { closed: true };
        }
        catch (error) {
            this.logger.error(`Producer kapatılamadı: ${error.message}`);
            throw error;
        }
    }
    async closeConsumer(consumerId) {
        try {
            const consumer = this.consumers.get(consumerId);
            if (!consumer) {
                throw new Error(`Consumer bulunamadı, ID: ${consumerId}`);
            }
            await consumer.close();
            this.consumers.delete(consumerId);
            this.logger.log(`Consumer kapatıldı, ID: ${consumerId}`);
            return { closed: true };
        }
        catch (error) {
            this.logger.error(`Consumer kapatılamadı: ${error.message}`);
            throw error;
        }
    }
    async closeTransport(transportId) {
        try {
            const transport = this.transports.get(transportId);
            if (!transport) {
                throw new Error(`Transport bulunamadı, ID: ${transportId}`);
            }
            await transport.close();
            this.transports.delete(transportId);
            this.logger.log(`Transport kapatıldı, ID: ${transportId}`);
            return { closed: true };
        }
        catch (error) {
            this.logger.error(`Transport kapatılamadı: ${error.message}`);
            throw error;
        }
    }
    async closeRouter(tourId) {
        try {
            const router = this.routers.get(tourId);
            if (!router) {
                throw new Error(`Router bulunamadı, Tur ID: ${tourId}`);
            }
            await router.close();
            this.routers.delete(tourId);
            this.logger.log(`Router kapatıldı, Tur ID: ${tourId}`);
            return { closed: true };
        }
        catch (error) {
            this.logger.error(`Router kapatılamadı: ${error.message}`);
            throw error;
        }
    }
    getLeastLoadedWorker() {
        if (this.mediasoupWorkers.length === 0) {
            return null;
        }
        return this.mediasoupWorkers[0];
    }
};
exports.WebrtcService = WebrtcService;
exports.WebrtcService = WebrtcService = WebrtcService_1 = __decorate([
    (0, common_1.Injectable)()
], WebrtcService);
//# sourceMappingURL=webrtc.service.js.map