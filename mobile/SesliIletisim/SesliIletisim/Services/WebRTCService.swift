// WebRTCService.swift
// SesliIletisim uygulaması için WebRTC servisi

#if DEBUG
// DEBUG modu için mock (sahte) WebRTC servisi
import Foundation
import AVFoundation

/// DEBUG modu için WebRTC servisinin mock (sahte) implementasyonu
class WebRTCService {
    /// Sınıfın tek örneği (Singleton)
    static let shared = WebRTCService()
    
    /// Katılımcı listesi
    private(set) var participants: [String: String] = [:]
    
    /// Mikrofonun etkin olup olmadığı
    private var microphoneEnabled: Bool = false
    
    /// Oturumun aktif olup olmadığı
    private var sessionActive: Bool = false
    
    /// Şu anki oturum ID'si
    private var currentSessionId: String?
    
    /// Kullanıcı kimliği
    private var userId: String?
    
    /// Logger fonksiyonu
    private func log(_ message: String) {
        print("[WebRTCService-DEBUG] \(message)")
    }
    
    /// Gizli başlatıcı
    private init() {
        log("WebRTC servisi başlatıldı (DEBUG mod)")
        setupAudioSession()
        
        // Sahte katılımcıları ekle
        for i in 1...5 {
            let userId = "user\(i)"
            participants[userId] = "Test Kullanıcı \(i)"
        }
    }
    
    /// Ses oturumunu yapılandırır
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat)
            try AVAudioSession.sharedInstance().setActive(true)
            log("Ses oturumu yapılandırıldı")
        } catch {
            log("Ses oturumu yapılandırılırken hata: \(error.localizedDescription)")
        }
    }
    
    /**
     * Bir sesli oturuma bağlanır
     * - Parameters:
     *   - sessionId: Bağlanılacak oturum ID'si
     *   - completion: Tamamlanma bloğu, bağlantı sonucunu döndürür
     */
    func connect(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        log("Oturuma bağlanılıyor: \(sessionId)")
        
        // Bağlantı simulasyonu - DEBUG modunda gerçek bir bağlantı yapılmaz
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.currentSessionId = sessionId
            self.sessionActive = true
            
            // Bazı test katılımcıları ekleyelim
            self.participants["user1"] = "Ahmet Yılmaz"
            self.participants["user2"] = "Mehmet Demir"
            self.participants["user3"] = "Ayşe Kaya"
            
            self.log("Oturuma bağlantı başarılı: \(sessionId)")
            completion(.success(()))
        }
    }
    
    /**
     * WebRTC bağlantısını sonlandırır
     */
    func disconnect() {
        log("Oturum bağlantısı sonlandırılıyor")
        
        // Oturumu temizle
        sessionActive = false
        participants.removeAll()
        currentSessionId = nil
        
        log("Oturum bağlantısı sonlandırıldı")
    }
    
    /**
     * Mikrofon durumunu ayarlar
     * - Parameter enabled: Mikrofonun açık olup olmayacağı
     */
    func setMicrophoneEnabled(_ enabled: Bool) {
        microphoneEnabled = enabled
        log("Mikrofon durumu değiştirildi: \(enabled ? "açık" : "kapalı")")
    }
    
    /**
     * Mikrofonun etkin olup olmadığını döndürür
     * - Returns: Mikrofonun etkin olup olmadığı
     */
    func isMicrophoneActive() -> Bool {
        return microphoneEnabled
    }
    
    /**
     * Oturumun aktif olup olmadığını döndürür
     * - Returns: Oturum aktif ise true, değilse false
     */
    func isSessionActive() -> Bool {
        return sessionActive
    }
    
    /**
     * Oturumdan ayrılır
     * - Parameter completion: Tamamlanma bloğu, işlem sonucunu döndürür
     */
    func leaveSession(completion: @escaping (Bool, Error?) -> Void) {
        log("Oturumdan ayrılınıyor")
        
        // Oturumdan ayrılma simulasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.disconnect()
            completion(true, nil)
        }
    }
    
    /**
     * Katılımcı listesini döndürür
     * - Returns: Katılımcı listesi (userId -> userName)
     */
    func getParticipants() -> [String: String] {
        return participants
    }
}
#else
// RELEASE modu için gerçek WebRTC implementasyonu
import Foundation
import AVFoundation
import UIKit
// Framework kütüphaneleri
import GoogleWebRTC
import Alamofire
import SocketIO
import KeychainAccess
import Toast_Swift

