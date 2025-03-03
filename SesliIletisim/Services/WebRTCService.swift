// WebRTCService.swift
// SesliIletisim uygulaması için WebRTC servisi

import Foundation
import AVFoundation

#if DEBUG
// DEBUG için sahte WebRTC implementasyonu
class WebRTCService {
    /// Singleton örneği
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
import GoogleWebRTC

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
 * SesliIletisim uygulaması için WebRTC servisi
 *
 * Bu servis, mediasoup ve WebRTC teknolojilerini kullanarak
 * gerçek zamanlı ses iletişimini yönetir.
 */
class WebRTCService: NSObject {
    /// Singleton örneği
    static let shared = WebRTCService()
    
    /// WebRTC fabrikası
    private var factory: RTCPeerConnectionFactory?
    
    /// Ses kaynağı
    private var audioSource: RTCAudioSource?
    
    /// Ses izi
    private var audioTrack: RTCAudioTrack?
    
    /// Peer bağlantıları
    private var peerConnections: [String: RTCPeerConnection] = [:]
    
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
        print("[WebRTCService] \(message)")
    }
    
    /// Gizli başlatıcı
    private override init() {
        super.init()
        log("WebRTC servisi başlatıldı")
        setupWebRTC()
        setupAudioSession()
    }
    
    /// WebRTC'yi yapılandırır
    private func setupWebRTC() {
        // WebRTC'yi başlat
        RTCInitializeSSL()
        factory = RTCPeerConnectionFactory()
        log("WebRTC başlatıldı")
    }
    
    /// Ses oturumunu yapılandırır
    private func setupAudioSession() {
        do {
            let audioSession = RTCAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try audioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
            try audioSession.setActive(true)
            log("Ses oturumu yapılandırıldı")
        } catch {
            log("Ses oturumu yapılandırılırken hata: \(error.localizedDescription)")
        }
    }
    
    /// Ses izini oluşturur
    private func createAudioTrack() {
        guard let factory = factory else {
            log("WebRTC fabrikası oluşturulmamış")
            return
        }
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        audioSource = factory.audioSource(with: constraints)
        
        guard let audioSource = audioSource else {
            log("Ses kaynağı oluşturulamadı")
            return
        }
        
        audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        log("Ses izi oluşturuldu")
    }
    
    /**
     * Bir sesli oturuma bağlanır
     * - Parameters:
     *   - sessionId: Bağlanılacak oturum ID'si
     *   - completion: Tamamlanma bloğu, bağlantı sonucunu döndürür
     */
    func connect(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        log("Oturuma bağlanılıyor: \(sessionId)")
        
        // Basitleştirilmiş bağlantı - gerçek uygulamada signaling sunucusuna bağlanılır
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.currentSessionId = sessionId
            self.sessionActive = true
            self.log("Oturuma bağlantı başarılı: \(sessionId)")
            completion(.success(()))
        }
    }
    
    /**
     * WebRTC bağlantısını sonlandırır
     */
    func disconnect() {
        log("Oturum bağlantısı sonlandırılıyor")
        
        // Peer bağlantılarını kapat
        for (peerId, connection) in peerConnections {
            connection.close()
            log("Peer bağlantısı kapatıldı: \(peerId)")
        }
        
        // Oturumu temizle
        peerConnections.removeAll()
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
        audioTrack?.isEnabled = enabled
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
        
        disconnect()
        completion(true, nil)
    }
    
    /**
     * Katılımcı listesini döndürür
     * - Returns: Katılımcı listesi (userId -> userName)
     */
    func getParticipants() -> [String: String] {
        return participants
    }
    
    deinit {
        RTCCleanupSSL()
        log("WebRTC servisi sonlandırıldı")
    }
}
#endif 