import Foundation
import AVFoundation
import WebRTC

/**
 * WebRTC İletişim Servisi
 * 
 * WebRTC teknolojisini kullanarak gerçek zamanlı sesli iletişim sağlayan servis.
 * mediasoup kütüphanesi ile entegre çalışır ve ses aktarımını Selective Forwarding Unit (SFU) mimarisi ile gerçekleştirir.
 */
class WebRTCService: NSObject {
    
    // MARK: - Singleton
    static let shared = WebRTCService()
    
    // MARK: - Özellikler
    private var peerConnectionFactory: RTCPeerConnectionFactory?
    private var peerConnection: RTCPeerConnection?
    private var audioSource: RTCAudioSource?
    private var audioTrack: RTCAudioTrack?
    private var localAudioStream: RTCMediaStream?
    
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    
    private var signalingClient: SignalingClient?
    private var transportOptions: [String: Any]?
    private var device: MediasoupDevice?
    private var sendTransport: Transport?
    private var receiveTransport: Transport?
    private var producer: Producer?
    private var consumers: [String: Consumer] = [:]
    
    private var connectionState: RTCPeerConnectionState = .new
    private var isMuted = false
    private var isConnected = false
    
    private var roomId: String?
    private var userId: String?
    
    // MARK: - Protokol Delegesi
    weak var delegate: WebRTCServiceDelegate?
    
    // MARK: - Yaşam Döngüsü
    override private init() {
        super.init()
        setupWebRTC()
    }
    
