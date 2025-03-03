import Foundation

/**
 * User - Kullanıcı Modeli
 *
 * Sisteme kayıtlı bir kullanıcıyı temsil eder.
 * Backend API ile senkronize edilir.
 */
public struct User: Codable {
    public let id: String
    public let name: String
    public let email: String
    public let role: String
    public let createdAt: String
    public let updatedAt: String
    public let profileImageUrl: String?
    public let phoneNumber: String?
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case role
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profileImageUrl = "profile_image_url"
        case phoneNumber = "phone_number"
    }
    
    public init(id: String, name: String, email: String, role: String,
                createdAt: String, updatedAt: String,
                profileImageUrl: String? = nil, phoneNumber: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
    }
}

// Kullanıcı rolü kontrolleri için extension
public extension User {
    var isGuide: Bool {
        return role == "guide"
    }
    
    var isParticipant: Bool {
        return role == "participant"
    }
}

/**
 * API Yanıt Modelleri - User ile ilgili API yanıtları
 */
public struct UserResponse: Codable {
    public let user: User
    public let token: String
    
    public init(user: User, token: String) {
        self.user = user
        self.token = token
    }
}

public struct LoginRequest: Codable {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct RegisterRequest: Codable {
    public let name: String
    public let email: String
    public let password: String
    public let role: String
    
    public init(name: String, email: String, password: String, role: String) {
        self.name = name
        self.email = email
        self.password = password
        self.role = role
    }
} 