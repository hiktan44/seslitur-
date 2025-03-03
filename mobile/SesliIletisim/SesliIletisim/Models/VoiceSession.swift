import Foundation

/**
 * VoiceSession - Sesli Oturum Modeli
 *
 * Bir tur kapsamında oluşturulan sesli iletişim oturumunu temsil eder.
 * Backend API ile senkronize edilir ve WebRTC bağlantıları için temel oluşturur.
 */
public struct VoiceSession: Codable {
    public let id: String
    public let title: String
    public let tourId: String
    public let creatorId: String
    public let isActive: Bool
    public let startTime: String
    public let endTime: String?
    public let participantCount: Int
    public let createdAt: String
    public let updatedAt: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case tourId = "tour_id"
        case creatorId = "creator_id"
        case isActive = "is_active" 
        case startTime = "start_time"
        case endTime = "end_time"
        case participantCount = "participant_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(id: String, title: String, tourId: String, creatorId: String, 
                isActive: Bool, startTime: String, endTime: String?, 
                participantCount: Int, createdAt: String, updatedAt: String) {
        self.id = id
        self.title = title
        self.tourId = tourId
        self.creatorId = creatorId
        self.isActive = isActive
        self.startTime = startTime
        self.endTime = endTime
        self.participantCount = participantCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/**
 * API Yanıt Modelleri - VoiceSession ile ilgili API yanıtları
 */
public struct SessionsResponse: Codable {
    public let sessions: [VoiceSession]
    
    public init(sessions: [VoiceSession]) {
        self.sessions = sessions
    }
}

public struct SessionResponse: Codable {
    public let session: VoiceSession
    
    public init(session: VoiceSession) {
        self.session = session
    }
}

public struct CreateVoiceSession: Codable {
    public let title: String
    public let tourId: String
    public let maxParticipants: Int
    
    public enum CodingKeys: String, CodingKey {
        case title
        case tourId = "tour_id"
        case maxParticipants = "max_participants"
    }
    
    public init(title: String, tourId: String, maxParticipants: Int = 300) {
        self.title = title
        self.tourId = tourId
        self.maxParticipants = maxParticipants
    }
}

/**
 * SessionStatus - Oturum durumunu belirten enum
 */
public enum SessionStatus: String, Codable {
    case pending = "pending"     // Beklemede
    case active = "active"       // Aktif
    case completed = "completed" // Tamamlandı
    case cancelled = "cancelled" // İptal edildi
}

/**
 * SessionConfig - Oturum yapılandırması
 */
public struct SessionConfig: Codable {
    public let audioQuality: AudioQuality
    public let moderationMode: ModerationMode
    public let allowQuestions: Bool
    public let handRaisingEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case audioQuality = "audio_quality"
        case moderationMode = "moderation_mode"
        case allowQuestions = "allow_questions"
        case handRaisingEnabled = "hand_raising_enabled"
    }
}

/**
 * AudioQuality - Ses kalitesi seviyesini belirten enum
 */
public enum AudioQuality: String, Codable {
    case low = "low"       // Düşük (20-40 kbps)
    case medium = "medium" // Orta (40-80 kbps)
    case high = "high"     // Yüksek (80-128 kbps)
}

/**
 * ModerationMode - Moderasyon modunu belirten enum
 */
public enum ModerationMode: String, Codable {
    case guideOnly = "guide_only"           // Sadece rehber konuşabilir
    case moderated = "moderated"            // Rehber izin verdiğinde konuşulabilir
    case freeConversation = "free"          // Herkes konuşabilir
} 