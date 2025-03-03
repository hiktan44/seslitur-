# TurSesli WebRTC API Dokümantasyonu

Bu dokümantasyon, TurSesli uygulamasının WebRTC ve Signaling API'lerini açıklar.

## Signaling Sunucusu API

Signaling sunucusu, WebRTC bağlantılarının kurulması için gerekli sinyal mesajlarının iletilmesini sağlar.

### Baz URL

```
https://api.tursesli.com
```

### Socket.IO Olayları

#### Sunucuya Gönderilen Olaylar

| Olay | Açıklama | Parametreler |
|------|----------|--------------|
| `join_room` | Bir odaya katılma isteği | `{ roomId, userId, userType, device }` |
| `leave_room` | Bir odadan ayrılma isteği | `{ roomId, userId }` |
| `signaling_message` | WebRTC sinyal mesajı | `{ type, sdp, roomId, userId }` veya `{ type, candidate, roomId, userId }` |
| `microphone_status` | Mikrofon durumu değişikliği | `{ roomId, userId, enabled }` |
| `audio_quality` | Ses kalitesi ayarı | `{ roomId, userId, bitrate }` |

#### Sunucudan Alınan Olaylar

| Olay | Açıklama | Parametreler |
|------|----------|--------------|
| `room_joined` | Odaya katılım başarılı | `{ roomInfo, participants }` |
| `new_participant` | Yeni katılımcı odaya katıldı | `{ userId, name, userType }` |
| `participant_left` | Katılımcı odadan ayrıldı | `{ userId }` |
| `signaling_message` | WebRTC sinyal mesajı | `{ type, sdp, userId }` veya `{ type, candidate, userId }` |
| `microphone_status_changed` | Bir katılımcının mikrofon durumu değişti | `{ userId, enabled }` |
| `audio_quality_changed` | Ses kalitesi değişti | `{ bitrate, quality }` |

### Örnek Kullanım

```swift
// Socket.IO bağlantısı kurma
let manager = SocketManager(socketURL: URL(string: "https://api.tursesli.com")!, config: [.log(true), .compress])
let socket = manager.defaultSocket

// Olayları dinleme
socket.on("room_joined") { data, ack in
    print("Odaya katılım başarılı")
}

// Odaya katılma isteği gönderme
let joinData: [String: Any] = [
    "roomId": "tour123",
    "userId": "user456",
    "userType": "guide",
    "device": [
        "platform": "iOS",
        "version": "15.0",
        "model": "iPhone 13"
    ]
]
socket.emit("join_room", joinData)
```

## WebRTC Yapılandırması

### ICE Sunucuları

```swift
let iceServers: [RTCIceServer] = [
    RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]),
    RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"]),
    RTCIceServer(
        urlStrings: ["turn:turn.tursesli.com:3478"],
        username: "tursesli",
        credential: "turnserver"
    )
]
```

### SDP Kısıtlamaları

```swift
// Offer oluşturma kısıtlamaları
let offerConstraints = RTCMediaConstraints(
    mandatoryConstraints: ["OfferToReceiveAudio": "true"],
    optionalConstraints: nil
)

// Peer bağlantısı kısıtlamaları
let peerConstraints = RTCMediaConstraints(
    mandatoryConstraints: nil,
    optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
)

// Ses kaynağı kısıtlamaları
let audioConstraints = RTCMediaConstraints(
    mandatoryConstraints: nil,
    optionalConstraints: ["echoCancellation": "true", "noiseSuppression": "true"]
)
```

### Ses Kalitesi Ayarları

| Kalite | Bit Hızı | Kullanım Senaryosu |
|--------|----------|-------------------|
| Düşük | 20 kbps | Düşük bant genişliği koşulları |
| Orta | 64 kbps | Normal kullanım |
| Yüksek | 128 kbps | Yüksek kalite gerektiren durumlar |

## WebRTCService API

`WebRTCService` sınıfı, WebRTC işlevselliğini kapsülleyen bir singleton servistir.

### Temel Metodlar

#### Oturum Yönetimi

```swift
// Bir sesli oturuma katılma
func joinSession(sessionId: String, userId: String, completion: @escaping (Bool, String?) -> Void)

// Mevcut oturumdan ayrılma
func leaveSession(completion: @escaping (Bool, String?) -> Void)

// Oturum durumunu kontrol etme
func isSessionActive() -> Bool
```

#### Ses Kontrolü

```swift
// Mikrofonu açma/kapatma
func enableMicrophone(_ enabled: Bool)

// Ses kalitesini ayarlama
func setAudioQuality(_ quality: AudioQuality)

// Bluetooth kulaklık desteğini açma/kapatma
func enableBluetoothSupport(_ enabled: Bool)
```

#### Katılımcı Bilgileri

```swift
// Mevcut oturumdaki katılımcıları alma
func getParticipants() -> [String: Any]

// Mevcut oturum bilgilerini alma
func getSessionInfo() -> [String: Any]?
```

### Örnek Kullanım

```swift
// Oturuma katılma
WebRTCService.shared.joinSession(sessionId: "tour123", userId: "user456") { success, errorMessage in
    if success {
        print("Oturuma başarıyla katıldı")
    } else {
        print("Oturuma katılırken hata: \(errorMessage ?? "Bilinmeyen hata")")
    }
}

// Mikrofonu açma
WebRTCService.shared.enableMicrophone(true)

// Ses kalitesini ayarlama
WebRTCService.shared.setAudioQuality(.medium)

// Oturumdan ayrılma
WebRTCService.shared.leaveSession { success, errorMessage in
    if success {
        print("Oturumdan başarıyla ayrıldı")
    } else {
        print("Oturumdan ayrılırken hata: \(errorMessage ?? "Bilinmeyen hata")")
    }
}
```

## Hata Kodları ve Çözümleri

| Hata Kodu | Açıklama | Çözüm |
|-----------|----------|-------|
| 1001 | Mikrofon erişimi reddedildi | Kullanıcıdan mikrofon izni isteyin |
| 1002 | Signaling sunucusuna bağlanılamadı | Ağ bağlantısını kontrol edin |
| 1003 | ICE bağlantısı kurulamadı | TURN sunucularını kontrol edin |
| 1004 | SDP oluşturulamadı | WebRTC yapılandırmasını kontrol edin |
| 1005 | Oturum bulunamadı | Geçerli bir oturum ID'si kullanın | 