    // MARK: - Kurulum
    private func setupWebRTC() {
        // WebRTC'yi başlat
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        
        // Audio track oluştur
        configureAudioSession()
        createAudioTrack()
        
        // Signaling istemcisini oluştur
        signalingClient = SignalingClient()
        signalingClient?.delegate = self
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Audio session ayarlanamadı: \(error.localizedDescription)")
            delegate?.webRTCService(self, didFailWithError: error)
        }
    }
    
    private func createAudioTrack() {
        guard let factory = peerConnectionFactory else { return }
        
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        audioSource = factory.audioSource(with: audioConstrains)
        
        let audioTrackId = "audio-\(UUID().uuidString)"
        audioTrack = factory.audioTrack(with: audioSource!, trackId: audioTrackId)
        
        localAudioStream = factory.mediaStream(withStreamId: "stream-\(UUID().uuidString)")
        if let audioTrack = audioTrack {
            localAudioStream?.addAudioTrack(audioTrack)
        }
    }
    
    // MARK: - Bağlantı Yönetimi
    func connect(to roomId: String, userId: String) {
        self.roomId = roomId
        self.userId = userId
        
        // Oturuma bağlan
        signalingClient?.connect(roomId: roomId, userId: userId)
    }
    
    func disconnect() {
        // Üreticiyi kapat
        if let producer = producer {
            producer.close()
            self.producer = nil
        }
        
        // Tüm tüketicileri kapat
        for (_, consumer) in consumers {
            consumer.close()
        }
        consumers.removeAll()
        
        // Transport'ları kapat
        if let sendTransport = sendTransport {
            sendTransport.close()
            self.sendTransport = nil
        }
        
        if let receiveTransport = receiveTransport {
            receiveTransport.close()
            self.receiveTransport = nil
        }
        
        // Cihazı temizle
        device = nil
        
        // Signaling istemcisini kapat
        signalingClient?.disconnect()
        
        // Audio session'ı deaktif et
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session kapatılamadı: \(error.localizedDescription)")
        }
        
        isConnected = false
        delegate?.webRTCServiceDidDisconnect(self)
    }
    
    // MARK: - Medya Kontrolü
    func muteAudio(_ mute: Bool) {
        guard let audioTrack = audioTrack else { return }
        audioTrack.isEnabled = !mute
        isMuted = mute
        
        // Sunucuya ses durumunu bildir
        if let producer = producer {
            if mute {
                producer.pause()
            } else {
                producer.resume()
            }
        }
        
        delegate?.webRTCService(self, didUpdateAudioMuted: mute)
    }
    
    func toggleAudio() -> Bool {
        muteAudio(!isMuted)
        return isMuted
    }
    
    // MARK: - Mediasoup İşlemleri
    private func loadDevice(routerRtpCapabilities: [String: Any]) {
        device = MediasoupDevice()
        
        do {
            try device?.load(routerRtpCapabilities: routerRtpCapabilities)
            createTransports()
        } catch {
            print("Mediasoup cihazı yüklenemedi: \(error.localizedDescription)")
            delegate?.webRTCService(self, didFailWithError: error)
        }
    }
    
    private func createTransports() {
        guard let device = device, let signalingClient = signalingClient else { return }
        
        // Gönderme transport oluşturma isteği
        signalingClient.createSendTransport { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let transportOptions):
                if device.canProduce(kind: .audio) {
                    // Gönderme transport oluştur
                    self.sendTransport = device.createSendTransport(id: transportOptions.id,
                                                               iceParameters: transportOptions.iceParameters,
                                                               iceCandidates: transportOptions.iceCandidates,
                                                               dtlsParameters: transportOptions.dtlsParameters,
                                                               sctpParameters: nil,
                                                               listener: self)
                    
                    // Ses üreticisi oluştur
                    self.createProducer()
                }
                
                // Alma transport oluşturma isteği
                self.createReceiveTransport()
                
            case .failure(let error):
                print("Gönderme transport oluşturulamadı: \(error.localizedDescription)")
                self.delegate?.webRTCService(self, didFailWithError: error)
            }
        }
    }
    
    private func createReceiveTransport() {
        guard let device = device, let signalingClient = signalingClient else { return }
        
        signalingClient.createReceiveTransport { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let transportOptions):
                // Alma transport oluştur
                self.receiveTransport = device.createRecvTransport(id: transportOptions.id,
                                                              iceParameters: transportOptions.iceParameters,
                                                              iceCandidates: transportOptions.iceCandidates,
                                                              dtlsParameters: transportOptions.dtlsParameters,
                                                              sctpParameters: nil,
                                                              listener: self)
                
                // RTP yeteneklerini sunucuya bildir
                if let rtpCapabilities = device.rtpCapabilities {
                    self.signalingClient?.joinRoom(rtpCapabilities: rtpCapabilities)
                }
                
            case .failure(let error):
                print("Alma transport oluşturulamadı: \(error.localizedDescription)")
                self.delegate?.webRTCService(self, didFailWithError: error)
            }
        }
    }
    
    private func createProducer() {
        guard let sendTransport = sendTransport, let audioTrack = audioTrack else { return }
        
        let codecOptions: [String: Any] = [
            "opusStereo": false,
            "opusDtx": true,
            "opusFec": true,
            "opusPtime": 20,
            "opusMaxPlaybackRate": 48000
        ]
        
        do {
            producer = try sendTransport.produce(track: audioTrack,
                                             encodings: nil,
                                             codecOptions: codecOptions,
                                             appData: ["peerId": userId ?? ""])
            
            isConnected = true
            delegate?.webRTCServiceDidConnect(self)
        } catch {
            print("Ses üreticisi oluşturulamadı: \(error.localizedDescription)")
            delegate?.webRTCService(self, didFailWithError: error)
        }
    }
    
    func consumeAudio(producerId: String, streamId: String) {
        guard let receiveTransport = receiveTransport, 
              let device = device, 
              let rtpCapabilities = device.rtpCapabilities else { return }
        
        signalingClient?.consumeAudio(producerId: producerId, rtpCapabilities: rtpCapabilities) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let consumerOptions):
                do {
                    let consumer = try receiveTransport.consume(id: consumerOptions.id,
                                                    producerId: producerId,
                                                    kind: .audio,
                                                    rtpParameters: consumerOptions.rtpParameters)
                    
                    self.consumers[producerId] = consumer
                    self.delegate?.webRTCService(self, didAddRemoteAudioTrack: consumer.track, peerId: consumerOptions.peerId)
                } catch {
                    print("Ses tüketicisi oluşturulamadı: \(error.localizedDescription)")
                    self.delegate?.webRTCService(self, didFailWithError: error)
                }
                
            case .failure(let error):
                print("Ses tüketme parametreleri alınamadı: \(error.localizedDescription)")
                self.delegate?.webRTCService(self, didFailWithError: error)
            }
        }
    }
}

