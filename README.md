# TurSesli - Gerçek Zamanlı Sesli İletişim Sistemi

TurSesli, 100-300 kişilik gruplar için internet üzerinden gerçek zamanlı sesli iletişim sağlayan bir sistemdir. WebRTC teknolojisini kullanarak düşük gecikme süreli ve yüksek kaliteli ses iletişimi sunar.

## Proje Teknolojileri

### Backend
- **Ana Framework**: NestJS (TypeScript tabanlı)
- **WebRTC Media Server**: MediaSoup
- **Veritabanı**: PostgreSQL (Supabase üzerinde)
- **API**: RESTful ve WebSocket
- **Kimlik Doğrulama**: JWT

### Frontend
- **Mobil Uygulamalar**: iOS (Swift) ve Android (Kotlin)
- **Web Arayüzü**: React (isteğe bağlı)

## Kurulum ve Çalıştırma

### Gereksinimler
- Node.js (v16+)
- npm veya yarn
- PostgreSQL
- Supabase CLI

### Kurulum Adımları

1. Depoyu klonlayın:
```bash
git clone https://github.com/hiktan44/seslitur-.git
cd seslitur-
```

2. Bağımlılıkları yükleyin:
```bash
npm install
```

3. `.env` dosyasını oluşturun:
```bash
cp .env.example .env
```

4. `.env` dosyasını kendi yapılandırmanıza göre düzenleyin.

5. Supabase Edge Functions gereksinimlerini yükleyin:
```bash
supabase start
```

### Uygulamayı Çalıştırma

Geliştirme modunda çalıştırma:
```bash
npm run start:dev
```

Üretim modunda çalıştırma:
```bash
npm run build
npm run start:prod
```

API Dokümantasyonu:
```
http://localhost:3000/api-docs
```

## Sistem Mimarisi

### Backend Mimarisi
- **Microservices**: NestJS modülleri bağımsız servisler olarak çalışır
- **WebRTC SFU**: MediaSoup ile Selective Forwarding Unit mimarisi
- **Signaling**: WebSocket üzerinden sinyal protokolü

### WebRTC Akışı
1. Kullanıcı bir tura katılır
2. WebSocket üzerinden sinyal sunucusuna bağlanır
3. MediaSoup transport nesneleri oluşturulur
4. Ses akışı için Producer ve Consumer nesneleri kurulur
5. Katılımcılar arasında gerçek zamanlı ses iletişimi başlar

## API Endpoint'leri

### Kullanıcı Yönetimi
- `POST /users` - Yeni kullanıcı oluşturma
- `GET /users` - Kullanıcı listesini alma
- `GET /users/:id` - Belirli bir kullanıcının bilgilerini alma
- `PATCH /users/:id` - Kullanıcı bilgilerini güncelleme
- `DELETE /users/:id` - Kullanıcı silme

### Tur Yönetimi
- `POST /tours` - Yeni tur oluşturma
- `GET /tours` - Tur listesini alma
- `GET /tours/:id` - Belirli bir turun bilgilerini alma
- `PATCH /tours/:id` - Tur bilgilerini güncelleme
- `DELETE /tours/:id` - Tur silme

### Sesli Oturum Yönetimi
- `POST /voice-sessions` - Yeni sesli oturum başlatma
- `GET /voice-sessions` - Aktif sesli oturumları alma
- `GET /voice-sessions/:id` - Belirli bir sesli oturumun bilgilerini alma
- `PATCH /voice-sessions/:id` - Sesli oturum bilgilerini güncelleme
- `DELETE /voice-sessions/:id` - Sesli oturumu sonlandırma

### WebRTC Yönetimi
- WebSocket üzerinden gerçekleşir
- `/webrtc` - WebRTC sinyal sunucusu

## Proje Durumu ve Yol Haritası

- [x] Temel API yapısı
- [x] WebRTC entegrasyonu
- [x] Supabase veritabanı entegrasyonu
- [ ] iOS uygulaması geliştirme
- [ ] Android uygulaması geliştirme
- [ ] Performans testleri ve optimizasyonlar
- [ ] AWS/Azure bulut ortamına geçiş

## Lisans

Bu proje özel lisans altında dağıtılmaktadır.

## İletişim

TurSesli Takımı - info@tursesli.com 

# Sesli İletişim Uygulaması

## Proje Hakkında
Bu uygulama, tur rehberleri ve turistler arasında sesli ve görüntülü iletişimi sağlayan bir iOS uygulamasıdır. Uygulama, WebRTC teknolojisi kullanarak gerçek zamanlı iletişim imkanı sunar.

## Özellikler
- 🎯 Anlık sesli ve görüntülü iletişim
- 👥 Grup oluşturma ve yönetme
- 🗺️ Tur keşfetme ve katılma
- 👤 Kullanıcı profil yönetimi
- ⚙️ Gelişmiş ayarlar ve özelleştirme seçenekleri

## Teknik Altyapı
- iOS 13.0+ desteği
- WebRTC tabanlı iletişim altyapısı
- Socket.IO ile gerçek zamanlı bağlantı
- Güvenli kimlik doğrulama sistemi
- Supabase veritabanı entegrasyonu

## Kurulum Gereksinimleri
- Xcode 14.0 veya üzeri
- iOS 13.0+ cihaz veya simülatör
- CocoaPods paket yöneticisi
- Node.js ve npm (backend için)

## Kurulum Adımları

### 1. Backend Kurulumu
```bash
cd backend
npm install
npm run start
```

### 2. iOS Uygulaması Kurulumu
```bash
cd SesliIletisim
pod install
open SesliIletisim.xcworkspace
```

### 3. Ortam Değişkenleri
`.env` dosyasını oluşturun ve gerekli değişkenleri ayarlayın:
```
API_URL=https://api.example.com
SOCKET_URL=wss://socket.example.com
TURN_SERVER=turn:turn.example.com:3478
```

## Derleme ve Çalıştırma
1. Xcode'da projeyi açın
2. Hedef cihazı seçin
3. Build (⌘+B) yapın
4. Run (⌘+R) ile çalıştırın

## Sorun Giderme
Sık karşılaşılan sorunlar ve çözümleri:

### Pod Kurulum Sorunları
```bash
pod deintegrate
pod cache clean --all
pod install
```

### Derleme Hataları
- Clean Build klasörü (⇧⌘K)
- Derived Data klasörünü temizleyin
- Pod'ları yeniden yükleyin

## Güvenlik
- SSL/TLS şifreleme
- Güvenli token tabanlı kimlik doğrulama
- WebRTC şifrelemesi
- Keychain veri depolama

## Mimari Yapı
- MVVM tasarım deseni
- Protocol-oriented programming
- Dependency injection
- Clean Architecture prensipleri

## Kullanılan Kütüphaneler
- Alamofire: Network istekleri
- Socket.IO: Gerçek zamanlı iletişim
- WebRTC: Görüntülü görüşme
- KeychainAccess: Güvenli veri depolama
- SDWebImage: Görsel yönetimi
- Toast-Swift: Bildirimler

## Katkıda Bulunma
1. Fork edin
2. Feature branch oluşturun
3. Değişikliklerinizi commit edin
4. Branch'inizi push edin
5. Pull Request oluşturun

## Lisans
Bu proje MIT lisansı altında lisanslanmıştır.

## İletişim
- GitHub: [@hiktan44](https://github.com/hiktan44)

## Sürüm Geçmişi
### v1.0.0 (2024-03-03)
- İlk sürüm
- Temel özellikler eklendi
- Giriş sistemi optimize edildi
