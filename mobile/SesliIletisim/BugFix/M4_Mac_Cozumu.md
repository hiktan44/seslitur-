# M4 Mac için Alamofire ve WebRTC Derleme Sorunları Çözümü

## Sorun Açıklaması

Apple Silicon (M serisi) işlemcilerde, özellikle M4 Mac'lerde, Alamofire ve WebRTC gibi framework'lerin derlenmesi sırasında şu hatalar alınabilir:

- "Framework 'Alamofire' not found"
- "Linker command failed with exit code 1"
- Sandbox izin hataları

Bu sorunlar, Apple Silicon mimarisinin x86_64 mimarisinden farklı olması ve bazı kütüphanelerin henüz tam olarak Apple Silicon'a optimize edilmemesinden kaynaklanmaktadır.

## Çözüm Adımları

### 1. Podfile Düzenlemeleri

Podfile'ı aşağıdaki gibi düzenleyin:

```ruby
platform :ios, '14.0'

# M4 Mac için ek ayarlar
install! 'cocoapods', :deterministic_uuids => false

target 'SesliIletisim' do
  use_frameworks!

  # Pods for SesliIletisim
  pod 'Alamofire', '~> 5.5.0'
  pod 'GoogleWebRTC', '1.1.32000'
  # Diğer pod'lar...
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

### 2. xcconfig Düzenlemeleri

`custom.xcconfig` dosyasını aşağıdaki gibi düzenleyin:

```
FRAMEWORK_SEARCH_PATHS = $(inherited) ${PODS_ROOT}/GoogleWebRTC/Frameworks/frameworks ${PODS_CONFIGURATION_BUILD_DIR}/Alamofire ${PODS_CONFIGURATION_BUILD_DIR}/KeychainAccess ${PODS_CONFIGURATION_BUILD_DIR}/SDWebImage ${PODS_CONFIGURATION_BUILD_DIR}/Socket.IO-Client-Swift ${PODS_CONFIGURATION_BUILD_DIR}/Starscream ${PODS_CONFIGURATION_BUILD_DIR}/Toast-Swift
ENABLE_BITCODE = NO
VALID_ARCHS = arm64 x86_64
EXCLUDED_ARCHS[sdk=iphonesimulator*] = i386
EXCLUDED_ARCHS[sdk=iphoneos*] = armv7
OTHER_LDFLAGS = $(inherited) -framework Alamofire -framework KeychainAccess -framework SDWebImage -framework SocketIO -framework Starscream -framework Toast_Swift -framework WebRTC
SWIFT_VERSION = 5.0
ONLY_ACTIVE_ARCH[config=Debug] = YES
ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES
BUILD_LIBRARY_FOR_DISTRIBUTION = YES
```

### 3. Pod'ları Temizleme ve Yeniden Yükleme

Terminal'de şu komutları çalıştırın:

```bash
cd /path/to/SesliIletisim
pod deintegrate
rm -rf Pods
rm -rf Podfile.lock
pod install
```

### 4. Xcode'u Temizleme

Terminal'de şu komutları çalıştırın:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

### 5. Xcode'u Rosetta ile Çalıştırma

1. Finder'da Xcode uygulamasını bulun
2. Sağ tıklayın ve "Get Info" seçeneğini seçin
3. "Open in Rosetta" seçeneğini işaretleyin
4. Xcode'u yeniden başlatın

### 6. Derleme Ayarları

Xcode'da projenizi açın ve şu ayarları yapın:

1. Projenizi seçin > Build Settings > Architectures > Build Active Architecture Only > Debug > YES
2. Projenizi seçin > Build Settings > Excluded Architectures > Any iOS Simulator SDK > i386
3. Projenizi seçin > Build Settings > Validate Workspace > YES

### 7. Derleme

1. Xcode'da Product > Clean Build Folder (Shift+Command+K) seçeneğini kullanın
2. Product > Build (Command+B) seçeneğini kullanın

## Ek Notlar

- M4 Mac'lerde Rosetta 2 emülatörü, x86_64 mimarisine sahip uygulamaları çalıştırmak için kullanılır.
- Bazı durumlarda, Xcode'un komut satırı araçlarını yeniden yüklemeniz gerekebilir:
  ```bash
  sudo xcode-select --install
  ```
- CocoaPods'un en son sürümünü kullandığınızdan emin olun:
  ```bash
  sudo gem install cocoapods
  ```

## Referanslar

- [Apple Developer Forums - M1 Mac Build Issues](https://developer.apple.com/forums/thread/677180)
- [CocoaPods Issues - Apple Silicon Support](https://github.com/CocoaPods/CocoaPods/issues/10220)
- [Alamofire GitHub - Apple Silicon Support](https://github.com/Alamofire/Alamofire/issues/3500) 