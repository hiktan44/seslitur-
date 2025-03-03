# WebRTC Derleme Sorunu Çözümü

## Sorun Açıklaması

SesliIletisim projesinde WebRTC kütüphanesi ile ilgili derleme sorunları yaşanmaktadır. Bu sorunlar genellikle şu şekilde ortaya çıkar:

1. `WebRTC.h` dosyası bulunamadı hatası
2. `RTCPeerConnection` sınıfı bulunamadı hatası
3. Sandbox izin hataları (rsync ile ilgili)
4. Linker hataları (framework bulunamadı)

## Çözüm Adımları

### 1. Import İfadelerini Düzeltme

WebRTC import ifadelerini düzeltmek için:

```swift
// Yanlış
import WebRTC

// Doğru
import GoogleWebRTC
```

Bu değişikliği şu dosyalarda yapın:
- `WebRTCService.swift`
- `DashboardViewController.swift`
- WebRTC kullanan diğer dosyalar

### 2. Podfile Düzenlemeleri

Podfile'da GoogleWebRTC sürümünü sabit bir sürüme ayarlayın:

```ruby
# Yanlış
pod 'GoogleWebRTC', '~> 1.1.31999'

# Doğru
pod 'GoogleWebRTC', '1.1.32000'
```

### 3. Build Settings Düzenlemeleri

Xcode'da şu ayarları yapın:

1. `ENABLE_BITCODE = NO`
2. `VALID_ARCHS = arm64 x86_64`
3. `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`
4. `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES`

Bu ayarları `xcconfig/custom.xcconfig` dosyasında veya Xcode'da doğrudan yapabilirsiniz.

### 4. Temizleme İşlemleri

Derleme sorunlarını çözmek için şu temizleme işlemlerini yapın:

```bash
# Türetilmiş verileri temizle
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*

# Xcode önbelleğini temizle
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# Pod'ları yeniden yükle
pod deintegrate
pod install
```

### 5. İzin Sorunları

Sandbox izin hatalarını çözmek için:

1. Xcode'u tamamen kapatın
2. Xcode'u Finder'da bulun ve "Get Info" seçeneğini tıklayın
3. "Open in Rosetta" seçeneğini işaretleyin (M1/M2 Mac'lerde)
4. Proje dosyalarının izinlerini düzeltin:
   ```bash
   chmod -R 755 .
   ```

## Ek Notlar

- GoogleWebRTC pod'u kullanımdan kaldırılmıştır, ancak şu an için projede kullanılmaktadır.
- Simülatörde derleme yaparken, M1/M2 Mac'lerde "Open in Rosetta" seçeneğini etkinleştirmeniz gerekebilir.
- Xcode 14 ve üzeri sürümlerde bazı ek yapılandırmalar gerekebilir.

## Referanslar

- [GoogleWebRTC Pod Sayfası](https://cocoapods.org/pods/GoogleWebRTC)
- [WebRTC Resmi Dokümantasyonu](https://webrtc.org/getting-started/ios)
- [Apple Developer Forums - Sandbox İzin Hataları](https://developer.apple.com/forums/thread/668564) 