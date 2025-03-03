#!/bin/bash

echo "SesliIletisim için derleme işlemi başlatılıyor..."

# Xcode'u kapatın
echo "Xcode kapatılıyor..."
pkill -9 Xcode

# Derived Data temizleniyor
echo "Derived Data temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim*
rm -rf ~/Library/Developer/Xcode/DerivedData/Pods*

# Podları temizliyoruz
echo "Podlar temizleniyor..."
arch -x86_64 pod deintegrate
rm -rf Pods
rm -f Podfile.lock
rm -rf SesliIletisim.xcworkspace

# xcconfig dosyasını güncelleyelim
mkdir -p xcconfig
cat > xcconfig/custom.xcconfig << 'EOF'
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
EOF

echo "xcconfig dosyası güncellendi"

# Pod'ları kurun
echo "Podlar kuruluyor..."
arch -x86_64 pod install

# Xcode projesi için ayarları ekliyoruz
echo "Proje ayarları yapılandırılıyor..."
echo "NOT: Xcode açıldığında şunları yapın:"
echo "1. Build Settings > Apple Clang - Language > Modules > Allow Non-modular Includes in Framework Modules = YES yapın"
echo "2. Build Settings > Architectures > Excluded Architectures (Any iOS Simulator SDK) = arm64 yapın"
echo "3. Build Settings > Signing & Capabilities > Enable Bitcode = NO yapın"
echo "4. Build Settings > Deployment > iOS Deployment Target = 13.0 yapın"

# Xcode'u açın
echo "Xcode açılıyor..."
arch -x86_64 open -a Xcode SesliIletisim.xcworkspace

echo "İşlem tamamlandı!" 