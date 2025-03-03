#!/bin/bash

# Terminate on error
set -e

echo "📦 Framework Binary Fix Script 📦"
echo "--------------------------------"

# 1. Kapatma İşlemleri
echo "🔄 Xcode oturumlarını kapatıyorum..."
killall Xcode 2>/dev/null || true
killall -9 Xcode 2>/dev/null || true

# 2. Temizlik İşlemleri
echo "🧹 Derived Data ve caches temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/CocoaPods/*
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*

# 3. Pod Temizliği
echo "🧹 Pod dosyalarını temizliyorum..."
rm -rf Pods
rm -rf Podfile.lock
pod deintegrate

# 4. Proje Temizliği
echo "🧹 Proje build dosyalarını temizliyorum..."
xcodebuild clean -workspace SesliIletisim.xcworkspace -scheme SesliIletisim 2>/dev/null || true

# 5. Podları Yeniden Kurma
echo "📥 Podları yeniden kuruyorum..."
pod install --repo-update

# 6. Framework Binary Fix
echo "🔧 Framework binary düzeltmelerini uyguluyorum..."

# 6.1 Pods_SesliIletisim.framework klasörünü doğrudan oluştur
mkdir -p "${PODS_ROOT}/Pods_SesliIletisim.framework" 2>/dev/null || true

# 6.2 Xcconfig Düzeltmesi
echo "📝 Xcconfig dosyasını güncelliyorum..."
cat > custom.xcconfig << EOL
// Custom configuration settings for the project
IPHONEOS_DEPLOYMENT_TARGET = 13.0

// Framework Search Paths - expanded and more specific
FRAMEWORK_SEARCH_PATHS = \$(inherited) "\$(SRCROOT)/Pods/**" "\$(PODS_ROOT)/**" "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${PODS_ROOT}/GoogleWebRTC/Frameworks/frameworks" "\${PODS_XCFRAMEWORKS_BUILD_DIR}/**" "\${PODS_CONFIGURATION_BUILD_DIR}"

// Header Search Paths - expanded
HEADER_SEARCH_PATHS = \$(inherited) "\$(SRCROOT)/Pods/**" "\${PODS_ROOT}/**" "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${PODS_ROOT}/Headers/Public/**"

// Library Search Paths
LIBRARY_SEARCH_PATHS = \$(inherited) "\$(SRCROOT)/Pods/**" "\${PODS_ROOT}/**" "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${TOOLCHAIN_DIR}/usr/lib/swift/\${PLATFORM_NAME}" /usr/lib/swift

// Other Linker Flags
OTHER_LDFLAGS = \$(inherited) -framework "Alamofire" -framework "CFNetwork" -framework "Foundation" -framework "ImageIO" -framework "KeychainAccess" -framework "QuartzCore" -framework "SDWebImage" -framework "SocketIO" -framework "Starscream" -framework "Toast_Swift" -framework "WebRTC" -ObjC -all_load

// Swift Version
SWIFT_VERSION = 5.0

// Embedded Swift Standard Libraries - YES to ensure Swift standard libraries are embedded
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

// Run Path Search Paths
LD_RUNPATH_SEARCH_PATHS = \$(inherited) /usr/lib/swift @executable_path/Frameworks @loader_path/Frameworks

// Other Framework Specific settings
CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO
SWIFT_SUPPRESS_WARNINGS = NO
VALIDATE_PRODUCT = NO
COPY_PHASE_STRIP = NO

// Code Signing
CODE_SIGN_IDENTITY = 
CODE_SIGNING_REQUIRED = NO
CODE_SIGN_STYLE = Automatic
EOL

# 7. Son Temizlik
echo "🧹 Son temizliği yapıyorum..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean -workspace SesliIletisim.xcworkspace -scheme SesliIletisim 2>/dev/null || true

# 8. Proje Açılıyor
echo "🚀 Xcode'u açıyorum..."
open SesliIletisim.xcworkspace

echo -e "\n✅ İşlem tamamlandı! Şimdi şunları yapın:"
echo "1. Xcode'da her iki konfigürasyon için custom.xcconfig seçildiğinden emin olun (Project Settings > Info)."
echo "2. Product > Clean Build Folder yapın."
echo "3. Projeyi derleyin."
echo "4. Sorun devam ederse, hata mesajlarını kontrol edin ve manual olarak düzeltin." 