// MARK: - SignalingClientDelegate
extension WebRTCService: SignalingClientDelegate {
    func signalingClient(_ client: SignalingClient, didReceiveRouterRtpCapabilities capabilities: [String: Any]) {
        loadDevice(routerRtpCapabilities: capabilities)
    }
    
    func signalingClient(_ client: SignalingClient, didReceiveNewProducer producerId: String, peerId: String) {
        consumeAudio(producerId: producerId, streamId: peerId)
    }
    
    func signalingClient(_ client: SignalingClient, didProducerClose producerId: String) {
        if let consumer = consumers[producerId] {
            consumer.close()
            consumers.removeValue(forKey: producerId)
            delegate?.webRTCService(self, didRemoveRemoteAudioTrack: consumer.track)
        }
    }
    
    func signalingClient(_ client: SignalingClient, didConnect connected: Bool) {
        if connected {
            client.getRouterRtpCapabilities()
        } else {
            delegate?.webRTCServiceDidDisconnect(self)
        }
    }
    
    func signalingClient(_ client: SignalingClient, didFailWithError error: Error) {
        delegate?.webRTCService(self, didFailWithError: error)
    }
}

// MARK: - SendTransportListener
extension WebRTCService: SendTransportListener {
    func onConnect(_ transport: Transport, dtlsParameters: [String: Any]) {
        signalingClient?.connectSendTransport(transportId: transport.id, dtlsParameters: dtlsParameters)
    }
    
    func onConnectionStateChange(_ transport: Transport, connectionState: TransportConnectionState) {
        // Bağlantı durumu değişikliklerini izle
    }
    
    func onProduce(_ transport: Transport, kind: MediaKind, rtpParameters: [String: Any], appData: [String: Any]?, callback: @escaping ([String: Any]) -> Void) {
        signalingClient?.produce(transportId: transport.id, kind: kind.rawValue, rtpParameters: rtpParameters, appData: appData) { producerId in
            callback(["id": producerId])
        }
    }
}

// MARK: - RecvTransportListener
extension WebRTCService: RecvTransportListener {
    func onConnect(_ transport: Transport, dtlsParameters: [String: Any]) {
        signalingClient?.connectReceiveTransport(transportId: transport.id, dtlsParameters: dtlsParameters)
    }
}

// MARK: - Protokol Tanımlamaları
protocol WebRTCServiceDelegate: AnyObject {
    func webRTCServiceDidConnect(_ service: WebRTCService)
    func webRTCServiceDidDisconnect(_ service: WebRTCService)
    func webRTCService(_ service: WebRTCService, didUpdateAudioMuted muted: Bool)
    func webRTCService(_ service: WebRTCService, didAddRemoteAudioTrack track: RTCAudioTrack, peerId: String)
    func webRTCService(_ service: WebRTCService, didRemoveRemoteAudioTrack track: RTCAudioTrack)
    func webRTCService(_ service: WebRTCService, didFailWithError error: Error)
}

// MARK: - Yardımcı Sınıflar (Gerçek uygulamada gerçek implemetasyonlar olacak)
class MediasoupDevice {
    var rtpCapabilities: [String: Any]?
    
    func load(routerRtpCapabilities: [String: Any]) throws {
        // Gerçek uygulamada mediasoup-client kütüphanesini kullanarak cihaz yüklenir
        rtpCapabilities = routerRtpCapabilities
    }
    
    func canProduce(kind: MediaKind) -> Bool {
        // Gerçek uygulamada mediasoup-client kütüphanesini kullanarak kontrol yapılır
        return true
    }
    
