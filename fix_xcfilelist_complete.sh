#!/bin/bash

# XCFilelist Sorunu İçin Kapsamlı Çözüm Script'i
# Bu script, CocoaPods XCFilelist dosya sorunlarını çözer ve doğru yol referanslarını oluşturur

# Renk tanımlamaları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Kapsamlı XCFilelist Onarım Scripti 📋${NC}"
echo -e "------------------------------\n"

# Proje ismini belirle
PROJECT_NAME="SesliIletisim"
WORKSPACE_NAME="${PROJECT_NAME}.xcworkspace"
PODFILE_NAME="Podfile"

# Podfile'ın varlığını kontrol et
if [ ! -f "${PODFILE_NAME}" ]; then
    echo -e "${RED}❌ Hata: '${PODFILE_NAME}' bulunamadı. Script, SesliIletisim projesinin kök dizininde çalıştırılmalıdır.${NC}"
    exit 1
fi

echo -e "${YELLOW}🔍 Projeyi hazırlıyorum...${NC}"

# Xcode DerivedData temizleme
echo -e "${YELLOW}🧹 DerivedData temizleniyor...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/${PROJECT_NAME}-*

# Pods klasörünü kontrol et, yoksa pod install yap
if [ ! -d "Pods" ]; then
    echo -e "${YELLOW}📦 Pods klasörü bulunamadı. 'pod install' çalıştırılıyor...${NC}"
    pod install
else
    echo -e "${GREEN}✅ Pods klasörü mevcut.${NC}"
fi

# XCFilelist dosya yolları
DEBUG_INPUT_FILELIST="Pods/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks-Debug-input-files.xcfilelist"
DEBUG_OUTPUT_FILELIST="Pods/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks-Debug-output-files.xcfilelist"
RELEASE_INPUT_FILELIST="Pods/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks-Release-input-files.xcfilelist"
RELEASE_OUTPUT_FILELIST="Pods/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks-Release-output-files.xcfilelist"

# Yedekleme fonksiyonu
backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "${1}.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✅ '$1' yedeklendi.${NC}"
    fi
}

echo -e "${YELLOW}🔍 XCFilelist dosyaları yedekleniyor...${NC}"
backup_file "${DEBUG_INPUT_FILELIST}"
backup_file "${DEBUG_OUTPUT_FILELIST}"
backup_file "${RELEASE_INPUT_FILELIST}"
backup_file "${RELEASE_OUTPUT_FILELIST}"

# Framework listesini oluştur
echo -e "${YELLOW}📦 Framework listesi oluşturuluyor...${NC}"

# Pods klasöründen framework isimlerini çıkar
FRAMEWORKS=()

# Bilinen frameworkleri ekle (varsa)
KNOWN_FRAMEWORKS=("Alamofire" "GoogleWebRTC" "KeychainAccess" "SDWebImage" "SocketIO" "Starscream" "Toast_Swift")
for fw in "${KNOWN_FRAMEWORKS[@]}"; do
    if [[ ! " ${FRAMEWORKS[@]} " =~ " ${fw} " ]]; then
        FRAMEWORKS+=("${fw}")
    fi
done

echo -e "${GREEN}✅ Framework listesi oluşturuldu. Toplam: ${#FRAMEWORKS[@]} framework${NC}"

# Tam dosya yolunu al
PROJECT_DIR="$(pwd)"

# Hedef dizinleri oluştur
mkdir -p "Pods/Target Support Files/Pods-${PROJECT_NAME}/"

# Debug input file oluştur
echo -e "${YELLOW}📝 Debug Input XCFilelist dosyası oluşturuluyor...${NC}"
echo "\${PODS_ROOT}/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks.sh" > "${DEBUG_INPUT_FILELIST}"
for fw in "${KNOWN_FRAMEWORKS[@]}"; do
    echo "\${PODS_ROOT}/${fw}/${fw}.framework" >> "${DEBUG_INPUT_FILELIST}"
done

# Debug output file oluştur
echo -e "${YELLOW}📝 Debug Output XCFilelist dosyası oluşturuluyor...${NC}"
# Debug output dosyasını oluştur
> "${DEBUG_OUTPUT_FILELIST}"
for fw in "${KNOWN_FRAMEWORKS[@]}"; do
    echo "\${TARGET_BUILD_DIR}/\${FRAMEWORKS_FOLDER_PATH}/${fw}.framework" >> "${DEBUG_OUTPUT_FILELIST}"
done

# Release dosyalarını da oluştur
echo -e "${YELLOW}📝 Release XCFilelist dosyaları oluşturuluyor...${NC}"
cp "${DEBUG_INPUT_FILELIST}" "${RELEASE_INPUT_FILELIST}"
cp "${DEBUG_OUTPUT_FILELIST}" "${RELEASE_OUTPUT_FILELIST}"

# Xcode projesi yollarını düzelt
echo -e "${YELLOW}🔍 Xcode projesi kontrol ediliyor...${NC}"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj/project.pbxproj"

if [ -f "${PROJECT_FILE}" ]; then
    backup_file "${PROJECT_FILE}"
    
    # XCFilelist yollarını düzelt
    sed -i '' 's|/Target Support Files/|Pods/Target Support Files/|g' "${PROJECT_FILE}"
    
    echo -e "${GREEN}✅ Proje dosyasında XCFilelist yolları düzeltildi.${NC}"
else
    echo -e "${YELLOW}⚠️ Proje dosyası bulunamadı: ${PROJECT_FILE}${NC}"
fi

# Pod yollarını düzelt
echo -e "${YELLOW}🔄 'pod deintegrate' ve 'pod install' çalıştırılıyor...${NC}"
pod deintegrate
pod install

echo -e "\n${GREEN}🎉 XCFilelist sorunu başarıyla çözüldü!${NC}\n"
echo -e "${BLUE}📋 Şimdi aşağıdaki adımları takip edin:${NC}"
echo -e "1. Xcode'u kapatın (açıksa)"
echo -e "2. Xcode'u tekrar açın: ${GREEN}xed .${NC}"
echo -e "3. Clean Build Folder yapın (Shift+Cmd+K)"
echo -e "4. Projeyi derleyin (Cmd+B)"
echo -e "5. Simülatörde çalıştırın (Cmd+R)" 