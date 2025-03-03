#!/bin/bash

# SesliIletisim - M4 Mac (Apple Silicon) Uyumluluk Scripti
# by Claude 3.7

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Renk yok

echo -e "${BLUE}=== M4 Mac Uyumluluk Scripti - SesliIletisim Projesi ===${NC}"
echo -e "${YELLOW}Bu script, M4 Mac (Apple Silicon) cihazlarda yaşanabilecek uyumluluk sorunlarını çözmek için tasarlanmıştır.${NC}"
echo ""

# Ana işlevler

check_rosetta() {
  echo -e "${YELLOW}Rosetta 2 durumu kontrol ediliyor...${NC}"
  
  if /usr/bin/pgrep -q oahd; then
    echo -e "${GREEN}[OK] Rosetta 2 zaten kurulu ve çalışıyor.${NC}"
    return 0
  else
    echo -e "${RED}[HATA] Rosetta 2 kurulu değil veya çalışmıyor.${NC}"
    echo -e "${YELLOW}Rosetta 2'yi kurmak için: ${GREEN}softwareupdate --install-rosetta${NC} komutunu çalıştırın.${NC}"
    return 1
  fi
}

fix_xcode_settings() {
  echo -e "${YELLOW}Xcode ayarları düzeltiliyor...${NC}"
  
  # Info.plist yolunu bulun
  XCODE_INFO_PLIST="/Applications/Xcode.app/Contents/Info.plist"
  
  if [ ! -f "$XCODE_INFO_PLIST" ]; then
    echo -e "${RED}[HATA] Xcode bulunamadı. Xcode'un kurulu olduğundan emin olun.${NC}"
    return 1
  fi
  
  # Rosetta'yı etkinleştirin
  echo -e "${YELLOW}Xcode için Rosetta'yı etkinleştirme tavsiye edilir. Bunu yapmak için:${NC}"
  echo -e "${GREEN}1. Finder'da Xcode'a sağ tıklayın ve 'Bilgi Al' seçeneğini seçin${NC}"
  echo -e "${GREEN}2. 'Rosetta ile Aç' seçeneğini işaretleyin${NC}"
  echo -e "${GREEN}[İPUCU] Veya terminalde: arch -x86_64 open -a Xcode SesliIletisim.xcworkspace${NC}"
  echo ""
  
  return 0
}

clean_derived_data() {
  echo -e "${YELLOW}Türetilmiş veriler temizleniyor...${NC}"
  
  rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Türetilmiş veriler başarıyla temizlendi.${NC}"
    return 0
  else
    echo -e "${RED}[HATA] Türetilmiş veriler temizlenirken bir sorun oluştu.${NC}"
    return 1
  fi
}

fix_pod_architecture() {
  echo -e "${YELLOW}Pod mimarisi düzeltiliyor...${NC}"
  
  # Podfile'ın varlığını kontrol et
  if [ ! -f "Podfile" ]; then
    echo -e "${RED}[HATA] Podfile bulunamadı. Proje kök dizininde olduğunuzdan emin olun.${NC}"
    return 1
  fi
  
  # Pods dizininin varlığını kontrol et
  if [ ! -d "Pods" ]; then
    echo -e "${YELLOW}[BİLGİ] Pods klasörü bulunamadı. Pod'lar yeniden yüklenecek.${NC}"
  fi
  
  # Podfile'ı yedekle
  cp Podfile Podfile.bak
  echo -e "${GREEN}[OK] Podfile yedeklendi: Podfile.bak${NC}"
  
  # Pod'ları mimari ile yeniden yükle
  echo -e "${YELLOW}Pod'lar x86_64 mimarisi ile yeniden yükleniyor...${NC}"
  arch -x86_64 pod deintegrate
  arch -x86_64 pod install
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] Pod'lar başarıyla yeniden yüklendi.${NC}"
    return 0
  else
    echo -e "${RED}[HATA] Pod'lar yüklenirken bir sorun oluştu. Lütfen hata mesajlarını kontrol edin.${NC}"
    return 1
  fi
}

