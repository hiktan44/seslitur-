import Foundation

/**
 * Ortak Enum ve Model tanımlamaları
 * Birden fazla yerde kullanılan sabit değerler ve yardımcı tipler
 */

// MARK: - Tur Durumu (Status)
public enum TourStatus: String, Codable {
    case pending = "pending"          // Tur henüz başlamadı
    case active = "active"            // Tur aktif ve katılıma açık
    case completed = "completed"      // Tur tamamlandı
    case cancelled = "cancelled"      // Tur iptal edildi
}

// MARK: - Sesli Oturum Durumu
public enum SessionStatus: String, Codable {
    case pending = "pending"          // Oturum henüz başlamadı
    case active = "active"            // Oturum aktif
    case completed = "completed"      // Oturum tamamlandı
    case cancelled = "cancelled"      // Oturum iptal edildi
}

// MARK: - Sesli Oturum Katılımcı Durumu
public enum ParticipantStatus: String, Codable {
    case connected = "connected"      // Bağlı
    case disconnected = "disconnected" // Bağlantı kesildi
    case speaking = "speaking"        // Konuşuyor
    case muted = "muted"              // Sessize alındı
    case handRaised = "hand_raised"   // El kaldırdı (soru soracak)
}

// MARK: - Sesli Oturum Modu
public enum SessionMode: String, Codable {
    case singleSpeaker = "single"     // Sadece rehber konuşabilir
    case moderated = "moderated"      // Rehber izin verdiğinde konuşulabilir
    case freeConversation = "free"    // Herkes konuşabilir
}

// MARK: - Kullanıcı Modu
public enum UserMode {
    case guide                        // Rehber modu
    case participant                  // Katılımcı modu
}

// MARK: - Sesli Oturum Yapılandırması
public struct SessionConfig: Codable {
    public let mode: SessionMode
    public let allowQuestions: Bool
    public let allowRecording: Bool
    public let qualityProfile: String
    
    public enum CodingKeys: String, CodingKey {
        case mode
        case allowQuestions = "allow_questions"
        case allowRecording = "allow_recording"
        case qualityProfile = "quality_profile"
    }
    
    public init(mode: SessionMode = .moderated, 
                allowQuestions: Bool = true,
                allowRecording: Bool = false,
                qualityProfile: String = "balanced") {
        self.mode = mode
        self.allowQuestions = allowQuestions
        self.allowRecording = allowRecording
        self.qualityProfile = qualityProfile
    }
}

// MARK: - API Hata Yanıtı
public struct APIError: Codable {
    public let error: String
    public let message: String
    public let statusCode: Int
    
    public enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status_code"
    }
}

// MARK: - Boş API Yanıtı
public struct EmptyResponse: Codable {
    public let success: Bool
    public let message: String?
} 