#!/bin/bash

# M4 Mac'lerde Alamofire Framework bağlantı sorunlarını düzeltmek için script
# by Claude 3.7

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Renk yok

echo -e "${BLUE}=== Alamofire Düzeltme Scripti - M4 Mac için ===${NC}"
echo -e "${YELLOW}Bu script, M4 Mac'lerde Rosetta 2 altında çalışırken Alamofire entegrasyonu sorunlarını düzeltmeye yardımcı olur.${NC}"
echo ""

# Pod Kurulumunu Kontrol Et
if [ ! -d "Pods" ]; then
    echo -e "${RED}[HATA] Pods klasörü bulunamadı. Proje kök dizininde olduğunuzdan emin olun.${NC}"
    exit 1
fi

# Alamofire modülünün varlığını kontrol et
if [ ! -d "Pods/Alamofire" ]; then
    echo -e "${RED}[HATA] Alamofire pod'u bulunamadı. Lütfen önce 'pod install' çalıştırın.${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Alamofire pod'u tespit edildi.${NC}"

# Mevcut xcconfig dosyasını kontrol et
XCCONFIG_PATH="xcconfig/custom.xcconfig"
if [ ! -f "$XCCONFIG_PATH" ]; then
    echo -e "${YELLOW}[UYARI] custom.xcconfig dosyası bulunamadı. Yeni oluşturuluyor...${NC}"
    mkdir -p xcconfig
    touch "$XCCONFIG_PATH"
else
    echo -e "${GREEN}[OK] custom.xcconfig dosyası tespit edildi.${NC}"
    # Mevcut ayarları yedekle
    cp "$XCCONFIG_PATH" "${XCCONFIG_PATH}.backup"
    echo -e "${GREEN}[OK] Mevcut xcconfig dosyası ${XCCONFIG_PATH}.backup olarak yedeklendi.${NC}"
fi

# Framework arama yollarını güncelle
echo "// Alamofire fix için güncellendi - $(date)" > "$XCCONFIG_PATH"
echo "ENABLE_BITCODE = NO" >> "$XCCONFIG_PATH"
echo "VALID_ARCHS = arm64 x86_64" >> "$XCCONFIG_PATH"
echo "EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64" >> "$XCCONFIG_PATH"
echo "EXCLUDED_ARCHS[sdk=iphoneos*] = x86_64" >> "$XCCONFIG_PATH"
echo "FRAMEWORK_SEARCH_PATHS = \$(inherited) \"\${PODS_CONFIGURATION_BUILD_DIR}/**\" \"\${PODS_ROOT}/GoogleWebRTC/Frameworks\" \"\${PODS_ROOT}/**\" \"\${PODS_XCFRAMEWORKS_BUILD_DIR}/**\"" >> "$XCCONFIG_PATH"
echo "HEADER_SEARCH_PATHS = \$(inherited) \"\${PODS_CONFIGURATION_BUILD_DIR}/**\" \"\${PODS_ROOT}/**\"" >> "$XCCONFIG_PATH"
echo "LIBRARY_SEARCH_PATHS = \$(inherited) \"\${PODS_CONFIGURATION_BUILD_DIR}/**\" \"\${PODS_ROOT}/**\" \"\${DT_TOOLCHAIN_DIR}/usr/lib/swift/\${PLATFORM_NAME}\" /usr/lib/swift" >> "$XCCONFIG_PATH"
echo "OTHER_LDFLAGS = \$(inherited) -ObjC -l\"Alamofire\" -l\"GoogleWebRTC\" -l\"KeychainAccess\" -l\"SDWebImage\" -l\"SocketIO\" -l\"Starscream\" -l\"Toast_Swift\" -l\"c++\" -l\"icucore\" -l\"sqlite3\" -l\"z\" -framework \"AVFoundation\" -framework \"CoreAudio\" -framework \"CoreGraphics\" -framework \"CoreMedia\" -framework \"CoreVideo\" -framework \"Foundation\" -framework \"GLKit\" -framework \"ImageIO\" -framework \"MediaPlayer\" -framework \"UIKit\" -framework \"VideoToolbox\" -framework \"WebKit\"" >> "$XCCONFIG_PATH"
echo "SWIFT_VERSION = 5.0" >> "$XCCONFIG_PATH"
echo "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES" >> "$XCCONFIG_PATH"
echo "SWIFT_INCLUDE_PATHS = \$(inherited) \"\${PODS_CONFIGURATION_BUILD_DIR}/**\" \"\${PODS_ROOT}/**\"" >> "$XCCONFIG_PATH"
echo "COMPILER_INDEX_STORE_ENABLE = NO" >> "$XCCONFIG_PATH"
echo "DEBUG_INFORMATION_FORMAT = dwarf-with-dsym" >> "$XCCONFIG_PATH"

