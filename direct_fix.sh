#!/bin/bash

# XCFilelist Sorununu Doğrudan Düzeltme Scripti

# Renk tanımlamaları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Doğrudan XCFilelist Onarım Scripti 📋${NC}"
echo -e "------------------------------\n"

# Proje ismini belirle
PROJECT_NAME="SesliIletisim"
WORKSPACE_NAME="${PROJECT_NAME}.xcworkspace"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj/project.pbxproj"

# Xcode'u kapatın
echo -e "${YELLOW}🔍 Açık olan Xcode uygulamalarını kapatıyorum...${NC}"
killall Xcode 2>/dev/null || true

# DerivedData temizleme
echo -e "${YELLOW}🧹 DerivedData temizleniyor...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/${PROJECT_NAME}-*

# Belirli bilinen Framework'ler
FRAMEWORKS=("Alamofire" "GoogleWebRTC" "KeychainAccess" "SDWebImage" "SocketIO" "Starscream" "Toast_Swift")

# Proje dosyasında değişiklik yapma
if [ -f "${PROJECT_FILE}" ]; then
    echo -e "${YELLOW}🔍 Proje dosyasında değişiklik yapılıyor...${NC}"
    cp "${PROJECT_FILE}" "${PROJECT_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
    
    # Pods sekmesinde "Embed Pods Frameworks" adımını bul
    # Ve Input Files/Output Files bölümlerini kaldır
    # Bu adımda file list'leri kullanmak yerine script'in her zaman çalışmasını sağlayacağız
    
    # sed komutu ile inputFileListPaths ve outputFileListPaths bölümlerini kaldır
    # ve onların yerine boş inputPaths ve outputPaths koy
    
    # Önce input ve output file listlerini temizle
    sed -i '' 's/inputFileListPaths = (/inputPaths = (/g' "${PROJECT_FILE}"
    sed -i '' 's/outputFileListPaths = (/outputPaths = (/g' "${PROJECT_FILE}"
    
    # Ardından file list içeriklerini temizle
    sed -i '' 's/"${PODS_ROOT}\/Target Support Files\/Pods-SesliIletisim\/Pods-SesliIletisim-frameworks-${CONFIGURATION}-input-files.xcfilelist",//g' "${PROJECT_FILE}"
    sed -i '' 's/"${PODS_ROOT}\/Target Support Files\/Pods-SesliIletisim\/Pods-SesliIletisim-frameworks-${CONFIGURATION}-output-files.xcfilelist",//g' "${PROJECT_FILE}"
    
    echo -e "${GREEN}✅ Proje dosyası düzenlendi.${NC}"
else
    echo -e "${RED}❌ Proje dosyası bulunamadı!${NC}"
    exit 1
fi

# Görünüşe göre CocoaPods'un yönettiği build fazlarında bir sorun var.
# Pods'u deintegre edip yeniden yükleyelim:
echo -e "${YELLOW}🔄 CocoaPods'u deintegre edip yeniden yüklüyorum...${NC}"
pod deintegrate
pod install

echo -e "\n${GREEN}🎉 Doğrudan düzeltme tamamlandı!${NC}\n"
echo -e "${BLUE}📋 Şimdi aşağıdaki adımları takip edin:${NC}"
echo -e "1. Xcode'u açın: ${GREEN}xed .${NC}"
echo -e "2. Xcode tercihleri değiştirmeyi onaylayan bir uyarıyla karşılaşırsanız 'Cancel' düğmesine tıklayın"
echo -e "3. Clean Build Folder yapın (Shift+Cmd+K)"
echo -e "4. Projeyi derleyin (Cmd+B)"
echo -e "5. Sorun devam ederse, derleme fazındaki 'Based on dependency analysis' kutusunun işaretini kaldırın:"
echo -e "   - Project > Build Phases > [CP] Embed Pods Frameworks > Based on dependency analysis işaretini kaldırın" 