    func createSendTransport(id: String, iceParameters: [String: Any], iceCandidates: [[String: Any]], dtlsParameters: [String: Any], sctpParameters: [String: Any]?, listener: SendTransportListener) -> Transport {
        // Gerçek uygulamada mediasoup-client kütüphanesini kullanarak transport oluşturulur
        return Transport(id: id, kind: .send, listener: listener)
    }
    
    func createRecvTransport(id: String, iceParameters: [String: Any], iceCandidates: [[String: Any]], dtlsParameters: [String: Any], sctpParameters: [String: Any]?, listener: RecvTransportListener) -> Transport {
        // Gerçek uygulamada mediasoup-client kütüphanesini kullanarak transport oluşturulur
        return Transport(id: id, kind: .receive, listener: listener)
    }
}

enum MediaKind: String {
    case audio
    case video
}

enum TransportKind {
    case send
    case receive
}

enum TransportConnectionState {
    case new
    case connecting
    case connected
    case failed
    case disconnected
    case closed
}

class Transport {
    let id: String
    let kind: TransportKind
    
    init(id: String, kind: TransportKind, listener: Any) {
        self.id = id
        self.kind = kind
    }
    
    func produce(track: RTCAudioTrack, encodings: [[String: Any]]?, codecOptions: [String: Any]?, appData: [String: Any]?) throws -> Producer {
        // Gerçek uygulamada mediasoup-client kütüphanesini kullanarak ses üreticisi oluşturulur
        return Producer(id: UUID().uuidString, track: track)
    }
    
    func consume(id: String, producerId: String, kind: MediaKind, rtpParameters: [String: Any]) throws -> Consumer {
        // Gerçek uygulamada mediasoup-client kütüphanesini kullanarak ses tüketicisi oluşturulur
        let track = RTCAudioTrack(factory: RTCPeerConnectionFactory(), trackId: "remote-\(UUID().uuidString)")
        return Consumer(id: id, producerId: producerId, track: track)
    }
    
    func close() {
        // Transport'u kapat
    }
}

class Producer {
    let id: String
    let track: RTCAudioTrack
    
    init(id: String, track: RTCAudioTrack) {
        self.id = id
        self.track = track
    }
    
    func pause() {
        // Ses üretimini duraklat
        track.isEnabled = false
    }
    
    func resume() {
        // Ses üretimini devam ettir
        track.isEnabled = true
    }
    
    func close() {
        // Üreticiyi kapat
    }
}

class Consumer {
    let id: String
    let producerId: String
    let track: RTCAudioTrack
    
    init(id: String, producerId: String, track: RTCAudioTrack) {
        self.id = id
        self.producerId = producerId
        self.track = track
    }
    
    func close() {
        // Tüketiciyi kapat
    }
}

// MARK: - Signaling İstemcisi
class SignalingClient {
    weak var delegate: SignalingClientDelegate?
    private var webSocket: URLSessionWebSocketTask?
    private var roomId: String?
    private var userId: String?
    
