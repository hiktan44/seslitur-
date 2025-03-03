# Sesli İletişim iOS Uygulaması Kurulum Kılavuzu

Bu döküman, Sesli İletişim iOS uygulamasının geliştirme ortamını kurma ve uygulamayı çalıştırma adımlarını içerir.

## Gereksinimler

- macOS işletim sistemi
- Xcode 13.0 veya üzeri
- iOS 15.0 veya üzeri cihaz/simülatör
- CocoaPods 1.13.0 veya üzeri
- Git

## Kurulum Adımları

### 1. Depoyu Klonlama

```bash
git clone https://github.com/username/tursesli.git
cd tursesli
```

### 2. CocoaPods Kurulumu

Eğer sisteminizde CocoaPods kurulu değilse veya sürümü eskiyse:

```bash
sudo gem install cocoapods
```

### 3. Bağımlılıkları Yükleme

```bash
cd mobile/SesliIletisim
pod install
```

Bu işlem, aşağıdaki kütüphaneleri içeren bağımlılıkları yükleyecektir:

- Alamofire: Network istekleri için
- GoogleWebRTC: WebRTC medya işlemleri için
- Socket.IO-Client-Swift: WebSocket iletişimi için
- SnapKit: UI layout işlemleri için
- Toast-Swift: Bildirimler için
- KeychainSwift: Güvenli depolama için

### 4. Xcode ile Projeyi Açma

```bash
open SesliIletisim.xcworkspace
```

**Not:** `.xcodeproj` dosyası yerine `.xcworkspace` dosyasını açmanız önemlidir.

### 5. Yapılandırma Ayarları

1. `APIService.swift` dosyasındaki `baseURL` değişkenini backend sunucunuzun adresine göre ayarlayın:

```swift
// APIService.swift içinde
private init() {
    #if DEBUG
    // Geliştirme ortamında localhost
    self.baseURL = "http://localhost:3000"
    #else
    // Prod ortamında gerçek sunucu adresi
    self.baseURL = "https://api.tursesli.com"
    #endif
}
```

2. Xcode içinde "Signing & Capabilities" ayarlarını kendi geliştirici hesabınıza göre yapılandırın.

### 6. Uygulamayı Çalıştırma

1. Xcode'da bir iOS cihazı veya simülatörü seçin
2. Build (⌘+B) ve ardından Run (⌘+R) yapın

## Backend Bağlantısı

Uygulama, aşağıdaki özellikleri kullanabilmek için çalışan bir NestJS backend sunucusuna ihtiyaç duyar:

- Kullanıcı kimlik doğrulama ve yetkilendirme
- Tur yönetimi
- Sesli oturum yönetimi
- WebRTC sinyal iletişimi

Backend sunucusunu çalıştırmak için:

```bash
# Proje ana dizinine dönün
cd ../..

# Backend sunucusunu başlatın
npm run start:dev
```

Backend API şu adreste erişilebilir olacaktır: <http://localhost:3000/api>

## Sorun Giderme

### Import Hataları

Eğer "No such module" hataları alıyorsanız:

1. Podfile'ı doğru şekilde güncelleyin
2. CocoaPods sürümünüzün güncel olduğundan emin olun (en az 1.13.0)
3. `pod repo update && pod install` komutunu çalıştırın
4. Xcode'u kapatıp tekrar açın

### Simülatör Mikrofon İzinleri

Simülatörde mikrofon izinlerini test etmek için:

1. Xcode menüsünden, I/O > Input > Microphone seçeneğini etkinleştirin
2. Ardından Features > Privacy > Microphone izinlerini etkinleştirin

### Bağlantı Sorunları

Backend sunucusuna bağlanırken sorun yaşıyorsanız:

1. API sunucusunun çalıştığından emin olun
2. iOS Uygulamasında doğru sunucu adresini kullandığınızı kontrol edin
3. iOS simulatörünün localhost'a erişebildiğinden emin olun (<http://localhost:3000>)

### Xcode Build Sorunları

- Pod bağımlılıklarıyla ilgili sorunlar için: `pod deintegrate && pod install`
- Cache ile ilgili sorunlar için: Xcode'u kapatın ve `rm -rf ~/Library/Developer/Xcode/DerivedData` komutunu çalıştırın

### "No Schema" Hatası

Bu hata genellikle WebRTCService.swift dosyasındaki URLComponents kullanımından kaynaklanır. Çözüm için:

