# WebRTCService Dokümantasyonu

## Genel Bakış

`WebRTCService` sınıfı, SesliIletisim uygulamasında gerçek zamanlı sesli iletişim için WebRTC protokolünü kullanır. Bu servis, SFU (Selective Forwarding Unit) mimarisi ile 100-300 kişilik gruplar için optimize edilmiştir.

## Özellikler

- Gerçek zamanlı sesli iletişim
- Düşük gecikme süresi (150ms'den az)
- Düşük bant genişliği kullanımı (20-128 kbps)
- Grup yönetimi ve katılımcı izleme
- Mikrofon kontrolü
- Oturum yönetimi
- Güvenli iletişim (DTLS-SRTP)

## Kullanım

### Servis Başlatma

```swift
// Singleton örneğini al
let webRTCService = WebRTCService.shared

// Kullanıcı kimliğini ayarla
webRTCService.setUserId("user123")
```

### Oturuma Bağlanma

```swift
// Bir oturuma bağlan
webRTCService.connect(sessionId: "session123") { result in
    switch result {
    case .success:
        print("Oturuma başarıyla bağlanıldı")
    case .failure(let error):
        print("Bağlantı hatası: \(error.localizedDescription)")
    }
}
```

### Mikrofon Kontrolü

```swift
// Mikrofonu aç
webRTCService.setMicrophoneEnabled(true)

// Mikrofon durumunu kontrol et
let isMicrophoneEnabled = webRTCService.isMicrophoneEnabled()
```

### Katılımcıları Listeleme

```swift
// Oturumdaki katılımcıları al
let participants = webRTCService.getParticipants()

// Katılımcıları işle
for (userId, userName) in participants {
    print("Katılımcı: \(userName) (ID: \(userId))")
}
```

### Oturumu Sonlandırma

```swift
// Oturumdan ayrıl
webRTCService.disconnect()
```

## Sınıf Referansı

### Özellikler

| Özellik | Tür | Açıklama |
|---------|-----|----------|
| `shared` | `WebRTCService` | Singleton örneği |
| `participants` | `[String: String]` | Katılımcı listesi (userId: userName) |
| `sessionActive` | `Bool` | Oturumun aktif olup olmadığı |
| `currentSessionId` | `String?` | Şu anki oturum ID'si |
| `userId` | `String?` | Kullanıcı kimliği |

### Metodlar

#### `connect(sessionId:completion:)`

Bir sesli oturuma bağlanır.

**Parametreler:**
- `sessionId`: Bağlanılacak oturum ID'si
- `completion`: Tamamlanma bloğu, bağlantı sonucunu döndürür

**Örnek:**
```swift
webRTCService.connect(sessionId: "session123") { result in
    // İşlem sonucunu işle
}
```

#### `disconnect()`

WebRTC bağlantısını sonlandırır.

**Örnek:**
```swift
webRTCService.disconnect()
```

#### `setMicrophoneEnabled(_:)`

Mikrofon durumunu ayarlar.

**Parametreler:**
- `enabled`: Mikrofonun açık olup olmayacağı

**Örnek:**
```swift
webRTCService.setMicrophoneEnabled(true)
```

#### `isMicrophoneEnabled()`

Mikrofonun etkin olup olmadığını döndürür.

**Dönüş Değeri:**
- Mikrofonun etkin olup olmadığı

**Örnek:**
```swift
let isMicrophoneEnabled = webRTCService.isMicrophoneEnabled()
```

#### `setUserId(_:)`

Kullanıcı kimliğini ayarlar.

**Parametreler:**
- `userId`: Kullanıcı kimliği

**Örnek:**
```swift
webRTCService.setUserId("user123")
```

#### `getParticipants()`

Oturumdaki katılımcıları döndürür.

**Dönüş Değeri:**
- Katılımcı listesi (userId: userName)

**Örnek:**
```swift
let participants = webRTCService.getParticipants()
```

## Hata İşleme

`WebRTCServiceError` enum'u, WebRTC servisi ile ilgili hataları tanımlar:

```swift
enum WebRTCServiceError: Error {
    case connectionFailed
    case invalidConfiguration
    case sessionClosed
    case unauthorized
    case timeout
}
```

## Notlar

- WebRTC servisi, AVAudioSession'ı `.playAndRecord` kategorisi ve `.voiceChat` modu ile yapılandırır.
- Düşük bant genişliği koşullarına adaptif olarak çalışır (20-128 kbps).
- Tüm iletişim DTLS-SRTP ile şifrelenir.
- DEBUG modunda gerçek WebRTC bağlantısı yerine bir simülasyon kullanılır. 