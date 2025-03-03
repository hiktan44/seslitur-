import Foundation

/**
 * Tour - Tur Modeli
 *
 * Rehber tarafından oluşturulan ve katılımcıların katılabildiği turları temsil eder.
 * Backend API ile senkronize edilir.
 */
public struct Tour: Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let startDate: String
    public let endDate: String?
    public let guideId: String
    public let code: String
    public let isActive: Bool
    public let participantCount: Int
    public let createdAt: String
    public let updatedAt: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case startDate = "start_date"
        case endDate = "end_date"
        case guideId = "guide_id"
        case code
        case isActive = "is_active"
        case participantCount = "participant_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(id: String, name: String, description: String?, startDate: String, endDate: String?, 
                guideId: String, code: String, isActive: Bool, participantCount: Int, 
                createdAt: String, updatedAt: String) {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.guideId = guideId
        self.code = code
        self.isActive = isActive
        self.participantCount = participantCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/**
 * API Yanıt Modelleri - Tour ile ilgili API yanıtları
 */
public struct ToursResponse: Codable {
    public let tours: [Tour]
    
    public init(tours: [Tour]) {
        self.tours = tours
    }
}

public struct TourResponse: Codable {
    public let tour: Tour
    
    public init(tour: Tour) {
        self.tour = tour
    }
}

public struct CreateTourRequest: Codable {
    public let name: String
    public let description: String?
    public let startDate: String
    public let endDate: String?
    
    public enum CodingKeys: String, CodingKey {
        case name
        case description
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
    public init(name: String, description: String?, startDate: String, endDate: String?) {
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
    }
}

/**
 * TourStatus - Tur durumunu belirten enum
 */
public enum TourStatus: String, Codable {
    case pending = "pending"   // Beklemede
    case active = "active"     // Aktif
    case completed = "completed" // Tamamlandı
    case cancelled = "cancelled" // İptal edildi
} 