1. WebRTCService.swift dosyasında setupWebSocket() metodunu kontrol edin:
```swift
private func setupWebSocket() {
    var urlComponents = URLComponents()
    
    #if DEBUG
    // Geliştirme ortamında yerel sunucu ve ws protokolü
    urlComponents.scheme = "ws"
    urlComponents.host = "localhost"
    urlComponents.port = 3000
    #else
    // Üretim ortamında güvenli wss protokolü
    urlComponents.scheme = "wss"
    urlComponents.host = "api.sesliletisim.com"
    #endif
    
    urlComponents.path = "/ws"
    // ...
}
```

2. URLComponents oluşturma işleminin sorunsuz çalıştığından emin olun:
   - scheme ve host değerleri boş olmamalı
   - WebSocket sunucusunun çalıştığından emin olun
   - Yerel sunucu için port numarasının doğru olduğunu kontrol edin

3. Yerel WebSocket sunucusunun terminalde çalıştığını doğrulayın:
```bash
curl -v "ws://localhost:3000/ws"
```

Bu komut bağlantı başarısız olsa bile sunucunun yanıt verip vermediğini gösterecektir.

## Notlar

Bu uygulama, demo/geliştirme amaçlıdır ve şu anda aşağıdaki özellikler tam olarak çalışmaktadır:

- Kullanıcı giriş/kayıt işlemleri
- Tur listeleme ve katılma
- WebRTC üzerinden sesli iletişim

Arka uç sunucusu olmadan, uygulama sınırlı işlevselliğe sahip olacaktır.

## Bilinen Sorunlar

- GoogleWebRTC kütüphanesi artık desteklenmiyor (deprecated), ama hala çalışıyor.
- Bazı eski iOS sürümlerinde (iOS 15'ten daha eski) mikrofon izinleri ile ilgili sorunlar olabilir.

## Güvenlik Uyarıları

- Geliştirme amacıyla, uygulama şu anda HTTP kullanıyor. Üretim ortamında HTTPS kullanmak önemlidir.
- Token'ları güvenli bir şekilde saklayın ve üretim ortamında oturum sürelerini uygun şekilde sınırlandırın.

## Yeni Bağımlılıklar Eklendiğinde

Yeni kütüphaneler Podfile'a eklendiğinde veya varolan kütüphaneler güncellendiğinde aşağıdaki adımları izleyin:

1. Terminal'i açın ve proje dizinine gidin:
```
cd /Users/hikmettanriverdi/adsız\ klasör/mobile/SesliIletisim
```

2. Pod install komutunu çalıştırın:
```
pod install
```

3. İşlem tamamlandıktan sonra, Xcode'u kapatıp, .xcworkspace dosyasını açın:
```
open SesliIletisim.xcworkspace
```

4. Gerekiyorsa temiz bir derleme yapın:
   - Xcode'da "Product" > "Clean Build Folder" seçeneğini kullanın
   - Ardından "Product" > "Build" seçeneğini kullanın

## Derleme Hataları Çözümleri

### "No such module 'XYZ'" Hatası

Bu hata genellikle CocoaPods ile yüklenen bir modülün bulunamaması durumunda oluşur. Çözüm için:

1. Podfile'da ilgili bağımlılığın olduğundan emin olun
2. Pod install komutunu tekrar çalıştırın
3. .xcworkspace dosyasını kullandığınızdan emin olun (.xcodeproj değil)
4. Xcode'u tamamen kapatıp yeniden açın
5. Derived Data klasörünü temizleyin:
   - Xcode > Preferences > Locations > Derived Data 
   - Path'i bulun ve klasörü silin

### WebRTC ve Socket.IO Hataları

WebRTC ve Socket.IO kütüphaneleri için özel olarak:

1. Import ifadelerinin doğru olduğundan emin olun:
   - `import GoogleWebRTC` (WebRTC için)
   - `import SocketIO` (Socket.IO için)
   
2. Podfile'da doğru sürümlerin belirtildiğinden emin olun:
   - `pod 'GoogleWebRTC', '~> 1.1.31999'`  
   - `pod 'Socket.IO-Client-Swift', '~> 16.1.0'`

3. Import sorunu devam ederse modül ismini kontrol edin:
   - Bazen modül isimleri Cocoapods'da farklı olabilir