update_xcconfig() {
  # x86_64 mimariyi destekleyen yapılandırma
  echo -e "${YELLOW}XCConfig dosyası güncelleniyor...${NC}"
  
  XCCONFIG_PATH="xcconfig/custom.xcconfig"
  
  # xcconfig dizininin varlığını kontrol et
  if [ ! -d "xcconfig" ]; then
    mkdir -p xcconfig
    echo -e "${YELLOW}[BİLGİ] 'xcconfig' dizini oluşturuldu.${NC}"
  fi
  
  # Eğer custom.xcconfig dosyası varsa, yedekle
  if [ -f "$XCCONFIG_PATH" ]; then
    cp "$XCCONFIG_PATH" "${XCCONFIG_PATH}.bak"
    echo -e "${GREEN}[OK] Mevcut XCConfig dosyası yedeklendi.${NC}"
  fi
  
  # Yeni xcconfig dosyası oluştur
  cat > "$XCCONFIG_PATH" << EOL
// M4 Mac uyumluluk için güncellendi - $(date)
FRAMEWORK_SEARCH_PATHS = \$(inherited) "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${PODS_ROOT}/GoogleWebRTC/Frameworks" "\${PODS_ROOT}/**" "\${PODS_XCFRAMEWORKS_BUILD_DIR}/**"
HEADER_SEARCH_PATHS = \$(inherited) "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${PODS_ROOT}/**"
LIBRARY_SEARCH_PATHS = \$(inherited) "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${PODS_ROOT}/**" "\${DT_TOOLCHAIN_DIR}/usr/lib/swift/\${PLATFORM_NAME}" /usr/lib/swift
ENABLE_BITCODE = NO
VALID_ARCHS = arm64 x86_64
EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
EXCLUDED_ARCHS[sdk=iphoneos*] = x86_64
OTHER_LDFLAGS = \$(inherited) -ObjC -l"Alamofire" -l"GoogleWebRTC" -l"KeychainAccess" -l"SDWebImage" -l"SocketIO" -l"Starscream" -l"Toast_Swift" -l"c++" -l"icucore" -l"sqlite3" -l"z" -framework "AVFoundation" -framework "CoreAudio" -framework "CoreGraphics" -framework "CoreMedia" -framework "CoreVideo" -framework "Foundation" -framework "GLKit" -framework "ImageIO" -framework "MediaPlayer" -framework "UIKit" -framework "VideoToolbox" -framework "WebKit"
SWIFT_VERSION = 5.0
ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES
SWIFT_INCLUDE_PATHS = \$(inherited) "\${PODS_CONFIGURATION_BUILD_DIR}/**" "\${PODS_ROOT}/**"
COMPILER_INDEX_STORE_ENABLE = NO
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
EOL
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK] XCConfig dosyası başarıyla güncellendi.${NC}"
    return 0
  else
    echo -e "${RED}[HATA] XCConfig dosyası güncellenirken bir sorun oluştu.${NC}"
    return 1
  fi
}

# Ana işlev
main() {
  echo -e "${BLUE}M4 Mac uyumluluk kontrolleri başlıyor...${NC}"
  
  # İşlem adımlarını çalıştır
  check_rosetta
  fix_xcode_settings
  clean_derived_data
  update_xcconfig
  fix_pod_architecture
  
  echo -e "${BLUE}=== Uyumluluk işlemleri tamamlandı ===${NC}"
  echo -e "${YELLOW}Xcode'u şu şekilde başlatmanızı öneririz:${NC}"
  echo -e "${GREEN}arch -x86_64 open -a Xcode SesliIletisim.xcworkspace${NC}"
  echo ""
  echo -e "${YELLOW}Yardımcı bilgiler: ${NC}"
  echo -e "${GREEN}1. Pod'ları daima 'arch -x86_64 pod install' komutu ile yükleyin${NC}"
  echo -e "${GREEN}2. Ayrıca Alamofire özel düzeltmesi için './BugFix/alamofire_fix.sh' scriptini de çalıştırabilirsiniz${NC}"
  echo -e "${GREEN}3. Daha fazla bilgi için SORUN_GIDERME.md dosyasına bakın${NC}"
  
  return 0
}

# Scripti çalıştır
main 