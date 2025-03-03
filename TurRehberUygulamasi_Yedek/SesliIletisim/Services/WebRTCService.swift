import Foundation
import AVFoundation

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
class WebRTCService {
    
    // MARK: - Singleton
    static let shared = WebRTCService()
    
    // MARK: - Properties
    private var audioSession: AVAudioSession
    private var isConnected: Bool = false
    private var isMicrophoneEnabled: Bool = false
    
    // MARK: - Mock Session Properties
    // Not: Gerçek WebRTC uygulamasında bu kısımlar mediasoup ve WebRTC API'leri ile değiştirilecek
    private var currentSessionId: String?
    private var participants: [String: Any] = [:]
    private var roomInfo: [String: Any] = [:]
    
    // MARK: - Initialization
    private init() {
        audioSession = AVAudioSession.sharedInstance()
        setupAudioSession()
    }
    
    // MARK: - Setup Methods
    private func setupAudioSession() {
        do {
            // Ses kategorisi ve modunu ayarla
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Audio session ayarlanırken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    
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
                // Gerçek uygulamada burada WebRTC ve mediasoup bağlantıları kurulacak
                // Örnek uygulama için mock bir implementasyon:
                
                self.currentSessionId = sessionId
                self.isConnected = true
                self.enableMicrophone(true)
                
                // Örnek katılımcılar ve oda bilgisi
                self.participants = [
                    "user1": ["name": "Ali Yılmaz", "isSpeaking": true],
                    "user2": ["name": "Ayşe Kaya", "isSpeaking": false],
                    "user3": ["name": "Mehmet Demir", "isSpeaking": false]
                ]
                
                self.roomInfo = [
                    "name": "Haftalık Toplantı",
                    "host": "Ali Yılmaz",
                    "participants": 3,
                    "maxParticipants": 100
                ]
                
                completion(true, nil)
            } else {
                completion(false, "Mikrofon erişimi reddedildi. Sesli iletişim için mikrofon iznine ihtiyaç duyulur.")
            }
        }
    }
    
    /**
     * Mevcut oturumdan ayrılmak için kullanılır
     */
    func leaveSession(completion: @escaping (Bool, String?) -> Void) {
        if isConnected {
            // Gerçek uygulamada burada WebRTC bağlantı kesme işlemleri yapılacak
            
            enableMicrophone(false)
            isConnected = false
            currentSessionId = nil
            participants = [:]
            roomInfo = [:]
            
            completion(true, nil)
        } else {
            completion(false, "Aktif bir oturum bulunamadı")
        }
    }
    
    /**
     * Mikrofonu açıp kapatmak için kullanılır
     * @param enabled Mikrofonun etkin olup olmayacağını belirtir
     */
    func enableMicrophone(_ enabled: Bool) {
        isMicrophoneEnabled = enabled
        
        // Gerçek uygulamada burada WebRTC yerel audio track'i etkinleştirilecek/devre dışı bırakılacak
        print("Mikrofon \(enabled ? "etkinleştirildi" : "devre dışı bırakıldı")")
    }
    
    /**
     * Mevcut oturumdaki katılımcıların listesini almak için kullanılır
     */
    func getParticipants() -> [String: Any] {
        return participants
    }
    
    /**
     * Mevcut oturumun bilgilerini almak için kullanılır
     */
    func getSessionInfo() -> [String: Any]? {
        guard isConnected else { return nil }
        return roomInfo
    }
    
    /**
     * Bağlantı durumunu almak için kullanılır
     */
    func isSessionActive() -> Bool {
        return isConnected
    }
    
    // MARK: - Private Helper Methods
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

// MARK: - Helper Extensions
extension WebRTCService {
    
    /**
     * Ses kalitesini ayarlamak için kullanılır
     * @param quality Ses kalitesi seviyesi (low, medium, high)
     */
    func setAudioQuality(_ quality: AudioQuality) {
        // Gerçek uygulamada burada WebRTC kodek ve ses parametreleri ayarlanacak
        
        print("Ses kalitesi ayarlandı: \(quality.rawValue)")
    }
    
    /**
     * Bluetooth kulaklık desteğini açıp kapatmak için kullanılır
     * @param enabled Bluetooth kulaklık desteğinin etkin olup olmayacağını belirtir
     */
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
}

// MARK: - Enums
extension WebRTCService {
    enum AudioQuality: String {
        case low = "Düşük Kalite (20 kbps)"
        case medium = "Orta Kalite (64 kbps)"
        case high = "Yüksek Kalite (128 kbps)"
    }
} 