#!/bin/bash

# SesliIletisim Derleme ve Sorun Giderme Yardımcısı
# by Claude 3.7

# Dizini script dosyasının bulunduğu yere ayarla
cd "$(dirname "$0")"

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Renk yok

clear
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}= SesliIletisim Derleme Yardımcısı =${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Otomatik çalıştırma izni ver
chmod +x fix.sh
chmod +x BugFix/alamofire_fix.sh
chmod +x BugFix/m4_mac_fix.sh

# Menü seçenekleri
while true; do
    echo -e "${YELLOW}Lütfen bir işlem seçin:${NC}"
    echo ""
    echo -e "${GREEN}1)${NC} Tüm sorun giderme adımlarını otomatik çalıştır"
    echo -e "${GREEN}2)${NC} Sadece Alamofire düzeltmesi uygula"
    echo -e "${GREEN}3)${NC} Sadece M4 Mac düzeltmesi uygula"
    echo -e "${GREEN}4)${NC} Xcode'u Rosetta ile başlat"
    echo -e "${GREEN}5)${NC} Xcode'u normal başlat"
    echo -e "${GREEN}6)${NC} Sorun giderme talimatlarını göster"
    echo -e "${GREEN}7)${NC} Çıkış"
    echo ""
    echo -n -e "${YELLOW}Seçiminiz (1-7): ${NC}"
    read -r choice
    
    case $choice in
        1)
            echo -e "${BLUE}Tüm sorun giderme adımları çalıştırılıyor...${NC}"
            ./fix.sh
            echo -e "${GREEN}[OK] Tamamlandı.${NC}"
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
        2)
            echo -e "${BLUE}Alamofire düzeltmesi uygulanıyor...${NC}"
            ./BugFix/alamofire_fix.sh
            echo -e "${GREEN}[OK] Tamamlandı.${NC}"
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
        3)
            echo -e "${BLUE}M4 Mac düzeltmesi uygulanıyor...${NC}"
            ./BugFix/m4_mac_fix.sh
            echo -e "${GREEN}[OK] Tamamlandı.${NC}"
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
        4)
            echo -e "${BLUE}Xcode Rosetta ile başlatılıyor...${NC}"
            arch -x86_64 open -a Xcode SesliIletisim.xcworkspace
            echo -e "${GREEN}[OK] Xcode başlatıldı.${NC}"
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
        5)
            echo -e "${BLUE}Xcode normal başlatılıyor...${NC}"
            open SesliIletisim.xcworkspace
            echo -e "${GREEN}[OK] Xcode başlatıldı.${NC}"
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
        6)
            echo -e "${BLUE}Sorun giderme talimatları gösteriliyor...${NC}"
            if [ -f "SORUN_GIDERME.md" ]; then
                cat SORUN_GIDERME.md
            else
                echo -e "${RED}[HATA] SORUN_GIDERME.md dosyası bulunamadı.${NC}"
            fi
            echo ""
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
        7)
            echo -e "${BLUE}Çıkış yapılıyor...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[HATA] Geçersiz seçim! Lütfen 1-7 arasında bir değer girin.${NC}"
            echo -e "${YELLOW}Devam etmek için Enter tuşuna basın...${NC}"
            read
            clear
            ;;
    esac
done 