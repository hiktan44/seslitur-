# M4 Mac için SesliIletisim Projesi Sorun Giderme Kılavuzu

Bu belge, özellikle M4 (Apple Silicon) Mac'lerde SesliIletisim projesinin derlenme sorunlarını gidermek için hazırlanmıştır.

## Sıklıkla Karşılaşılan Sorunlar

### "Framework 'Alamofire' not found" Hatası

Bu hata genellikle M4 Mac'lerde Alamofire framework'ünün doğru bir şekilde entegre edilememesi nedeniyle ortaya çıkar.

### Çözüm Yöntemleri

1. **Rosetta 2 ile Xcode Çalıştırma**

   M4 Mac'lerde bazı iOS kütüphaneleri (özellikle Alamofire, Google WebRTC) henüz tam olarak native Apple Silicon desteği sağlamamış olabilir. Bu nedenle Xcode'u Rosetta 2 ile çalıştırmak çözüm olabilir:

   ```bash
   arch -x86_64 open -a Xcode SesliIletisim.xcworkspace
   ```

2. **CocoaPods'u Rosetta 2 ile Yükleme**

   Tüm pod'ları x86_64 mimarisi ile yüklemelisiniz:

   ```bash
   arch -x86_64 pod deintegrate
   arch -x86_64 pod install
   ```

3. **Otomatik Düzeltme Scripti Kullanma**

   Projede bulunan düzeltme scriptini kullanabilirsiniz:

   ```bash
   chmod +x BugFix/alamofire_fix.sh
   ./BugFix/alamofire_fix.sh
   ```

4. **Podfile Düzenlemeleri**

   Eğer Alamofire hatası devam ediyorsa, Podfile'ı şu şekilde düzenleyin:
   
   ```ruby
   # Framework yerine modular header kullan
   use_modular_headers!
   # use_frameworks!
   
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       target.build_configurations.each do |config|
         config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
         config.build_settings['ENABLE_BITCODE'] = 'NO'
         config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
         
         # Framework arama yolları
         config.build_settings['FRAMEWORK_SEARCH_PATHS'] = [
           "$(inherited)",
           "\"${PODS_ROOT}/GoogleWebRTC/Frameworks\"",
           "\"${PODS_ROOT}/**\"",
           "\"${PODS_XCFRAMEWORKS_BUILD_DIR}/**\""
         ]
         
         # Library arama yolları
         config.build_settings['LIBRARY_SEARCH_PATHS'] = [
           "$(inherited)",
           "\"${PODS_ROOT}/**\"",
           "\"${PODS_CONFIGURATION_BUILD_DIR}/**\""
         ]
         
         # Swift modül yolları
         config.build_settings['SWIFT_INCLUDE_PATHS'] = [
           "$(inherited)",
           "\"${PODS_CONFIGURATION_BUILD_DIR}/**\"",
           "\"${PODS_ROOT}/**\""
         ]
       end
     end
   end
   ```

5. **xcconfig Dosyası Düzenlemeleri**

   `xcconfig/custom.xcconfig` dosyasını şu şekilde düzenleyin:

   ```
   FRAMEWORK_SEARCH_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/**" "${PODS_ROOT}/GoogleWebRTC/Frameworks" "${PODS_ROOT}/**" "${PODS_XCFRAMEWORKS_BUILD_DIR}/**"
   HEADER_SEARCH_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/**" "${PODS_ROOT}/**"
   LIBRARY_SEARCH_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/**" "${PODS_ROOT}/**" "${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}" /usr/lib/swift
   ENABLE_BITCODE = NO
   VALID_ARCHS = arm64 x86_64
   EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
   EXCLUDED_ARCHS[sdk=iphoneos*] = x86_64
   OTHER_LDFLAGS = $(inherited) -ObjC -l"Alamofire" -l"GoogleWebRTC" -l"KeychainAccess" -l"SDWebImage" -l"SocketIO" -l"Starscream" -l"Toast_Swift" -l"c++" -l"icucore" -l"sqlite3" -l"z" -framework "AVFoundation" -framework "CoreAudio" -framework "CoreGraphics" -framework "CoreMedia" -framework "CoreVideo" -framework "Foundation" -framework "GLKit" -framework "ImageIO" -framework "MediaPlayer" -framework "UIKit" -framework "VideoToolbox" -framework "WebKit"
   SWIFT_VERSION = 5.0
   ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES
   SWIFT_INCLUDE_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/**" "${PODS_ROOT}/**"
   COMPILER_INDEX_STORE_ENABLE = NO
   DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
   ```

6. **WebRTC Import Düzenlemesi**

   WebRTC servisi içerisindeki import ifadesini modüler hale getirin:

   ```swift
   // WebRTC için modüler import
   #if SWIFT_PACKAGE
   import GoogleWebRTC
   #else
   @import GoogleWebRTC;
   #endif
   ```

7. **Xcode'un Türetilmiş Verilerini Temizleme**

   Bazen Xcode'un türetilmiş verilerini temizlemek sorunu çözebilir:

   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
   ```

8. **Rosetta 2 Kurulumu**

   M4 Mac'inizde Rosetta 2 kurulu değilse, şu komutu kullanarak kurabilirsiniz:

   ```bash
   softwareupdate --install-rosetta
   ```

## Derleme Adımları

1. Projeyi düzgün bir şekilde derlemek için şu adımları takip edin:

   a. Xcode'u kapatın
   b. Terminalde projenin kök dizinine gidin
   c. `./BugFix/alamofire_fix.sh` scriptini çalıştırın
   d. Xcode'u Rosetta ile açın: `arch -x86_64 open -a Xcode SesliIletisim.xcworkspace`
   e. Xcode içinde şu işlemleri yapın:
      - Product > Clean Build Folder (Shift+Command+K)
      - Product > Build (Command+B)

## Yardımcı Linkler

- [CocoaPods ve M1/M2/M3/M4 Mac Sorunları](https://github.com/CocoaPods/CocoaPods/issues/9907)
- [Apple Silicon Transition Guide](https://developer.apple.com/documentation/apple-silicon/porting-your-mac-app-to-apple-silicon)
- [Rosetta 2 Hakkında](https://support.apple.com/tr-tr/HT211861)

## İletişim

Projeyle ilgili herhangi bir sorun yaşarsanız veya yardıma ihtiyacınız olursa, lütfen ekip liderinizle iletişime geçin.

---

*Son Güncelleme: [Tarih: Her düzenleme yapıldığında güncellenir]* 