echo -e "${GREEN}[OK] custom.xcconfig dosyası güncellendi.${NC}"

# Podfile'ı güncelle
PODFILE="Podfile"
if [ ! -f "$PODFILE" ]; then
    echo -e "${RED}[HATA] Podfile bulunamadı.${NC}"
    exit 1
fi

# Podfile'ı yedekle
cp "$PODFILE" "${PODFILE}.backup"
echo -e "${GREEN}[OK] Mevcut Podfile ${PODFILE}.backup olarak yedeklendi.${NC}"

# Podfile'ı güncelle
cat > "$PODFILE" << EOL
# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

# use_frameworks!
use_modular_headers!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      
      # Framework arama yollarını ekleyelim
      config.build_settings['FRAMEWORK_SEARCH_PATHS'] = [
        "\$(inherited)",
        "\"\${PODS_ROOT}/GoogleWebRTC/Frameworks\"",
        "\"\${PODS_ROOT}/**\"",
        "\"\${PODS_XCFRAMEWORKS_BUILD_DIR}/**\""
      ]
      
      # Library arama yollarını ekleyelim
      config.build_settings['LIBRARY_SEARCH_PATHS'] = [
        "\$(inherited)",
        "\"\${PODS_ROOT}/**\"",
        "\"\${PODS_CONFIGURATION_BUILD_DIR}/**\""
      ]
      
      # Swift modül yollarını ekleyelim
      config.build_settings['SWIFT_INCLUDE_PATHS'] = [
        "\$(inherited)",
        "\"\${PODS_CONFIGURATION_BUILD_DIR}/**\"",
        "\"\${PODS_ROOT}/**\""
      ]
    end
  end
end

target 'SesliIletisim' do
  # Comment the next line if you don't want to use dynamic frameworks
  pod 'Alamofire', '5.5.0'
  pod 'GoogleWebRTC', '1.1.32000'
  pod 'KeychainAccess', '4.2.2'
  pod 'SDWebImage', '5.12.5'
  pod 'Socket.IO-Client-Swift', '16.1.0'
  pod 'Starscream', '4.0.8'
  pod 'Toast-Swift', '5.0.1'
end
EOL

echo -e "${GREEN}[OK] Podfile güncellendi.${NC}"

# Temizlik ve yeniden kurulum
echo -e "${BLUE}Pod'ları temizleyip yeniden kuruyorum...${NC}"
echo -e "${YELLOW}Bu işlem birkaç dakika sürebilir...${NC}"

arch -x86_64 pod deintegrate
arch -x86_64 pod install

echo -e "${GREEN}[OK] Pod'lar başarıyla yeniden kuruldu.${NC}"
echo -e "${BLUE}=== İşlem tamamlandı ===${NC}"
echo -e "${YELLOW}Lütfen şimdi Xcode'u kapatıp yeniden açın ve aşağıdaki komutu kullanarak Xcode'u Rosetta altında başlatın:${NC}"
echo -e "${GREEN}arch -x86_64 open -a Xcode SesliIletisim.xcworkspace${NC}"
echo ""
echo -e "${YELLOW}İyi şanslar!${NC}" 