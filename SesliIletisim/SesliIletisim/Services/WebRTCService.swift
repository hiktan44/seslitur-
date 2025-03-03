import Foundation
import AVFoundation

#if DEBUG
// Debug modu için basit bir WebRTC implementasyonu
class WebRTCService {
    // Singleton
    static let shared = WebRTCService()
    
    // Durumları takip etmek için değişkenler
    private var isConnected = false
    private var isMicrophoneEnabled = false
    private var sessionId: String?
    private var userId: String?
    
    // Simüle edilmiş katılımcı listesi
    private var participants: [String: [String: Any]] = [:]
    
    private init() {
        print("[DEBUG] WebRTCService oluşturuldu")
    }
    
    // MARK: - Public Methods
    func connect(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.sessionId = sessionId
        self.userId = UserDefaults.standard.string(forKey: "userId")
        self.isConnected = true
        
        print("[DEBUG] WebRTC bağlantısı simülasyonu: \(sessionId) oturumuna bağlanıldı")
        
        // Simüle edilmiş katılımcılar
        let simulatedUser1 = ["id": "sim_user_1", "name": "Test User 1", "isSpeaking": false]
        let simulatedUser2 = ["id": "sim_user_2", "name": "Test User 2", "isSpeaking": true]
        self.participants["sim_user_1"] = simulatedUser1 as [String : Any]
        self.participants["sim_user_2"] = simulatedUser2 as [String : Any]
        
        // Başarılı sonuç dön
        completion(.success(()))
    }
    
    func disconnect() {
        guard isConnected else { return }
        
        print("[DEBUG] WebRTC bağlantısı sonlandırıldı (simülasyon)")
        isConnected = false
        sessionId = nil
        userId = nil
        participants.removeAll()
    }
    
    func isMicrophoneActive() -> Bool {
        return isMicrophoneEnabled
    }
    
    func setMicrophoneEnabled(_ isEnabled: Bool) {
        print("[DEBUG] Mikrofon durumu değiştirildi: \(isEnabled)")
        isMicrophoneEnabled = isEnabled
    }
    
    func isSessionActive() -> Bool {
        return isConnected && sessionId != nil
    }
    
    func getParticipants() -> [String: Any] {
        return participants
    }
    
    func leaveSession(completion: @escaping (Bool, Error?) -> Void) {
        print("[DEBUG] Oturumdan ayrılma simüle ediliyor")
        self.disconnect()
        completion(true, nil)
    }
    
    // MARK: - Ek metodlar
    func joinSession(sessionId: String, userId: String, completion: @escaping (Bool, String?) -> Void) {
        // Debug modunda basit bir bağlantı simülasyonu
        self.sessionId = sessionId
        self.userId = userId
        self.isConnected = true
        self.isMicrophoneEnabled = true
        
        print("[DEBUG] Oturum katılımı simüle ediliyor: \(sessionId)")
        
        // Örnek katılımcılar
        let simulatedUser1 = ["name": "Ali Yılmaz", "isSpeaking": true]
        let simulatedUser2 = ["name": "Ayşe Kaya", "isSpeaking": false]
        let simulatedUser3 = ["name": "Mehmet Demir", "isSpeaking": false]
        
        self.participants["user1"] = simulatedUser1 as [String : Any]
        self.participants["user2"] = simulatedUser2 as [String : Any]
        self.participants["user3"] = simulatedUser3 as [String : Any]
        
        completion(true, nil)
    }
    
    func getSessionInfo() -> [String: Any]? {
        guard isConnected else { return nil }
        
        return [
            "name": "Haftalık Toplantı",
            "host": "Ali Yılmaz",
            "participants": 3,
            "maxParticipants": 100
        ]
    }
    
    func enableMicrophone(_ enabled: Bool) {
        isMicrophoneEnabled = enabled
        print("[DEBUG] Mikrofon \(enabled ? "etkinleştirildi" : "devre dışı bırakıldı")")
    }
    
    func setAudioQuality(_ quality: AudioQuality) {
        print("[DEBUG] Ses kalitesi ayarlandı: \(quality.rawValue)")
    }
    
