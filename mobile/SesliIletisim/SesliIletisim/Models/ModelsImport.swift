/**
 * ModelsImport - Model tanımlarının merkezi import dosyası
 * 
 * Bu dosya, ortak model tanımlarını projenin her yerinde kolay bir şekilde kullanabilmek için
 * tek bir import noktası sağlar. Bu sayede model yapılarında değişiklik olduğunda
 * sadece ilgili model dosyasını güncellemek yeterli olacaktır.
 */

import Foundation

// Enum tanımları
@_exported import enum UserMode // Models.swift içinden export edilen UserMode

// Struct tanımları 
@_exported import struct User // Models.swift içinden export edilen User
@_exported import struct Tour // Models.swift içinden export edilen Tour
@_exported import struct VoiceSession // Models.swift içinden export edilen VoiceSession
@_exported import struct AuthResponse // Models.swift içinden export edilen AuthResponse

// Protocol tanımları
// @_exported import protocol SomeProtocol

// Enum tanımlarını direkt olarak burada yapalım (hızlı çözüm için)
public enum UserMode {
    case guide       // Rehber modu
    case participant // Katılımcı modu
}

// Sesli oturum katılımcı durumu
public enum ParticipantStatus: String, Codable {
    case connected = "connected"      // Bağlı
    case disconnected = "disconnected" // Bağlantı kesildi
    case speaking = "speaking"        // Konuşuyor
    case muted = "muted"              // Sessize alındı
    case handRaised = "hand_raised"   // El kaldırdı (soru soracak)
}

// Sesli oturum modu
public enum SessionMode: String, Codable {
    case singleSpeaker = "single"     // Sadece rehber konuşabilir
    case moderated = "moderated"      // Rehber izin verdiğinde konuşulabilir
    case freeConversation = "free"    // Herkes konuşabilir
} 