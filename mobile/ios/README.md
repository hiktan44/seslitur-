# Sesli İletişim Mobil Uygulaması

## Proje Hakkında

Bu uygulama, 100-300 kişilik gruplar için gerçek zamanlı sesli iletişim sağlayan bir sistemin mobil istemcisidir. WebRTC teknolojisini kullanarak düşük gecikme süresi ve yüksek ses kalitesi sunmayı amaçlar. Hem iOS hem de Android platformlarında çalışır.

## Özellikler

- Gerçek zamanlı sesli iletişim (150ms'den az gecikme)
- 300 kişiye kadar grup desteği
- Şifre korumalı odalar
- Moderatör kontrolü ve konuşma izinleri
- Bluetooth kulaklık desteği
- Arka planda çalışma
- End-to-end şifreleme

## Teknik Özellikler

- WebRTC ile sesli iletişim
- mediasoup SFU (Selective Forwarding Unit) mimarisi
- Opus ses kodeği için optimizasyonlar
- STUN/TURN sunucu desteği
- Düşük bant genişliği koşullarına adaptasyon (20-128 kbps)
- TLS 1.3+ ile şifrelenmiş iletişim

## iOS Uygulaması

### Kurulum Gereksinimleri

- Xcode 13.0+
- iOS 14.0+
- Swift 5.0+
- CocoaPods veya Swift Package Manager

### Bağımlılıklar

- WebRTC.framework
- mediasoup-client-ios
- Starscream (WebSocket bağlantıları için)
- KeychainAccess (güvenli kimlik bilgileri depolama)

### Kurulum

1. Depoyu klonlayın:
```
git clone https://github.com/username/voice-communication-app.git
cd voice-communication-app/mobile/ios
```

2. Bağımlılıkları yükleyin:
```
pod install
```

3. VoiceCommunication.xcworkspace dosyasını Xcode ile açın.

4. Geliştirici sertifikanızı ve uygulama kimliğinizi ayarlayın.

5. Uygulamayı derleyin ve çalıştırın.

### Proje Yapısı

- `AppDelegate.swift` - Uygulama yaşam döngüsü yönetimi
- `SceneDelegate.swift` - Sahne yaşam döngüsü yönetimi
- `VoiceCommunicationApp.swift` - Ana uygulama dosyası
- `Info.plist` - Uygulama yapılandırma dosyası
- `Controllers/` - Görünüm kontrolcüleri
  - `MainViewController.swift` - Ana ekran
  - `LoginViewController.swift` - Giriş ekranı
  - `RegisterViewController.swift` - Kayıt ekranı
  - `ForgotPasswordViewController.swift` - Şifremi unuttum ekranı
  - `DashboardViewController.swift` - Dashboard ekranı
  - `AdminDashboardViewController.swift` - Admin paneli
- `Services/` - Uygulama servisleri
  - `WebRTCService.swift` - WebRTC entegrasyonu
  - `SignalingClient.swift` - Sinyal protokolü istemcisi
- `Models/` - Veri modelleri
- `Utils/` - Yardımcı fonksiyonlar

## Android Uygulaması

### Kurulum Gereksinimleri

- Android Studio 4.0+
- Android SDK 21+ (Android 5.0 Lollipop ve üzeri)
- Kotlin 1.5+
- Gradle 7.0+

### Bağımlılıklar

- WebRTC için libwebrtc
- mediasoup-client-android
- OkHttp (WebSocket bağlantıları için)
- Jetpack komponenetleri (ViewModel, LiveData, Room)
- Coroutines (Asenkron işlemler için)

### Kurulum

1. Depoyu klonlayın:
```
git clone https://github.com/username/voice-communication-app.git
cd voice-communication-app/mobile/android
```

2. Android Studio ile projeyi açın.

3. Gradle sync işlemini çalıştırın.

4. Uygulamayı derleyin ve çalıştırın.

### Proje Yapısı

- `MainActivity.kt` - Ana aktivite, giriş ve kayıt sayfalarına yönlendirme
- `LoginActivity.kt` - Kullanıcı girişi aktivitesi
- `RegisterActivity.kt` - Kullanıcı kaydı aktivitesi
- `DashboardActivity.kt` - Ana dashboard aktivitesi
- `AdminDashboardActivity.kt` - Admin paneli aktivitesi
- `services/` - Uygulama servisleri
  - `WebRTCService.kt` - WebRTC entegrasyonu
  - `SignalingService.kt` - Sinyal protokolü servisi
- `models/` - Veri modelleri
- `utils/` - Yardımcı fonksiyonlar
- `repository/` - Veri erişim katmanı

## WebRTC Entegrasyonu

WebRTC entegrasyonu, her platformda aşağıdaki görevleri yerine getirir:

- Audio oturumunu yapılandırma
- mediasoup SFU ile iletişim
- Transport ve Producer/Consumer yönetimi
- Sinyal protokolü entegrasyonu

## Performans Optimizasyonları

- Ses kalitesi ve gecikme süresini optimize etmek için Opus kodek parametreleri özelleştirilmiştir
- Ağ koşullarına göre adaptif bit hızı ayarlaması
- Batarya kullanımını minimize etmek için arka plan servisleri optimizasyonu
- Bluetooth kulaklık bağlantıları için özel optimizasyonlar

## Güvenlik Özellikleri

- TLS 1.3+ ile uçtan uca şifreleme
- DTLS-SRTP ile medya şifreleme
- Güvenli kimlik doğrulama ve oturum yönetimi
- Hassas kullanıcı verilerinin güvenli depolanması

## Backend Entegrasyonu

Mobil uygulamalar, NestJS ile geliştirilmiş bir backend ile entegre çalışır. Backend, şu servisleri sağlar:

- Kullanıcı yönetimi ve kimlik doğrulama
- Grup ve oturum yönetimi
- Signaling servisi
- mediasoup SFU sunucusu

## Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## Lisans

Bu proje [LICENSE] lisansı altında lisanslanmıştır.

## İletişim

Sorularınız için: iletisim@example.com 