    func connect(roomId: String, userId: String) {
        self.roomId = roomId
        self.userId = userId
        
        // WebSocket bağlantısı kurma - Gerçek uygulamada gerçek WebSocket kullanılır
        // Bu örnekte taklit ediyoruz
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.signalingClient(self, didConnect: true)
        }
    }
    
    func disconnect() {
        // WebSocket bağlantısını kapat
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        
        delegate?.signalingClient(self, didConnect: false)
    }
    
    func getRouterRtpCapabilities() {
        // Gerçek uygulamada sunucudan RTP yeteneklerini alır
        let capabilities: [String: Any] = [
            "codecs": [
                ["kind": "audio", "mimeType": "audio/opus", "clockRate": 48000, "channels": 2, "parameters": ["foo": "bar"]]
            ],
            "headerExtensions": []
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.signalingClient(self, didReceiveRouterRtpCapabilities: capabilities)
        }
    }
    
    func createSendTransport(completion: @escaping (Result<TransportOptions, Error>) -> Void) {
        // Gerçek uygulamada sunucudan transport oluşturma parametrelerini alır
        let options = TransportOptions(
            id: "send-" + UUID().uuidString,
            iceParameters: ["usernameFragment": "foo", "password": "bar", "iceLite": true],
            iceCandidates: [["foundation": "udpcandidate", "ip": "127.0.0.1", "port": 10000, "priority": 1]],
            dtlsParameters: ["role": "auto", "fingerprints": [["algorithm": "sha-256", "value": "foo:bar:buzz"]]]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(options))
        }
    }
    
    func createReceiveTransport(completion: @escaping (Result<TransportOptions, Error>) -> Void) {
        // Gerçek uygulamada sunucudan transport oluşturma parametrelerini alır
        let options = TransportOptions(
            id: "recv-" + UUID().uuidString,
            iceParameters: ["usernameFragment": "foo", "password": "bar", "iceLite": true],
            iceCandidates: [["foundation": "udpcandidate", "ip": "127.0.0.1", "port": 20000, "priority": 1]],
            dtlsParameters: ["role": "auto", "fingerprints": [["algorithm": "sha-256", "value": "foo:bar:buzz"]]]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(options))
        }
    }
    
    func connectSendTransport(transportId: String, dtlsParameters: [String: Any]) {
        // Gerçek uygulamada sunucuya transport bağlantı parametrelerini gönderir
    }
    
    func connectReceiveTransport(transportId: String, dtlsParameters: [String: Any]) {
        // Gerçek uygulamada sunucuya transport bağlantı parametrelerini gönderir
    }
    
    func produce(transportId: String, kind: String, rtpParameters: [String: Any], appData: [String: Any]?, completion: @escaping (String) -> Void) {
        // Gerçek uygulamada sunucuya yeni üretici oluşturma isteği gönderir
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion("producer-" + UUID().uuidString)
        }
    }
    
    func joinRoom(rtpCapabilities: [String: Any]) {
        // Gerçek uygulamada odaya katılma ve RTP yeteneklerini gönderme
        
        // Odada başka kullanıcılar olduğunu simüle et
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.delegate?.signalingClient(self, didReceiveNewProducer: "remote-producer-1", peerId: "user-123")
        }
    }
    
    func consumeAudio(producerId: String, rtpCapabilities: [String: Any], completion: @escaping (Result<ConsumerOptions, Error>) -> Void) {
        // Gerçek uygulamada sunucudan tüketici parametrelerini alır
        let options = ConsumerOptions(
            id: "consumer-" + UUID().uuidString,
            producerId: producerId,
            rtpParameters: ["codecs": []],
            peerId: "user-123"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(options))
        }
    }
}

protocol SignalingClientDelegate: AnyObject {
    func signalingClient(_ client: SignalingClient, didReceiveRouterRtpCapabilities capabilities: [String: Any])
    func signalingClient(_ client: SignalingClient, didReceiveNewProducer producerId: String, peerId: String)
    func signalingClient(_ client: SignalingClient, didProducerClose producerId: String)
    func signalingClient(_ client: SignalingClient, didConnect connected: Bool)
    func signalingClient(_ client: SignalingClient, didFailWithError error: Error)
}

protocol SendTransportListener: AnyObject {
    func onConnect(_ transport: Transport, dtlsParameters: [String: Any])
    func onConnectionStateChange(_ transport: Transport, connectionState: TransportConnectionState)
    func onProduce(_ transport: Transport, kind: MediaKind, rtpParameters: [String: Any], appData: [String: Any]?, callback: @escaping ([String: Any]) -> Void)
}

protocol RecvTransportListener: AnyObject {
    func onConnect(_ transport: Transport, dtlsParameters: [String: Any])
    func onConnectionStateChange(_ transport: Transport, connectionState: TransportConnectionState)
}

// MARK: - Yardımcı Yapılar
struct TransportOptions {
    let id: String
    let iceParameters: [String: Any]
    let iceCandidates: [[String: Any]]
    let dtlsParameters: [String: Any]
}

struct ConsumerOptions {
    let id: String
    let producerId: String
    let rtpParameters: [String: Any]
    let peerId: String
} 