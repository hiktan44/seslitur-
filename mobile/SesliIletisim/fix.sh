#!/bin/bash

# SesliIletisim - Sorun Giderme Scripti
# by Claude 3.7

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Renk yok

echo -e "${BLUE}=== SesliIletisim Uyumluluk ve Sorun Giderme Scripti ===${NC}"
echo -e "${YELLOW}Bu script, SesliIletisim projesinin derleme sorunlarını otomatik olarak çözmeye yardımcı olur.${NC}"
echo ""

# Script dosyalarını çalıştırılabilir hale getir
chmod +x BugFix/alamofire_fix.sh
chmod +x BugFix/m4_mac_fix.sh

# Apple Silicon (M1/M2/M3/M4) tespiti
if [[ $(uname -m) == 'arm64' ]]; then
    echo -e "${YELLOW}Apple Silicon (M1/M2/M3/M4) Mac tespit edildi.${NC}"
    
    # Rosetta kontrol et
    if /usr/bin/pgrep -q oahd; then
        echo -e "${GREEN}[OK] Rosetta 2 kurulu ve çalışıyor.${NC}"
    else
        echo -e "${RED}[UYARI] Rosetta 2 kurulu değil veya çalışmıyor.${NC}"
        echo -e "${YELLOW}Rosetta 2'yi kurmak istiyor musunuz? (E/H)${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Ee]$ ]]; then
            softwareupdate --install-rosetta
        else
            echo -e "${YELLOW}Rosetta kurulmadan devam ediliyor...${NC}"
        fi
    fi
    
    echo -e "${YELLOW}M4 Mac uyumluluk scripti çalıştırılıyor...${NC}"
    ./BugFix/m4_mac_fix.sh
    
    echo -e "${YELLOW}Alamofire düzeltme scripti çalıştırılıyor...${NC}"
    ./BugFix/alamofire_fix.sh
else
    echo -e "${YELLOW}Intel Mac tespit edildi. Alamofire düzeltme scripti çalıştırılıyor...${NC}"
    ./BugFix/alamofire_fix.sh
fi

echo -e "${BLUE}=== Sorun giderme tamamlandı ===${NC}"
echo -e "${YELLOW}Xcode'u başlatmak için:${NC}"
echo -e "${GREEN}open SesliIletisim.xcworkspace${NC}"

if [[ $(uname -m) == 'arm64' ]]; then
    echo -e "${YELLOW}M4 Mac için Rosetta ile başlatmak için:${NC}"
    echo -e "${GREEN}arch -x86_64 open -a Xcode SesliIletisim.xcworkspace${NC}"
fi

echo ""
echo -e "${YELLOW}Daha fazla bilgi için SORUN_GIDERME.md dosyasına bakabilirsiniz.${NC}" 