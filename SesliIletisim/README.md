# Sesli İletişim iOS Uygulaması

Bu proje, 100-300 kişilik gruplar için internet üzerinden gerçek zamanlı sesli iletişim sağlayan bir iOS uygulamasıdır.

## Özellikler

- Kullanıcı kaydı ve girişi
- Admin paneli
- Kullanıcı, grup ve oturum yönetimi
- WebRTC ve mediasoup SFU entegrasyonu
- Grup oluşturma ve katılma
- Gerçek zamanlı sesli iletişim
- Bluetooth kulaklık desteği
- Ses kalitesi optimizasyonu

## Teknik Özellikler

- iOS 14+ desteği
- Swift 5.0+
- WebRTC teknolojisi
- mediasoup SFU mimarisi
- Opus kodek (20-128 kbps arası uyarlanabilir bit hızı)
- TLS 1.3+ ve DTLS-SRTP ile güvenli iletişim
- End-to-end şifreleme

## Gereksinimler

- Xcode 12.0 veya üstü
- iOS 14.0 veya üstü
- Swift 5.0 veya üstü

## Kurulum

1. Proje reposunu klonlayın:
```
git clone https://github.com/ornek/SesliIletisim.git
```

2. Proje dizinine gidin:
```
cd SesliIletisim
```

3. Xcode ile proje dosyasını açın:
```
open SesliIletisim.xcodeproj
```

4. Uygulamayı bir simülatörde veya gerçek bir cihazda çalıştırın.

## Kullanım

### Normal Kullanıcı Girişi
- Uygulamayı açın ve "Giriş Yap" butonuna tıklayın
- E-posta ve şifrenizi girin
- "Giriş Yap" butonuna basın

### Admin Girişi
- Uygulamayı açın ve "Giriş Yap" butonuna tıklayın
- E-posta olarak "admin@example.com" ve şifre olarak "12345" girin
- "Admin olarak giriş yap" seçeneğini aktif edin
- "Giriş Yap" butonuna basın

## Geliştirme

### Proje Yapısı

- **Controllers/** - Uygulama kontrolleri
  - MainViewController.swift - Ana sayfa
  - LoginViewController.swift - Giriş ekranı
  - RegisterViewController.swift - Kayıt ekranı
  - DashboardViewController.swift - Kullanıcı paneli
  - AdminDashboardViewController.swift - Admin paneli
  - ForgotPasswordViewController.swift - Şifre sıfırlama

- **Services/** - Servis sınıfları
  - WebRTCService.swift - WebRTC ve mediasoup entegrasyonu

## Katkıda Bulunma

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasını inceleyebilirsiniz.

## İletişim

Hikmet Tanriverdi - [info@example.com](mailto:info@example.com) 