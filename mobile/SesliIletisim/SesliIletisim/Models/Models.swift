import Foundation

/**
 * UserMode - Kullanıcı modu
 * 
 * Kullanıcının rehber veya katılımcı olarak uygulamayı kullanmasını belirler
 */
public enum UserMode {
    case guide      // Rehber modu
    case participant // Katılımcı modu
}

/**
 * User - Kullanıcı modeli
 * 
 * Kullanıcı bilgilerini içerir
 */
public struct User: Codable {
    public let id: String
    public let email: String
    public let name: String
    public let role: String
    public let profileImage: String?
    public let createdAt: String
    public let updatedAt: String
}

/**
 * AuthResponse - Kimlik doğrulama yanıtı
 * 
 * Giriş ve kayıt işlemlerinden dönen yanıt
 */
public struct AuthResponse: Codable {
    public let user: User
    public let token: String
}

/**
 * RegisterUser - Kullanıcı kaydı
 * 
 * Yeni kullanıcı kaydı için gerekli bilgiler
 */
public struct RegisterUser: Encodable {
    public let name: String
    public let email: String
    public let password: String
    public let role: String
}

/**
 * Tour - Tur modeli
 * 
 * Tur bilgilerini içerir
 */
public struct Tour: Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let startDate: String
    public let endDate: String
    public let guideId: String
    public let code: String
    public let isActive: Bool
    public let participantCount: Int
    public let createdAt: String
    public let updatedAt: String
}

/**
 * VoiceSession - Sesli oturum modeli
 * 
 * Sesli iletişim oturumu bilgilerini içerir
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
}

/**
 * CreateVoiceSession - Sesli oturum oluşturma
 * 
 * Yeni sesli oturum oluşturmak için gerekli bilgiler
 */
public struct CreateVoiceSession: Encodable {
    public let title: String
    public let tourId: String
}

/**
 * APIError - API hata modeli
 * 
 * API'den dönen hataları temsil eder
 */
public struct APIError: Error, Codable {
    public let statusCode: Int
    public let message: String
    public let error: String
}

/**
 * JoinTourRequest - Tura katılma isteği
 * 
 * Tura katılmak için gerekli bilgiler
 */
public struct JoinTourRequest: Encodable {
    public let code: String
}

/**
 * Participant - Katılımcı modeli
 * 
 * Sesli oturumdaki katılımcı bilgilerini içerir
 */
public struct Participant: Codable {
    public let id: String
    public let userId: String
    public let sessionId: String
    public let name: String
    public let joinTime: String
    public let isActive: Bool
    public let isMuted: Bool
}

// MARK: - WebRTC Models

/**
 * WebRTC sinyal mesajı modeli
 */
struct SignalingMessage: Codable {
    var type: String
    var participantId: String?
    var displayName: String?
    var transportId: String?
    var iceParameters: [String: Any]?
    var iceCandidates: [[String: Any]]?
    var dtlsParameters: [String: Any]?
    var producerId: String?
    var consumerId: String?
    var rtpParameters: [String: Any]?
    
    // CodingKeys enumeration
    private enum CodingKeys: String, CodingKey {
        case type, participantId, displayName, transportId
        case iceParameters, iceCandidates, dtlsParameters
        case producerId, consumerId, rtpParameters
    }
    
    // Custom encoder to handle dictionary values
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(participantId, forKey: .participantId)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(transportId, forKey: .transportId)
        try container.encodeIfPresent(producerId, forKey: .producerId)
        try container.encodeIfPresent(consumerId, forKey: .consumerId)
        
        // Encode dictionary values using JSONSerialization
        if let iceParams = iceParameters {
            let data = try JSONSerialization.data(withJSONObject: iceParams)
            let json = try JSONSerialization.jsonObject(with: data)
            try container.encode(json, forKey: .iceParameters)
        }
        
        if let iceCands = iceCandidates {
            let data = try JSONSerialization.data(withJSONObject: iceCands)
            let json = try JSONSerialization.jsonObject(with: data)
            try container.encode(json, forKey: .iceCandidates)
        }
        
        if let dtlsParams = dtlsParameters {
            let data = try JSONSerialization.data(withJSONObject: dtlsParams)
            let json = try JSONSerialization.jsonObject(with: data)
            try container.encode(json, forKey: .dtlsParameters)
        }
        
        if let rtpParams = rtpParameters {
            let data = try JSONSerialization.data(withJSONObject: rtpParams)
            let json = try JSONSerialization.jsonObject(with: data)
            try container.encode(json, forKey: .rtpParameters)
        }
    }
    
    // Custom decoder to handle dictionary values
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        participantId = try container.decodeIfPresent(String.self, forKey: .participantId)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        transportId = try container.decodeIfPresent(String.self, forKey: .transportId)
        producerId = try container.decodeIfPresent(String.self, forKey: .producerId)
        consumerId = try container.decodeIfPresent(String.self, forKey: .consumerId)
        
        // Decode dictionary values using JSONSerialization
        if let iceParamsData = try? container.decodeIfPresent(Data.self, forKey: .iceParameters) {
            iceParameters = try JSONSerialization.jsonObject(with: iceParamsData) as? [String: Any]
        }
        
        if let iceCandidatesData = try? container.decodeIfPresent(Data.self, forKey: .iceCandidates) {
            iceCandidates = try JSONSerialization.jsonObject(with: iceCandidatesData) as? [[String: Any]]
        }
        
        if let dtlsParamsData = try? container.decodeIfPresent(Data.self, forKey: .dtlsParameters) {
            dtlsParameters = try JSONSerialization.jsonObject(with: dtlsParamsData) as? [String: Any]
        }
        
        if let rtpParamsData = try? container.decodeIfPresent(Data.self, forKey: .rtpParameters) {
            rtpParameters = try JSONSerialization.jsonObject(with: rtpParamsData) as? [String: Any]
        }
    }
} 