    func enableBluetoothSupport(_ enabled: Bool) {
        print("[DEBUG] Bluetooth desteği \(enabled ? "etkinleştirildi" : "devre dışı bırakıldı")")
    }
    
    enum AudioQuality: String {
        case low = "Düşük Kalite (20 kbps)"
        case medium = "Orta Kalite (64 kbps)"
        case high = "Yüksek Kalite (128 kbps)"
    }
}

#else
import WebRTC

/**
 * WebRTCService - Sesli İletişim uygulaması için WebRTC ve mediasoup entegrasyonu
 *
 * Bu servis, gerçek zamanlı sesli iletişim için WebRTC teknolojisini kullanarak
 * mediasoup SFU sunucusuna bağlanmayı ve ses akışı iletimini sağlar.
 *
 * - WebRTC bağlantı yönetimi
 * - MediaSoup entegrasyonu
 * - Ses ayarları ve kalite optimizasyonu
 * - Signaling protokolü
 */
class WebRTCService: NSObject, URLSessionWebSocketDelegate, RTCPeerConnectionDelegate {
    
    // MARK: - Singleton
    static let shared = WebRTCService()
    
    // MARK: - Properties
    private var audioSession: AVAudioSession
    private var isConnected: Bool = false
    private var isMicrophoneEnabled: Bool = false
    private var webSocketTask: URLSessionWebSocketTask?
    private var webSocketSession: URLSession?
    
    // MARK: - WebRTC Properties
    private var peerConnectionFactory: RTCPeerConnectionFactory?
    private var peerConnection: RTCPeerConnection?
    private var localAudioTrack: RTCAudioTrack?
    private var audioSource: RTCAudioSource?
    
    // MARK: - Session Properties
    private var sessionId: String?
    private var userId: String?
    private var tourId: String?
    private var participants: [String: Any] = [:]
    private var roomInfo: [String: Any] = [:]
    
    // MARK: - WebRTC Properties
    private var transportId: String?
    private var producerId: String?
    private var consumers: [String: Any] = [:]
    
    // MARK: - Audio Settings
    private var rtcAudioSession: RTCAudioSession?
    
