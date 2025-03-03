import Foundation
import Alamofire

/**
 * API Servisi
 * Backend API ile iletişim kurmak için kullanılır
 */
public class APIService {
    
    // MARK: - Singleton
    
    public static let shared = APIService()
    
    private init() {
        // Development veya Production URL'ini ayarla
        #if DEBUG
        baseURL = "http://localhost:5000/api"
        #else
        baseURL = "https://api.sesliiletisim.com/api"
        #endif
    }
    
    // MARK: - Properties
    
    /// API sunucusunun temel URL'i
    public let baseURL: String
    
    /// Kimlik doğrulama tokeni
    public var authToken: String? {
        // Keychain'den tokeni al
        // İlerleyen aşamada KeychainAccess gibi bir kütüphane kullanılabilir
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    /// Mevcut kullanıcı
    public var currentUser: User? {
        get {
            // Kayıtlı kullanıcı bilgilerini UserDefaults'dan al
            if let userData = UserDefaults.standard.data(forKey: "currentUser"),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                return user
            }
            return nil
        }
        set {
            // Kullanıcı bilgilerini UserDefaults'a kaydet
            if let user = newValue,
               let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUser")
            }
        }
    }
    
    // MARK: - Authentication
    
    /**
     * Kullanıcı girişi yapar
     * @param email Kullanıcı email adresi
     * @param password Kullanıcı şifresi
     * @param completion Giriş işlemi sonucu
     */
    public func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(baseURL)/auth/login"
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: AuthResponse.self) { response in
                switch response.result {
                case .success(let authResponse):
                    // Token'ı kaydet
                    UserDefaults.standard.set(authResponse.token, forKey: "authToken")
                    self.currentUser = authResponse.user
                    completion(.success(authResponse.user))
                    
                case .failure(let error):
                    print("Login error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Kullanıcı kaydı yapar
     * @param name Kullanıcı adı
     * @param email Kullanıcı email adresi
     * @param password Kullanıcı şifresi
     * @param role Kullanıcı rolü (guide veya participant)
     * @param completion Kayıt işlemi sonucu
     */
    public func register(name: String, email: String, password: String, role: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(baseURL)/auth/register"
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "role": role
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: AuthResponse.self) { response in
                switch response.result {
                case .success(let authResponse):
                    // Token'ı kaydet
                    UserDefaults.standard.set(authResponse.token, forKey: "authToken")
                    self.currentUser = authResponse.user
                    completion(.success(authResponse.user))
                    
                case .failure(let error):
                    print("Register error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Kullanıcı çıkışı yapar
     */
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "currentTourId")
        UserDefaults.standard.removeObject(forKey: "currentTourName")
        self.currentUser = nil
    }
    
    // MARK: - Tours
    
    /**
     * Rehberin turlarını getirir
     * @param completion Turları getirme sonucu
     */
    public func getTours(completion: @escaping (Result<[Tour], Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let url = "\(baseURL)/tours/guide"
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: ToursResponse.self) { response in
                switch response.result {
                case .success(let toursResponse):
                    completion(.success(toursResponse.tours))
                    
                case .failure(let error):
                    print("Get tours error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Yeni tur oluşturur
     * @param name Tur adı
     * @param description Tur açıklaması
     * @param startDate Başlangıç tarihi
     * @param completion Tur oluşturma sonucu
     */
    public func createTour(name: String, description: String, startDate: Date, completion: @escaping (Result<Tour, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let parameters: [String: Any] = [
            "name": name,
            "description": description,
            "start_date": dateFormatter.string(from: startDate)
        ]
        
        let url = "\(baseURL)/tours"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: TourResponse.self) { response in
                switch response.result {
                case .success(let tourResponse):
                    completion(.success(tourResponse.tour))
                    
                case .failure(let error):
                    print("Create tour error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Tur kodunu kullanarak tura katılır
     * @param tourCode Tur kodu
     * @param completion Tura katılma sonucu
     */
    public func joinTourWithCode(tourCode: String, completion: @escaping (Result<Tour, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "code": tourCode
        ]
        
        let url = "\(baseURL)/tours/join"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: TourResponse.self) { response in
                switch response.result {
                case .success(let tourResponse):
                    completion(.success(tourResponse.tour))
                    
                case .failure(let error):
                    print("Join tour error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Voice Sessions
    
    /**
     * Sesli oturum oluşturur
     * @param tourId Tur ID
     * @param name Oturum adı
     * @param startTime Başlangıç zamanı
     * @param maxParticipants Maksimum katılımcı sayısı
     * @param completion Oturum oluşturma sonucu
     */
    public func createVoiceSession(tourId: String, name: String, startTime: Date, maxParticipants: Int = 300, completion: @escaping (Result<VoiceSession, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let parameters: [String: Any] = [
            "tour_id": tourId,
            "name": name,
            "start_time": dateFormatter.string(from: startTime),
            "max_participants": maxParticipants
        ]
        
        let url = "\(baseURL)/voice-sessions"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: SessionResponse.self) { response in
                switch response.result {
                case .success(let sessionResponse):
                    completion(.success(sessionResponse.session))
                    
                case .failure(let error):
                    print("Create session error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Tura ait sesli oturumları getirir
     * @param tourId Tur ID
     * @param completion Oturum listesi sonucu
     */
    public func getVoiceSessions(forTourId tourId: String, completion: @escaping (Result<[VoiceSession], Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let url = "\(baseURL)/voice-sessions/tour/\(tourId)"
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: SessionsResponse.self) { response in
                switch response.result {
                case .success(let sessionsResponse):
                    completion(.success(sessionsResponse.sessions))
                    
                case .failure(let error):
                    print("Get sessions error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Aktif sesli oturumları getirir
     * @param completion Aktif oturum listesi sonucu
     */
    public func getActiveVoiceSessions(completion: @escaping (Result<[VoiceSession], Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let url = "\(baseURL)/voice-sessions/active"
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: SessionsResponse.self) { response in
                switch response.result {
                case .success(let sessionsResponse):
                    completion(.success(sessionsResponse.sessions))
                    
                case .failure(let error):
                    print("Get active sessions error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Sesli oturumu sonlandırır
     * @param sessionId Oturum ID
     * @param completion Sonlandırma işlemi sonucu
     */
    public func endVoiceSession(sessionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let url = "\(baseURL)/voice-sessions/\(sessionId)/end"
        
        AF.request(url, method: .put, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success(_):
                    completion(.success(()))
                    
                case .failure(let error):
                    print("End session error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    /**
     * Sesli oturum oluştur (alternatif)
     * @param session Oturum bilgileri
     * @param completion Oturum oluşturma sonucu
     */
    public func createVoiceSession(session: CreateVoiceSession, completion: @escaping (Result<VoiceSession, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(APIError.unauthorized))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        // Request parametreleri
        let parameters: [String: Any] = [
            "tour_id": session.tourId,
            "title": session.title,
            "max_participants": session.maxParticipants
        ]
        
        let url = "\(baseURL)/voice-sessions"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: SessionResponse.self) { response in
                switch response.result {
                case .success(let sessionResponse):
                    completion(.success(sessionResponse.session))
                    
                case .failure(let error):
                    print("Create voice session error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Helper Methods
    
    /**
     * API istekleri için HTTP başlıkları oluşturur
     * @return HTTP başlıkları
     */
    public func authHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        if let token = authToken {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        return headers
    }
}

// MARK: - Response Models

public struct AuthResponse: Decodable {
    public let token: String
    public let user: User
}

public struct ToursResponse: Decodable {
    public let tours: [Tour]
}

public struct TourResponse: Decodable {
    public let tour: Tour
}

public struct SessionResponse: Decodable {
    public let session: VoiceSession
}

public struct SessionsResponse: Decodable {
    public let sessions: [VoiceSession]
}

// CreateVoiceSession modeli
public struct CreateVoiceSession {
    public let title: String
    public let tourId: String
    public let maxParticipants: Int
    
    public init(title: String, tourId: String, maxParticipants: Int = 300) {
        self.title = title
        self.tourId = tourId
        self.maxParticipants = maxParticipants
    }
}

// MARK: - API Errors

public enum APIError: Error {
    case unauthorized
    case badRequest
    case notFound
    case serverError
    case decodingError
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .unauthorized:
            return "Yetkisiz erişim. Lütfen tekrar giriş yapın."
        case .badRequest:
            return "Geçersiz istek. Lütfen girdilerinizi kontrol edin."
        case .notFound:
            return "İstenen kaynak bulunamadı."
        case .serverError:
            return "Sunucu hatası. Lütfen daha sonra tekrar deneyin."
        case .decodingError:
            return "Veri çözümleme hatası. Uygulamayı güncelleyin."
        case .unknown:
            return "Bilinmeyen bir hata oluştu."
        }
    }
}

// MARK: - Model Definitions

struct User: Codable {
    let id: String
    let email: String
    let name: String
    let role: String
    let createdAt: String
}

struct Tour: Codable {
    let id: String
    let name: String
    let description: String?
    let startDate: String
    let endDate: String?
    let guideId: String
    let code: String
    let createdAt: String
}

struct VoiceSession: Codable {
    let id: String
    let title: String
    let tourId: String
    let creatorId: String
    let isActive: Bool
    let startTime: String
    let endTime: String?
    let participantCount: Int
    let createdAt: String
} 