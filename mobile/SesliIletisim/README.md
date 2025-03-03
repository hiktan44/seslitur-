# SesliIletisim - Gerçek Zamanlı Sesli İletişim Sistemi

SesliIletisim, 100-300 kişilik gruplar için internet üzerinden gerçek zamanlı sesli iletişim sağlayan bir mobil uygulamadır. WebRTC teknolojisi kullanarak düşük gecikme süresi ve yüksek ses kalitesiyle grup iletişimi sağlar.

![SesliIletisim Logo](Assets.xcassets/AppIcon.appiconset/Icon-76.png)

## Özellikler

- 📡 Gerçek zamanlı sesli iletişim (150ms'den az gecikme)
- 👥 100-300 kişilik grupları destekler
- 🔒 Uçtan uca şifreleme
- 🔊 Yüksek ses kalitesi (Opus kodek)
- 📱 iOS için native geliştirme
- 🎧 Bluetooth kulaklık desteği
- 🔋 Optimize edilmiş pil kullanımı
- 🌐 Düşük bant genişliği adaptasyonu (20-128 kbps)

## Kurulum ve Çalıştırma

### Gereksinimler

- Xcode 14.0 veya üstü
- iOS 14.0 veya üstü
- CocoaPods

### Kurulum Adımları

1. Projeyi klonlayın:
   ```bash
   git clone https://github.com/kullanici/SesliIletisim.git
   cd SesliIletisim
   ```

2. CocoaPods bağımlılıklarını yükleyin:
   ```bash
   pod install
   ```

3. Workspace'i açın:
   ```bash
   open SesliIletisim.xcworkspace
   ```

4. Projeyi derleyin ve çalıştırın (Command+R)

### M4 Mac'lerde Kurulum (Apple Silicon)

M4 Mac'lerde Alamofire ve WebRTC entegrasyonu ile ilgili sorunlar yaşanabilir. Çözüm için:

1. Rosetta 2'yi kurun (gerekiyorsa):
   ```bash
   softwareupdate --install-rosetta
   ```

2. Düzeltme scriptini çalıştırın:
   ```bash
   chmod +x BugFix/alamofire_fix.sh
   ./BugFix/alamofire_fix.sh
   ```

3. Xcode'u Rosetta ile açın:
   ```bash
   arch -x86_64 open -a Xcode SesliIletisim.xcworkspace
   ```

Daha fazla bilgi için [SORUN_GIDERME.md](SORUN_GIDERME.md) dosyasına bakabilirsiniz.

## Proje Yapısı

```
SesliIletisim/
├── Assets.xcassets/       # Görseller ve assetler
├── Controllers/           # View Controller'lar
├── Views/                 # UI bileşenleri
├── Models/                # Veri modelleri
├── Services/              # Servisler
│   ├── APIService.swift        # API istekleri
│   ├── WebRTCService.swift     # WebRTC entegrasyonu
│   ├── AuthService.swift       # Kimlik doğrulama
│   └── AudioService.swift      # Ses yönetimi
├── Utils/                 # Yardımcı sınıflar
├── BugFix/                # Düzeltme scriptleri
└── xcconfig/              # Yapılandırma dosyaları
```

## API Dokümantasyonu

### Oturum Yönetimi

| Endpoint | Açıklama | Parametre |
|----------|----------|-----------|
| `/api/auth/login` | Kullanıcı girişi | `email`, `password` |
| `/api/auth/register` | Yeni kullanıcı kaydı | `email`, `password`, `name` |
| `/api/auth/logout` | Çıkış yapma | `token` |

### Grup Yönetimi

| Endpoint | Açıklama | Parametre |
|----------|----------|-----------|
| `/api/groups/create` | Grup oluşturma | `name`, `description`, `isPrivate` |
| `/api/groups/join` | Gruba katılma | `groupId`, `password` (opsiyonel) |
| `/api/groups/leave` | Gruptan ayrılma | `groupId` |

## WebRTC Mimarisi

SesliIletisim, SFU (Selective Forwarding Unit) mimarisi kullanarak çok sayıda katılımcının düşük gecikme ile iletişim kurmasını sağlar:

1. Kullanıcı, WebSocket üzerinden signaling sunucusuna bağlanır
2. Kullanıcı, STUN/TURN sunucuları aracılığıyla NAT geçişi yapar
3. Medya sunucusu (mediasoup), gelen ses akışlarını seçici olarak diğer kullanıcılara iletir
4. Opus kodek kullanılarak ses kalitesi optimize edilir

## Katkıda Bulunma

Projeye katkıda bulunmak isterseniz, lütfen bir pull request açın. Herhangi bir değişiklik yapmadan önce, test birimlerini çalıştırdığınızdan emin olun.

## Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## İletişim

Sorularınız için: sesli.iletisim@example.com 

# SesliIletisim iOS Uygulaması - Sorun Giderme Kılavuzu

Bu belge, SesliIletisim iOS uygulamasında karşılaşılan yaygın sorunları gidermek için oluşturulmuş çözüm yöntemlerini içerir.

## İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Karşılaşılan Sorunlar](#karşılaşılan-sorunlar)
3. [Çözüm Scriptleri](#çözüm-scriptleri)
4. [Kurulum Adımları](#kurulum-adımları)
5. [Elle Çözüm Adımları](#elle-çözüm-adımları)
6. [Sık Sorulan Sorular](#sık-sorulan-sorular)

## Genel Bakış

SesliIletisim, gerçek zamanlı sesli iletişim sağlayan bir iOS uygulamasıdır. Bu uygulama, çeşitli 3. parti kütüphaneleri kullanır:

- **Socket.IO-Client-Swift**: Gerçek zamanlı iletişim için
- **Starscream**: WebSocket bağlantıları için
- **Alamofire**: Ağ istekleri için
- **KeychainAccess**: Güvenli veri depolama için
- **SDWebImage**: Görsel önbelleğe alma için
- **Toast-Swift**: Kullanıcı bildirimleri için
- **GoogleWebRTC**: Sesli iletişim için

## Karşılaşılan Sorunlar

iOS projemizde aşağıdaki genel sorunlarla karşılaşılmaktadır:

1. **Framework Sorunu**: `Pods_SesliIletisim.framework not found` hatası
2. **Socket.IO ve Starscream Uyumsuzluğu**: `WebSocketDelegate` protokol uyumsuzluğu
3. **Privacy Bundle Sorunu**: `Starscream_Privacy.bundle/Starscream_Privacy` dosyası bulunamıyor hatası
4. **XCFilelist Sorunu**: `Unable to load contents of file list` hatası

## Çözüm Scriptleri

Bu sorunları çözmek için aşağıdaki scriptler hazırlanmıştır:

1. **`fix_all_issues.sh`**: Tüm sorunları tek seferde çözen ana script
2. **`fix_socket_io_compatibility.sh`**: Socket.IO ve Starscream uyumsuzluğunu çözer
3. **`create_privacy_bundles.sh`**: Privacy Bundle sorunlarını çözer
4. **`build_with_privacy.sh`**: Command Line kullanarak derleme yapar
5. **`fix_xcfilelist.sh`**: XCFilelist sorunlarını çözer ve Xcode projesi yapılandırmasını düzeltir

### Script Çalıştırma

```bash
# Tüm sorunları tek seferde çöz
chmod +x fix_all_issues.sh
./fix_all_issues.sh

# Ya da ayrı ayrı çöz
chmod +x fix_socket_io_compatibility.sh
./fix_socket_io_compatibility.sh

chmod +x create_privacy_bundles.sh
./create_privacy_bundles.sh

chmod +x fix_xcfilelist.sh
./fix_xcfilelist.sh
```

## Kurulum Adımları

### 1. Yeni bir Temiz Kurulum İçin

```bash
# Repository'i klonla
git clone [repo-url]
cd SesliIletisim

# Pod'ları yükle
pod install

# Sorunları tek seferde çöz
chmod +x fix_all_issues.sh
./fix_all_issues.sh
```

### 2. Mevcut Bir Kurulum İçin

```bash
# DerivedData temizle
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*

# Pod'ları yeniden yükle
pod deintegrate
pod clean
rm -rf Pods
pod install --repo-update

# Sorunları çöz
./fix_all_issues.sh
```

## Elle Çözüm Adımları

### 1. Framework Sorunu Çözümü

1. `custom.xcconfig` dosyasını düzenleyin:
   ```
   FRAMEWORK_SEARCH_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/Alamofire" "${PODS_CONFIGURATION_BUILD_DIR}/KeychainAccess" "${PODS_CONFIGURATION_BUILD_DIR}/SDWebImage" "${PODS_CONFIGURATION_BUILD_DIR}/Socket.IO-Client-Swift" "${PODS_CONFIGURATION_BUILD_DIR}/Starscream" "${PODS_CONFIGURATION_BUILD_DIR}/Toast-Swift" "${PODS_ROOT}/GoogleWebRTC/Frameworks/frameworks"
   ```

2. Xcode'da proje ayarlarını kontrol edin:
   - Build Settings > Framework Search Paths
   - Build Settings > Other Linker Flags

### 2. Socket.IO Uyumsuzluk Çözümü

1. Podfile'da doğru sürümleri belirtin:
   ```
   pod 'Socket.IO-Client-Swift', '16.0.1'
   pod 'Starscream', '4.0.4'
   ```

2. `WebSocketCompat.swift` dosyasını oluşturun ve gerekli uzantıları ekleyin.

### 3. Privacy Bundle Sorunu Çözümü

1. Xcode'da Build Phases'e yeni bir Run Script Phase ekleyin:
   ```bash
   sh "${SRCROOT}/create_privacy_bundles.sh"
   ```

2. Bu fazı "[CP] Embed Pods Frameworks" fazından önce çalışacak şekilde taşıyın.

### 4. XCFilelist Sorunları Çözümü

"Unable to load contents of file list" hatası için:

1. `fix_xcfilelist.sh` script'ini çalıştırın:
   ```bash
   ./fix_xcfilelist.sh
   ```

2. Bu script aşağıdaki işlemleri yapar:
   - Eksik XCFilelist dosyalarını otomatik olarak oluşturur
   - Proje konfigürasyonlarındaki yolları düzeltir
   - Yeni eklenen kütüphaneleri tespit ederek listeye ekler

## Sık Sorulan Sorular

### Xcode açılmıyor veya çöküyor ne yapmalıyım?

DerivedData klasörünü temizleyin ve şu komutu çalıştırın:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
```

### "Framework not found Pods_SesliIletisim" hatası alıyorum

`fix_all_issues.sh` script'ini çalıştırın veya şu adımları takip edin:
1. Pod'ları yeniden yükleyin: `pod deintegrate && pod install`
2. `custom.xcconfig` dosyasını düzenleyin
3. Proje ayarlarında Base Configuration dosyasını kontrol edin

### Starscream Privacy Bundle hatası alıyorum

1. `create_privacy_bundles.sh` script'ini çalıştırın
2. Bu script'i Xcode Build Phases'e ekleyin
3. Clean Build Folder (Shift+Cmd+K) yapın ve tekrar derleyin

### "Unable to load contents of file list" hatası alıyorum

Bu sorun, XCFilelist dosyalarının eksik olduğunu gösterir. Çözüm:
1. `fix_all_issues.sh` script'ini çalıştırın
2. Veya manuel olarak `Target Support Files/Pods-SesliIletisim/` altındaki .xcfilelist dosyalarını kontrol edin

## Teknik Detaylar

### WebSocket Uyumluluğu

Socket.IO-Client-Swift, Starscream 3.x ile uyumlu olarak tasarlanmış, ancak projemizde Starscream 4.x kullanıldığından uyumluluk katmanı oluşturuldu.

### Privacy Bundle Yapısı

iOS 17 ve Xcode 15 ile gelen değişiklikler, 3. parti kütüphanelerde Privacy Bundle gerektiriyor. Her kütüphane için oluşturulan bundle şunları içerir:
- Info.plist
- PrivacyInfo.xcprivacy
- Binary dosya

---

Bu belge, SesliIletisim iOS uygulaması geliştirme ekibi tarafından hazırlanmıştır.
Son güncelleme: Ekim 2023 