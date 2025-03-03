#!/bin/bash

# Xcode'u kapat
echo "Xcode kapatılıyor..."
killall Xcode 2>/dev/null

# Derived Data temizleme
echo "Derived Data temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Pod temizleme
echo "Pods temizleniyor..."
rm -rf Pods
rm -rf Podfile.lock
rm -rf SesliIletisim.xcworkspace

# Swift paket cache temizliği
echo "Swift paket önbelleği temizleniyor..."
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf ~/Library/Developer/Xcode/DerivedData/*-*

# CocoaPods önbellek temizliği
echo "CocoaPods önbelleği temizleniyor..."
pod cache clean --all

# Pod kurulumu
echo "Pod yeniden yükleniyor..."
pod install --repo-update

# Framework arama yollarını düzeltme
echo "Framework arama yollarını yapılandırma..."
cat > xcconfig/custom.xcconfig << 'EOT'
// Custom configuration settings for the project
IPHONEOS_DEPLOYMENT_TARGET = 13.0

// Framework Search Paths
FRAMEWORK_SEARCH_PATHS = $(inherited) "$(SRCROOT)/Pods/**" "$(PODS_ROOT)/**" "${PODS_ROOT}/GoogleWebRTC/Frameworks" "${PODS_XCFRAMEWORKS_BUILD_DIR}/**"

// Header Search Paths
HEADER_SEARCH_PATHS = $(inherited) "$(SRCROOT)/Pods/**" "${PODS_ROOT}/**" "${PODS_CONFIGURATION_BUILD_DIR}/**"

// Library Search Paths
LIBRARY_SEARCH_PATHS = $(inherited) "$(SRCROOT)/Pods/**" "${PODS_ROOT}/**" "${PODS_CONFIGURATION_BUILD_DIR}/**"

// Other Linker Flags
OTHER_LDFLAGS = $(inherited) -framework "Alamofire" -framework "GoogleWebRTC" -framework "KeychainAccess" -framework "SDWebImage" -framework "SocketIO" -framework "Starscream" -framework "Toast_Swift" -framework "AVFoundation" -framework "CoreFoundation" -framework "CoreMedia" -framework "Foundation" -framework "ImageIO" -framework "Security" -framework "UIKit"

// Swift Version
SWIFT_VERSION = 5.0

// Embedded Swift Standard Libraries
ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

// Modules
DEFINES_MODULE = YES
SWIFT_INSTALL_OBJC_HEADER = YES
CLANG_ENABLE_MODULES = YES
CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES

// Bitcode
ENABLE_BITCODE = NO

// Architectures for Simulator
EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
EXCLUDED_ARCHS[sdk=iphoneos*] = x86_64

// Swift Optimization Level
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_COMPILATION_MODE = wholemodule

// Uyarıları Bastırma Ayarları
GCC_WARN_INHIBIT_ALL_WARNINGS = NO
SWIFT_SUPPRESS_WARNINGS = NO
SWIFT_TREAT_WARNINGS_AS_ERRORS = NO
GCC_TREAT_WARNINGS_AS_ERRORS = NO

// Uyarıları Kabul Edilebilir Seviyeye İndirme
OTHER_SWIFT_FLAGS = $(inherited) -D COCOAPODS -suppress-warnings
GCC_WARN_UNUSED_VARIABLE = NO
GCC_WARN_UNUSED_FUNCTION = NO

// Framework Not Found Hatası için Çözüm
LD_RUNPATH_SEARCH_PATHS = $(inherited) '@executable_path/Frameworks' '@loader_path/Frameworks'

// FPS Optimizasyonu için Ayarlar
CLANG_OPTIMIZATION_PROFILE_FILE = ""
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
EOT

# Build temizliği
echo "Build temizleniyor..."
xcodebuild clean -workspace SesliIletisim.xcworkspace -scheme SesliIletisim -configuration Debug 2>/dev/null

echo "İşlem tamamlandı!"
echo "Şimdi Xcode'u açınız ve SesliIletisim.xcworkspace dosyasını açınız."
echo "Proje ayarlarında, her iki build konfigürasyonu için de custom.xcconfig dosyasını seçtiğinizden emin olunuz."
echo "Sonrasında Product -> Clean Build Folder yapınız ve projeyi derleyiniz."

# Xcode'u aç
open SesliIletisim.xcworkspace 