/// WebRTC servisi için özel hata türleri
enum WebRTCServiceError: Error {
    case connectionFailed
    case invalidConfiguration
    case sessionClosed
    case unauthorized
    case timeout
    
    var localizedDescription: String {
        switch self {
        case .connectionFailed:
            return "Bağlantı hatası oluştu"
        case .invalidConfiguration:
            return "Geçersiz konfigürasyon"
        case .sessionClosed:
            return "Oturum kapatıldı"
        case .unauthorized:
            return "Yetkisiz erişim"
        case .timeout:
            return "Bağlantı zaman aşımına uğradı"
        }
    }
}

/**
 * WebRTC servisi
 *
 * Bu servis, gerçek zamanlı sesli iletişim için WebRTC protokolünü kullanır.
 * SFU (Selective Forwarding Unit) mimarisi ile 100-300 kişilik gruplar için optimize edilmiştir.
 */
class WebRTCService: NSObject {
    /// Singleton örneği
    static let shared = WebRTCService()
    
    // MARK: - Properties
    
    /// Ses oturumu
    private var audioSession: AVAudioSession
    
    /// Oturumun aktif olup olmadığı
    private var sessionActive: Bool = false
    
    /// Mikrofonun etkin olup olmadığı
    private var microphoneEnabled: Bool = false
    
    /// WebSocket görevi
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// WebSocket oturumu
    private var webSocketSession: URLSession?
    
    /// Bağlantı URL'si
    private var serverUrl: String?
    
    // MARK: - WebRTC Properties
    
    /// Peer bağlantı fabrikası
    private var peerConnectionFactory: RTCPeerConnectionFactory?
    
    /// Peer bağlantısı
    private var peerConnection: RTCPeerConnection?
    
    /// Yerel ses izi
    private var localAudioTrack: RTCAudioTrack?
    
    /// Ses kaynağı
    private var audioSource: RTCAudioSource?
    
    /// WebRTC ses oturumu
    private var rtcAudioSession: RTCAudioSession?
    
    // MARK: - Session Properties
    
    /// Oturum ID'si
    private var sessionId: String?
    
    /// Kullanıcı ID'si
    private var userId: String?
    
    /// Grup ID'si
    private var groupId: String?
    
    /// Katılımcı listesi
    private(set) var participants: [String: [String: Any]] = [:]
    
    /// Transport ID'si
    private var transportId: String?
    
    /// Producer ID'si (mikrofon yayını için)
    private var producerId: String?
    
    // MARK: - Initialization
    
    /// Gizli başlatıcı
    override init() {
        self.audioSession = AVAudioSession.sharedInstance()
        super.init()
        
        setupAudio()
        setupWebRTC()
    }
    
    // MARK: - Setup Methods
    
