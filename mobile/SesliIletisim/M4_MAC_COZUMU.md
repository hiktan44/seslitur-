# M4 Mac için SesliIletisim Projesi Derleme Çözümü

## Sorun

M4 Mac'lerde SesliIletisim projesini derlerken şu hatalar alınabilir:
- "Framework 'Alamofire' not found"
- "Linker command failed with exit code 1"
- Sandbox izin hataları

## Hızlı Çözüm

Otomatik çözüm scripti hazırladık. Bu script, M4 Mac'lerde yaşanan derleme sorunlarını çözmek için gerekli tüm adımları otomatik olarak uygular.

```bash
# Scripti çalıştırın
./BugFix/m4_mac_fix.sh
```

Script şu işlemleri yapar:
1. Xcode'un türetilmiş verilerini temizler
2. Pod'ları temizler ve yeniden yükler
3. Podfile'ı M4 Mac için optimize eder
4. xcconfig dosyasını günceller
5. WebRTC import ifadelerini düzeltir
6. Xcode projesi için Build Settings'i günceller

## Manuel Çözüm Adımları

Eğer script çalışmazsa, aşağıdaki adımları manuel olarak uygulayabilirsiniz:

### 1. Xcode'u Rosetta ile Açın

1. Finder'da Xcode uygulamasını bulun
2. Sağ tıklayın ve "Get Info" seçeneğini seçin
3. "Open in Rosetta" seçeneğini işaretleyin
4. Xcode'u yeniden başlatın

### 2. Temizleme İşlemleri

```bash
# Xcode'un türetilmiş verilerini temizleyin
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# Pod'ları temizleyin
cd /path/to/SesliIletisim
pod deintegrate
rm -rf Pods
rm -rf Podfile.lock
```

### 3. Podfile'ı Düzenleyin

Podfile'ı aşağıdaki gibi düzenleyin:

```ruby
platform :ios, '14.0'

# M4 Mac için ek ayarlar
install! 'cocoapods', :deterministic_uuids => false

target 'SesliIletisim' do
  use_frameworks!

  # Pods for SesliIletisim
  pod 'Alamofire', '5.5.0'
  pod 'GoogleWebRTC', '1.1.32000'
  pod 'Socket.IO-Client-Swift', '16.1.0'
  pod 'KeychainAccess', '4.2.2'
  pod 'SDWebImage', '5.12.5'
  pod 'Toast-Swift', '5.0.1'
  pod 'Starscream', '4.0.4'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['VALID_ARCHS'] = 'arm64 x86_64'
      
      # M4 Mac için ek ayarlar
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphoneos*]"] = "armv7"
      
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
end
```

### 4. Pod'ları Yeniden Yükleyin

```bash
pod install
```

### 5. WebRTC Import İfadelerini Düzeltin

WebRTCService.swift ve DashboardViewController.swift dosyalarında WebRTC import ifadelerini düzeltin:

```swift
// Yanlış
import WebRTC

// Doğru
import GoogleWebRTC
```

### 6. Xcode'da Build Settings'i Düzenleyin

1. Projenizi seçin > Build Settings > Architectures > Build Active Architecture Only > Debug > YES
2. Projenizi seçin > Build Settings > Excluded Architectures > Any iOS Simulator SDK > i386
3. Projenizi seçin > Build Settings > Excluded Architectures > Any iOS Device SDK > armv7
4. Projenizi seçin > Build Settings > Enable Bitcode > NO
5. Projenizi seçin > Build Settings > Always Embed Swift Standard Libraries > YES
6. Projenizi seçin > Build Settings > Build Library for Distribution > YES

### 7. Derleme

1. Xcode'da Product > Clean Build Folder (Shift+Command+K) seçeneğini kullanın
2. Product > Build (Command+B) seçeneğini kullanın

## Ek Çözümler

Eğer yukarıdaki adımlar sorunu çözmezse, şu ek çözümleri deneyebilirsiniz:

### CocoaPods'u Güncelleme

```bash
sudo gem install cocoapods
```

### Xcode Komut Satırı Araçlarını Yeniden Yükleme

```bash
sudo xcode-select --install
```

### Xcode'u Güncelleme veya Eski Sürüme Geçme

Xcode'un en son sürümünü veya daha eski bir sürümünü kullanmayı deneyebilirsiniz.

## Teknik Açıklama

M4 Mac'lerde yaşanan derleme sorunları, Apple Silicon mimarisinin x86_64 mimarisinden farklı olması ve bazı kütüphanelerin henüz tam olarak Apple Silicon'a optimize edilmemesinden kaynaklanmaktadır.

Rosetta 2 emülatörü, x86_64 mimarisine sahip uygulamaları çalıştırmak için kullanılır. Xcode'u Rosetta ile açmak, derleme sürecinde x86_64 mimarisine sahip kütüphanelerin doğru şekilde derlenmesini sağlar.

## Referanslar

- [Apple Developer Forums - M1 Mac Build Issues](https://developer.apple.com/forums/thread/677180)
- [CocoaPods Issues - Apple Silicon Support](https://github.com/CocoaPods/CocoaPods/issues/10220)
- [Alamofire GitHub - Apple Silicon Support](https://github.com/Alamofire/Alamofire/issues/3500) 