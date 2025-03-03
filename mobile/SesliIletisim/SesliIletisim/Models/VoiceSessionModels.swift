/**
 * VoiceSessionModels - Sesli İletişim Modelleri
 * 
 * Sesli iletişim oturumları ile ilgili model yapılarını içerir.
 * Tüm sesli oturum API'leri ve WebRTC entegrasyonu için gerekli
 * veri tipleri burada tanımlanır.
 */

import Foundation

// MARK: - Sesli Oturum
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
}

// MARK: - Sesli Oturum Oluşturma İsteği
public struct CreateVoiceSession: Codable {
    public let title: String
    public let tourId: String
    public let maxParticipants: Int
    public let mode: SessionMode
    
    public init(title: String, tourId: String, maxParticipants: Int = 300, mode: SessionMode = .singleSpeaker) {
        self.title = title
        self.tourId = tourId
        self.maxParticipants = maxParticipants
        self.mode = mode
    }
}

// MARK: - Sesli Oturum Katılımcısı
public struct VoiceSessionParticipant: Codable {
    public let id: String
    public let userId: String
    public let userName: String
    public let sessionId: String
    public let status: ParticipantStatus
    public let joinTime: String
    public let isActive: Bool
}

// MARK: - Sesli Oturum Yapılandırması
public struct VoiceSessionConfig: Codable {
    public let maxParticipants: Int
    public let mode: SessionMode
    public let allowHandRaising: Bool
    public let enableRecording: Bool
    public let speakingTimeLimit: Int? // Saniye cinsinden, varsa
    
    public init(maxParticipants: Int = 300, 
              mode: SessionMode = .singleSpeaker,
              allowHandRaising: Bool = true,
              enableRecording: Bool = false,
              speakingTimeLimit: Int? = nil) {
        self.maxParticipants = maxParticipants
        self.mode = mode
        self.allowHandRaising = allowHandRaising
        self.enableRecording = enableRecording
        self.speakingTimeLimit = speakingTimeLimit
    }
}

// MARK: - Sesli Oturum Yanıtları
public struct SessionsResponse: Codable {
    public let sessions: [VoiceSession]
}

public struct SessionResponse: Codable {
    public let session: VoiceSession
}

public struct SessionParticipantsResponse: Codable {
    public let participants: [VoiceSessionParticipant]
} 