    /// Ses ayarlarını yapılandırır
    private func setupAudio() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat)
            try audioSession.setActive(true)
        } catch {
            print("Ses oturumu ayarlanırken hata oluştu: \(error)")
        }
    }
    
    /// WebRTC ayarlarını yapılandırır
    private func setupWebRTC() {
        rtcAudioSession = RTCAudioSession.sharedInstance()
        rtcAudioSession?.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
        rtcAudioSession?.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        
        // RTCPeerConnectionFactory başlat
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
        
        // Ses kaynağı oluştur
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        audioSource = peerConnectionFactory?.audioSource(with: constraints)
        
        if let source = audioSource {
            localAudioTrack = peerConnectionFactory?.audioTrack(with: source, trackId: "audio0")
        }
    }
    
    // MARK: - Connection Methods
    
    /**
     * WebRTC sunucusuna bağlanır
     * - Parameters:
     *   - serverUrl: WebSocket sunucu URL'si
     *   - userId: Kullanıcı kimliği
     *   - groupId: Grup kimliği
     *   - completion: Tamamlanma bloğu, bağlantı sonucunu döndürür
     */
    func connect(serverUrl: String, userId: String, groupId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.userId = userId
        self.groupId = groupId
        self.serverUrl = serverUrl
        
        // WebSocket bağlantısı oluştur
        guard let url = URL(string: serverUrl) else {
            let error = WebRTCServiceError.invalidConfiguration
            completion(.failure(error))
            return
        }
        
        webSocketSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = webSocketSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // PeerConnection oluştur
        createPeerConnection { success in
            if success {
                self.sessionActive = true
                self.sendJoinRequest()
                completion(.success(()))
            } else {
                completion(.failure(WebRTCServiceError.connectionFailed))
            }
        }
    }
    
    /**
     * Bir sesli oturuma bağlanır (basitleştirilmiş)
     * - Parameters:
     *   - sessionId: Bağlanılacak oturum ID'si
     *   - completion: Tamamlanma bloğu, bağlantı sonucunu döndürür
     */
    func connect(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.sessionId = sessionId
        
        // Kullanıcı bilgilerini al
        let userDefaults = UserDefaults.standard
        let userId = userDefaults.string(forKey: "userId") ?? UUID().uuidString
        
        // Varsayılan sunucu URL'si
        let serverUrl = "wss://rtc.sesliiletisim.com/ws"
        
        // Tam bağlantı metodunu çağır
        connect(serverUrl: serverUrl, userId: userId, groupId: sessionId, completion: completion)
    }
    
    /**
     * WebRTC bağlantısını sonlandırır
     */
    func disconnect() {
        // Mikrofonu kapat
        setMicrophoneEnabled(false)
        
        // WebSocket bağlantısını sonlandır
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        webSocketSession = nil
        
        // PeerConnection temizle
        peerConnection?.close()
        peerConnection = nil
        
        // Oturumu temizle
        sessionActive = false
        sessionId = nil
        userId = nil
        groupId = nil
        transportId = nil
        producerId = nil
        participants.removeAll()
    }
    
    /**
     * Oturumun aktif olup olmadığını döndürür
     * - Returns: Oturum aktif ise true, değilse false
     */
    func isSessionActive() -> Bool {
        return sessionActive && peerConnection != nil
    }
    
    /**
     * Oturumdan ayrılır
     * - Parameter completion: Tamamlanma bloğu, işlem sonucunu döndürür
     */
    func leaveSession(completion: @escaping (Bool, Error?) -> Void) {
        // Ayrılma mesajını gönder
        let leaveMessage: [String: Any] = [
            "type": "leave",
            "sessionId": sessionId ?? "",
            "userId": userId ?? ""
        ]
        
        sendMessage(leaveMessage)
        
        // Bağlantıyı sonlandır
        disconnect()
        
        // Tamamlandı
        completion(true, nil)
    }
    
    // MARK: - WebRTC Setup
    
    /**
     * PeerConnection oluşturur
     * - Parameter completion: Tamamlanma bloğu, bağlantı başarılı ise true döndürür
     */
    private func createPeerConnection(completion: @escaping (Bool) -> Void) {
        // RTCConfiguration oluştur
        let config = RTCConfiguration()
        
        // STUN sunucularını ekle
        let defaultStunServers = ["stun:stun.l.google.com:19302", "stun:stun1.l.google.com:19302"]
        var iceServers = [RTCIceServer]()
        iceServers.append(RTCIceServer(urlStrings: defaultStunServers))
        
        // TURN sunucusu ekleyin (gerekirse)
        let turnServerUrl = "turn:turn.sesliiletisim.com:3478"
        let turnServerUsername = "sesliiletisim"
        let turnServerPassword = "turn_password"
        iceServers.append(RTCIceServer(
            urlStrings: [turnServerUrl],
            username: turnServerUsername,
            credential: turnServerPassword
        ))
        
        config.iceServers = iceServers
        
        // Bağlantı kısıtlamaları oluştur
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: ["OfferToReceiveAudio": "true"],
            optionalConstraints: nil
        )
        
        // PeerConnection oluştur
        peerConnection = peerConnectionFactory?.peerConnection(with: config, constraints: constraints, delegate: self)
        
        // Ses izini ekle
        if let audioTrack = localAudioTrack {
            peerConnection?.add(audioTrack, streamIds: ["stream-\(userId ?? "unknown")"])
            completion(true)
            } else {
            completion(false)
        }
    }
    
    // MARK: - Microphone Control
    
    /**
     * Mikrofon durumunu ayarlar
     * - Parameter enabled: Mikrofonun açık olup olmayacağı
     */
    func setMicrophoneEnabled(_ enabled: Bool) {
        microphoneEnabled = enabled
        localAudioTrack?.isEnabled = enabled
        
        // Sunucuya mikrofon durumunu bildir
        if sessionActive {
            let micStatusMessage: [String: Any] = [
                "type": "microphoneStatus",
                "enabled": enabled,
                "userId": userId ?? "",
                "sessionId": sessionId ?? ""
            ]
            
            sendMessage(micStatusMessage)
        }
    }
    
    /**
     * Mikrofonun etkin olup olmadığını döndürür
     * - Returns: Mikrofonun etkin olup olmadığı
     */
    func isMicrophoneActive() -> Bool {
        return microphoneEnabled && localAudioTrack?.isEnabled == true
    }
    
    // MARK: - WebSocket Methods
    
    /**
     * Katılma isteği gönderir
     */
    private func sendJoinRequest() {
        guard let userId = userId, let groupId = groupId else { return }
        
        let joinMessage: [String: Any] = [
            "type": "join",
            "userId": userId,
            "groupId": groupId
        ]
        
        sendMessage(joinMessage)
    }
    
    /**
     * WebSocket üzerinden mesaj gönderir
     * - Parameter message: Gönderilecek mesaj
     */
    private func sendMessage(_ message: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webSocketTask?.send(.string(jsonString)) { error in
                    if let error = error {
                        print("Mesaj gönderilirken hata oluştu: \(error)")
                    }
                }
            }
        } catch {
            print("JSON serileştirme hatası: \(error)")
        }
    }
    
    /**
     * Karşıdan gelen mesajları alır ve işler
     */
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Sürekli mesaj alımı için kendini çağır
                self.receiveMessages()
                
            case .failure(let error):
                print("WebSocket mesaj alımı hatası: \(error)")
                
                // Bağlantı koptu, tekrar bağlanmayı dene
                if self.sessionActive {
                    self.reconnect()
                }
            }
        }
    }
    
    /**
     * Tekrar bağlanmayı dener
     */
    private func reconnect() {
        guard let serverUrl = serverUrl, let userId = userId, let groupId = groupId else {
            return
        }
        
        // 3 saniye bekleyip tekrar bağlanmayı dene
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.connect(serverUrl: serverUrl, userId: userId, groupId: groupId) { _ in
                // Bağlantı yeniden kuruldu veya başarısız oldu
            }
        }
    }
    
    /**
     * Sunucudan gelen mesajları işler
     * - Parameter messageText: Mesaj metni
     */
    private func handleMessage(_ messageText: String) {
        guard let data = messageText.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = json["type"] as? String {
                
                switch type {
                case "welcome":
                    handleWelcomeMessage(json)
                case "participantJoined":
                    handleParticipantJoinedMessage(json)
                case "participantLeft":
                    handleParticipantLeftMessage(json)
                case "microphoneStatus":
                    handleMicrophoneStatusMessage(json)
                case "transportCreated":
                    handleTransportCreatedMessage(json)
                case "error":
                    handleErrorMessage(json)
                default:
                    print("Bilinmeyen mesaj türü: \(type)")
                }
            }
        } catch {
            print("JSON ayrıştırma hatası: \(error)")
        }
    }
    
    /**
     * Hoşgeldin mesajını işler
     * - Parameter message: Mesaj içeriği
     */
    private func handleWelcomeMessage(_ message: [String: Any]) {
        if let sessionId = message["sessionId"] as? String {
            self.sessionId = sessionId
            print("Oturuma katılındı: \(sessionId)")
        }
        
        if let participants = message["participants"] as? [[String: Any]] {
            for participant in participants {
                if let userId = participant["userId"] as? String {
                    self.participants[userId] = participant
                }
            }
            print("Katılımcı sayısı: \(participants.count)")
        }
    }
    
    /**
     * Katılımcı katılma mesajını işler
     * - Parameter message: Mesaj içeriği
     */
    private func handleParticipantJoinedMessage(_ message: [String: Any]) {
        if let userId = message["userId"] as? String {
            participants[userId] = message
            print("Katılımcı katıldı: \(userId)")
        }
    }
    
    /**
     * Katılımcı ayrılma mesajını işler
     * - Parameter message: Mesaj içeriği
     */
    private func handleParticipantLeftMessage(_ message: [String: Any]) {
        if let userId = message["userId"] as? String {
            participants.removeValue(forKey: userId)
            print("Katılımcı ayrıldı: \(userId)")
        }
    }
    
    /**
     * Mikrofon durumu mesajını işler
     * - Parameter message: Mesaj içeriği
     */
    private func handleMicrophoneStatusMessage(_ message: [String: Any]) {
        if let userId = message["userId"] as? String,
           let enabled = message["enabled"] as? Bool {
            print("Katılımcı mikrofon durumu değişti: \(userId), Etkin: \(enabled)")
            
            // Katılımcının mikrofon durumunu güncelle
            if var participant = participants[userId] {
                participant["microphoneEnabled"] = enabled
                participants[userId] = participant
            }
        }
    }
    
    /**
     * Transport oluşturma mesajını işler
     * - Parameter message: Mesaj içeriği
     */
    private func handleTransportCreatedMessage(_ message: [String: Any]) {
        if let transportId = message["transportId"] as? String {
            self.transportId = transportId
            print("Transport oluşturuldu: \(transportId)")
            
            // Ses yayınını başlat
            startAudioPublishing()
        }
    }
    
    /**
     * Hata mesajını işler
     * - Parameter message: Mesaj içeriği
     */
    private func handleErrorMessage(_ message: [String: Any]) {
        if let errorMessage = message["message"] as? String {
            print("Sunucu hatası: \(errorMessage)")
        }
    }
    
    /**
     * Ses yayınını başlatır
     */
    private func startAudioPublishing() {
        guard let transportId = transportId else { return }
        
        let publishMessage: [String: Any] = [
            "type": "publish",
            "transportId": transportId,
            "kind": "audio",
            "rtpParameters": [
                "codecs": [
                    [
                        "mimeType": "audio/opus",
                        "payloadType": 111,
                        "clockRate": 48000,
                        "channels": 2,
                        "parameters": [
                            "minptime": 10,
                            "useinbandfec": 1
                        ]
                    ]
                ]
            ]
        ]
        
        sendMessage(publishMessage)
    }
    
    /**
     * Katılımcı listesini döndürür
     * - Returns: Katılımcı listesi (userId -> userName)
     */
    func getParticipants() -> [String: String] {
        var result: [String: String] = [:]
        
        for (userId, participantInfo) in participants {
            if let userName = participantInfo["userName"] as? String {
                result[userId] = userName
            } else {
                result[userId] = "İsimsiz Katılımcı"
            }
        }
        
        return result
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebRTCService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket bağlantısı açıldı")
        
        // Mesaj alma işlemini başlat
        receiveMessages()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket bağlantısı kapandı, kod: \(closeCode)")
        
        if let reasonData = reason, let reasonString = String(data: reasonData, encoding: .utf8) {
            print("Kapatma nedeni: \(reasonString)")
        }
        
        sessionActive = false
    }
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCService: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Sinyal durumu değişti: \(stateChanged.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("Medya akışı eklendi")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("Medya akışı kaldırıldı")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Bağlantı yeniden müzakere edilmeli")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("ICE bağlantı durumu değişti: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ICE toplama durumu değişti: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("ICE adayı oluşturuldu: \(candidate.sdp)")
        
        // ICE adayını sunucuya gönder
        let iceCandidateMessage: [String: Any] = [
            "type": "iceCandidate",
            "candidate": [
                "sdp": candidate.sdp,
                "sdpMLineIndex": candidate.sdpMLineIndex,
                "sdpMid": candidate.sdpMid ?? ""
            ]
        ]
        
        sendMessage(iceCandidateMessage)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("ICE adayları kaldırıldı")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Veri kanalı açıldı: \(dataChannel.label)")
    }
}
#endif