    // MARK: - Initializers
    private override init() {
        audioSession = AVAudioSession.sharedInstance()
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    
    /**
     * WebRTC bağlantısını başlatır
     * @param sessionId Bağlanılacak oturum ID'si
     * @param completion Bağlantı sonucu
     */
    func connect(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isConnected else {
            completion(.success(()))
            return
        }
        
        self.sessionId = sessionId
        self.userId = UserDefaults.standard.string(forKey: "userId")
        
        // WebSocket bağlantısını başlat
        setupWebSocket()
        
        // Tamamlandı bildirimi
        completion(.success(()))
    }
    
    /**
     * WebRTC bağlantısını sonlandırır
     */
    func disconnect() {
        guard isConnected else { return }
        
        // WebSocket bağlantısını kapat
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        
        // Peer bağlantısını temizle
        closePeerConnection()
        
        // Durum değişkenlerini sıfırla
        isConnected = false
        sessionId = nil
        userId = nil
        participants.removeAll()
    }
    
    /**
     * Mikrofonun aktif olup olmadığını kontrol eder
     * @return Mikrofonun durumu
     */
    func isMicrophoneActive() -> Bool {
        return isMicrophoneEnabled
    }
    
    /**
     * Mikrofonu açar veya kapatır
     * @param isEnabled Mikrofonun aktif olup olmayacağı
     */
    func setMicrophoneEnabled(_ isEnabled: Bool) {
        isMicrophoneEnabled = isEnabled
        localAudioTrack?.isEnabled = isEnabled
    }
    
    /**
     * Oturumun aktif olup olmadığını kontrol eder
     * @return Oturumun durumu
     */
    func isSessionActive() -> Bool {
        return isConnected && sessionId != nil
    }
    
    /**
     * Oturumdaki katılımcıları getirir
     * @return Katılımcı listesi
     */
    func getParticipants() -> [String: Any] {
        return participants
    }
    
    /**
     * Oturumdan ayrılma isteği gönderir
     * @param completion Ayrılma sonucu
     */
    func leaveSession(completion: @escaping (Bool, Error?) -> Void) {
        guard let sessionId = sessionId else {
            completion(false, NSError(domain: "WebRTCService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Aktif oturum bulunamadı"]))
            return
        }
        
        let message = [
            "type": "leave",
            "sessionId": sessionId,
            "userId": userId ?? ""
        ] as [String : Any]
        
        sendSignalingMessage(message) { success in
            if success {
                self.disconnect()
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "WebRTCService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ayrılma isteği gönderilemedi"]))
            }
        }
    }
    
    /**
     * Bir sesli oturuma katılmak için kullanılır
     * @param sessionId Katılmak istenen oturumun benzersiz tanımlayıcısı
     * @param userId Kullanıcının benzersiz tanımlayıcısı
     * @param completion İşlem tamamlandığında çağrılacak closure
     */
    func joinSession(sessionId: String, userId: String, completion: @escaping (Bool, String?) -> Void) {
        // Mikrofon izni kontrolü
        checkMicrophonePermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.connect(sessionId: sessionId) { result in
                    switch result {
                    case .success:
                        completion(true, nil)
                    case .failure(let error):
                        completion(false, error.localizedDescription)
                    }
                }
            } else {
                completion(false, "Mikrofon erişimi reddedildi. Sesli iletişim için mikrofon iznine ihtiyaç duyulur.")
            }
        }
    }
    
    // MARK: - WebSocket Delegate Methods
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        print("WebSocket bağlantısı açıldı")
        
        // Oturuma katılma mesajı gönder
        let joinMessage = [
            "type": "join",
            "sessionId": sessionId ?? "",
            "userId": userId ?? ""
        ] as [String : Any]
        
        sendSignalingMessage(joinMessage) { success in
            if success {
                self.setupPeerConnection()
                self.listenForWebSocketMessages()
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        
        var reasonStr = "Bilinmeyen sebep"
        if let reasonData = reason, let str = String(data: reasonData, encoding: .utf8) {
            reasonStr = str
        }
        
        print("WebSocket bağlantısı kapandı: \(closeCode), sebep: \(reasonStr)")
    }
    
    // MARK: - RTCPeerConnectionDelegate Implementation
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Signaling durumu değişti: \(stateChanged.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("Stream eklendi")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("Stream kaldırıldı")
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
        
        let message = [
            "type": "candidate",
            "sessionId": sessionId ?? "",
            "userId": userId ?? "",
            "candidate": [
                "sdpMid": candidate.sdpMid ?? "",
                "sdpMLineIndex": candidate.sdpMLineIndex,
                "candidate": candidate.sdp
            ]
        ] as [String : Any]
        
        sendSignalingMessage(message) { _ in }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("ICE adayları kaldırıldı")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Veri kanalı açıldı: \(dataChannel.label)")
    }
    
    // MARK: - Private Methods
    
    private func setupWebSocket() {
        // WebSocket URL oluştur
        var urlComponents = URLComponents()
        
        // Üretim ortamında güvenli wss protokolü
        urlComponents.scheme = "wss"
        urlComponents.host = "api.sesliletisim.com"
        
        urlComponents.path = "/ws"
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: UserDefaults.standard.string(forKey: "authToken")),
            URLQueryItem(name: "sessionId", value: sessionId)
        ]
        
        guard let url = urlComponents.url else {
            print("WebSocket URL oluşturulamadı")
            print("Şema: \(urlComponents.scheme ?? "Şema yok"), Host: \(urlComponents.host ?? "Host yok"), Path: \(urlComponents.path)")
            return
        }
        
        print("WebSocket URL: \(url)")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        webSocketSession = session
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // İlk mesajları dinlemeye başla
        listenForWebSocketMessages()
    }
    
    private func listenForWebSocketMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.handleWebSocketMessage(data)
                case .string(let string):
                    if let data = string.data(using: .utf8) {
                        self.handleWebSocketMessage(data)
                    }
                @unknown default:
                    print("Bilinmeyen WebSocket mesaj tipi")
                }
                
                // Sürekli mesaj dinleme
                self.listenForWebSocketMessages()
                
            case .failure(let error):
                print("WebSocket mesaj alma hatası: \(error.localizedDescription)")
                
                // Bağlantıyı yeniden kurma denemesi
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if self.isConnected {
                        self.listenForWebSocketMessages()
                    } else {
                        self.setupWebSocket()
                    }
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let type = json["type"] as? String else {
                print("Geçersiz JSON formatı")
                return
            }
            
            print("WebSocket mesajı alındı: \(type)")
            
            switch type {
            case "welcome":
                // Sunucudan karşılama mesajı
                if let roomInfo = json["roomInfo"] as? [String: Any] {
                    self.roomInfo = roomInfo
                }
                
            case "participant-joined":
                // Yeni katılımcı bilgisi
                if let userId = json["userId"] as? String,
                   let participant = json["participant"] as? [String: Any] {
                    participants[userId] = participant
                }
                
            case "participant-left":
                // Ayrılan katılımcı bilgisi
                if let userId = json["userId"] as? String {
                    participants.removeValue(forKey: userId)
                }
                
            case "error":
                // Hata mesajı
                if let error = json["error"] as? String {
                    print("Sunucu hatası: \(error)")
                }
                
            case "offer":
                // SDP teklifi
                if let sdp = json["sdp"] as? [String: Any],
                   let sdpString = sdp["sdp"] as? String {
                    handleRemoteOffer(sdpString)
                }
                
            case "answer":
                // SDP yanıtı
                if let sdp = json["sdp"] as? [String: Any],
                   let sdpString = sdp["sdp"] as? String {
                    handleRemoteAnswer(sdpString)
                }
                
            case "candidate":
                // ICE adayı
                if let candidateObj = json["candidate"] as? [String: Any],
                   let sdpMid = candidateObj["sdpMid"] as? String,
                   let sdpMLineIndex = candidateObj["sdpMLineIndex"] as? Int32,
                   let candidate = candidateObj["candidate"] as? String {
                    
                    let iceCandidate = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                    handleRemoteCandidate(iceCandidate)
                }
                
            default:
                print("Bilinmeyen mesaj tipi: \(type)")
            }
            
        } catch {
            print("WebSocket mesajı ayrıştırılamadı: \(error.localizedDescription)")
        }
    }
    
    private func sendSignalingMessage(_ message: [String: Any], completion: @escaping (Bool) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message)
            
            webSocketTask?.send(.data(jsonData)) { error in
                if let error = error {
                    print("WebSocket mesajı gönderme hatası: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } catch {
            print("JSON verisi oluşturulamadı: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // Ses oturumu ayarları
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Ses oturumu ayarlanamadı: \(error.localizedDescription)")
        }
    }
    
    // Peer bağlantısını kapatır ve temizler
    private func closePeerConnection() {
        peerConnection?.close()
        peerConnection = nil
        localAudioTrack = nil
        audioSource = nil
        peerConnectionFactory = nil
    }
    
    // WebRTC Peer bağlantısını kurar ve ses kaynağını yapılandırır
    private func setupPeerConnection() {
        // RTCPeerConnectionFactory oluştur
        peerConnectionFactory = RTCPeerConnectionFactory()
        
        // ICE sunucularını yapılandır
        let configuration = RTCConfiguration()
        configuration.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]),
            RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"])
        ]
        
        // TURN sunucusu (üretim ortamında kullanılmalı)
        let turnServer = RTCIceServer(
            urlStrings: ["turn:turn.sesliletisim.com:3478"],
            username: "sesliletisim",
            credential: "turnSifre123")
        configuration.iceServers.append(turnServer)
        
        // Medya kısıtlamaları
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
        
        // Peer bağlantısını oluştur
        peerConnection = peerConnectionFactory?.peerConnection(
            with: configuration, constraints: constraints, delegate: self)
        
        // Ses kaynağını ekle
        setupAudioSource()
    }
    
    // Ses kaynağını oluşturur ve bağlantıya ekler
    private func setupAudioSource() {
        // Ses kaynağı oluştur
        let audioConstrains = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil)
        
        audioSource = peerConnectionFactory?.audioSource(with: audioConstrains)
        localAudioTrack = peerConnectionFactory?.audioTrack(with: audioSource!, trackId: "ARDAudioOnly")
        
        // Ses izini bağlantıya ekle
        peerConnection?.add(localAudioTrack!, streamIds: ["ARDAudioOnlyStream"])
        
        // Mikrofon durumunu ayarla
        localAudioTrack?.isEnabled = isMicrophoneEnabled
    }
    
    // Uzak taraftan gelen SDP teklifini işler
    private func handleRemoteOffer(_ sdpString: String) {
        let sessionDescription = RTCSessionDescription(type: .offer, sdp: sdpString)
        peerConnection?.setRemoteDescription(sessionDescription) { error in
            if let error = error {
                print("Uzak teklif ayarlanamadı: \(error.localizedDescription)")
                return
            }
            
            // Yanıt oluştur
            self.createAnswer()
        }
    }
    
    // Yanıt oluşturur ve gönderir
    private func createAnswer() {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true"
            ],
            optionalConstraints: nil)
        
        peerConnection?.answer(for: constraints) { [weak self] sdp, error in
            guard let self = self, let sdp = sdp else {
                print("Yanıt oluşturulamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp) { error in
                if let error = error {
                    print("Yerel açıklama ayarlanamadı: \(error.localizedDescription)")
                    return
                }
                
                // Yanıtı gönder
                let message = [
                    "type": "answer",
                    "sessionId": self.sessionId ?? "",
                    "userId": self.userId ?? "",
                    "sdp": [
                        "type": "answer",
                        "sdp": sdp.sdp
                    ]
                ] as [String : Any]
                
                self.sendSignalingMessage(message) { _ in }
            }
        }
    }
    
    // Uzak taraftan gelen SDP yanıtını işler
    private func handleRemoteAnswer(_ sdpString: String) {
        let sessionDescription = RTCSessionDescription(type: .answer, sdp: sdpString)
        peerConnection?.setRemoteDescription(sessionDescription) { error in
            if let error = error {
                print("Uzak yanıt ayarlanamadı: \(error.localizedDescription)")
            }
        }
    }
    
    // Uzak taraftan gelen ICE adayını işler
    private func handleRemoteCandidate(_ candidate: RTCIceCandidate) {
        if let peerConnection = peerConnection {
            peerConnection.add(candidate)
        } else {
            print("ICE adayı eklenemedi: peerConnection nil")
        }
    }
    
    // MARK: - Ek yardımcı metodlar
    
    /**
     * Mevcut oturumun bilgilerini almak için kullanılır
     */
    func getSessionInfo() -> [String: Any]? {
        guard isConnected else { return nil }
        return roomInfo
    }
    
    /**
     * Mikrofonu açıp kapatmak için kullanılır
     * @param enabled Mikrofonun etkin olup olmayacağını belirtir
     */
    func enableMicrophone(_ enabled: Bool) {
        self.setMicrophoneEnabled(enabled)
    }
    
    // Ses kalitesini ayarlamak için kullanılır
    func setAudioQuality(_ quality: AudioQuality) {
        // WebRTC kodek parametrelerini ayarla
        print("Ses kalitesi ayarlandı: \(quality.rawValue)")
    }
    
    // Bluetooth kulaklık desteğini açıp kapatmak için kullanılır
    func enableBluetoothSupport(_ enabled: Bool) {
        do {
            if enabled {
                try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            } else {
                try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.mixWithOthers])
            }
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Bluetooth ayarları değiştirilirken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    // Mikrofon izin kontrolü
    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
}

// MARK: - Enums
extension WebRTCService {
    enum AudioQuality: String {
        case low = "Düşük Kalite (20 kbps)"
        case medium = "Orta Kalite (64 kbps)"
        case high = "Yüksek Kalite (128 kbps)"
    }
}
#endif 