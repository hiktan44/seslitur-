#!/bin/bash

# XCFilelist Sorunu Çözüm Scripti
# Bu script, "Unable to load contents of file list" hatasını çözmek için tasarlanmıştır

# Çalışma dizinini kontrol et
if [ ! -f "Podfile" ]; then
    echo "❌ Lütfen bu scripti SesliIletisim klasöründe çalıştırın."
    exit 1
fi

echo "📋 XCFilelist Onarım Scripti 📋"
echo "------------------------------"
echo ""

# Pods dizinini kontrol et
if [ ! -d "Pods" ]; then
    echo "❌ Pods dizini bulunamadı. Lütfen 'pod install' komutunu çalıştırın."
    exit 1
fi

# XCFilelist yolları
TARGET_SUPPORT_FILES="Pods/Target Support Files/Pods-SesliIletisim"
INPUT_FILES_DEBUG="${TARGET_SUPPORT_FILES}/Pods-SesliIletisim-frameworks-Debug-input-files.xcfilelist"
OUTPUT_FILES_DEBUG="${TARGET_SUPPORT_FILES}/Pods-SesliIletisim-frameworks-Debug-output-files.xcfilelist"
INPUT_FILES_RELEASE="${TARGET_SUPPORT_FILES}/Pods-SesliIletisim-frameworks-Release-input-files.xcfilelist"
OUTPUT_FILES_RELEASE="${TARGET_SUPPORT_FILES}/Pods-SesliIletisim-frameworks-Release-output-files.xcfilelist"

# Dizini oluştur (eğer yoksa)
mkdir -p "${TARGET_SUPPORT_FILES}"

# XCFilelist'leri yedekle (eğer varsa)
backup_xcfilelist() {
    if [ -f "$1" ]; then
        cp -f "$1" "$1.backup"
        echo "✅ $1 yedeklendi."
    fi
}

echo "🔍 XCFilelist dosyaları kontrol ediliyor..."

backup_xcfilelist "${INPUT_FILES_DEBUG}"
backup_xcfilelist "${OUTPUT_FILES_DEBUG}"
backup_xcfilelist "${INPUT_FILES_RELEASE}"
backup_xcfilelist "${OUTPUT_FILES_RELEASE}"

# Framework listesini al
echo "📦 Framework listesi oluşturuluyor..."
FRAMEWORKS=()

# Pod'ları Framework klasöründen al
PODS_FRAMEWORKS_DIR="Pods/Frameworks"
if [ -d "${PODS_FRAMEWORKS_DIR}" ]; then
    for framework in "${PODS_FRAMEWORKS_DIR}"/*.framework; do
        if [ -d "$framework" ]; then
            FRAMEWORK_NAME=$(basename "$framework" .framework)
            FRAMEWORKS+=("$FRAMEWORK_NAME")
        fi
    done
else
    # Pods klasörünü tara
    for pod_dir in Pods/*; do
        if [ -d "$pod_dir" ] && [[ ! "$pod_dir" =~ "Target Support Files" ]] && [[ ! "$pod_dir" =~ "Local Podspecs" ]] && [[ ! "$pod_dir" =~ "Headers" ]]; then
            POD_NAME=$(basename "$pod_dir")
            if [[ ! "$POD_NAME" =~ ^[[:upper:]] ]]; then
                FRAMEWORKS+=("$POD_NAME")
            fi
        fi
    done
fi

# Bilinen framework'leri elle ekle
KNOWN_FRAMEWORKS=("Alamofire" "KeychainAccess" "SDWebImage" "SocketIO" "Starscream" "Toast_Swift" "GoogleWebRTC")
for framework in "${KNOWN_FRAMEWORKS[@]}"; do
    if [[ ! " ${FRAMEWORKS[@]} " =~ " ${framework} " ]]; then
        FRAMEWORKS+=("$framework")
    fi
done

# Debug Input XCFilelist oluştur
echo "📝 Debug Input XCFilelist dosyası oluşturuluyor..."
cat > "${INPUT_FILES_DEBUG}" << EOF
\${PODS_ROOT}/Target Support Files/Pods-SesliIletisim/Pods-SesliIletisim-frameworks.sh
\${PODS_XCFRAMEWORKS_BUILD_DIR}/GoogleWebRTC/WebRTC.framework/WebRTC
EOF

for framework in "${FRAMEWORKS[@]}"; do
    echo "\${BUILT_PRODUCTS_DIR}/${framework}/${framework}.framework" >> "${INPUT_FILES_DEBUG}"
done

# Debug Output XCFilelist oluştur
echo "📝 Debug Output XCFilelist dosyası oluşturuluyor..."
cat > "${OUTPUT_FILES_DEBUG}" << EOF
\${TARGET_BUILD_DIR}/\${FRAMEWORKS_FOLDER_PATH}/WebRTC.framework
EOF

for framework in "${FRAMEWORKS[@]}"; do
    echo "\${TARGET_BUILD_DIR}/\${FRAMEWORKS_FOLDER_PATH}/${framework}.framework" >> "${OUTPUT_FILES_DEBUG}"
done

# Release Dosyalarını Kopyala
echo "📝 Release XCFilelist dosyaları oluşturuluyor..."
cp "${INPUT_FILES_DEBUG}" "${INPUT_FILES_RELEASE}"
cp "${OUTPUT_FILES_DEBUG}" "${OUTPUT_FILES_RELEASE}"

# Sonuçları göster
echo "✅ Tüm XCFilelist dosyaları başarıyla oluşturuldu!"
echo "📋 Oluşturulan dosyalar:"
echo "- ${INPUT_FILES_DEBUG}"
echo "- ${OUTPUT_FILES_DEBUG}"
echo "- ${INPUT_FILES_RELEASE}"
echo "- ${OUTPUT_FILES_RELEASE}"

# Xcode ayarlarında kontroller
echo "🔍 Xcode projesi kontrol ediliyor..."
PROJECT_FILE="SesliIletisim.xcodeproj/project.pbxproj"

if [ -f "${PROJECT_FILE}" ]; then
    # Yedek oluştur
    cp -f "${PROJECT_FILE}" "${PROJECT_FILE}.xcfilelist.backup"
    echo "✅ Proje dosyası yedeklendi."
    
    # XCFilelist yollarını düzelt
    sed -i '' 's|"\/Target Support Files\/Pods-SesliIletisim\/Pods-SesliIletisim-frameworks-|"$(PODS_ROOT)\/Target Support Files\/Pods-SesliIletisim\/Pods-SesliIletisim-frameworks-|g' "${PROJECT_FILE}"
    echo "✅ Proje dosyasında XCFilelist yolları düzeltildi."
else
    echo "⚠️ Proje dosyası bulunamadı: ${PROJECT_FILE}"
fi

echo "🎉 XCFilelist sorunu başarıyla çözüldü!"
echo ""
echo "📋 Şimdi aşağıdaki adımları takip edin:"
echo "1. Xcode'da Clean Build Folder (Shift+Cmd+K) yapın"
echo "2. Projeyi yeniden derleyin (Cmd+B)"
echo "3. Sorun devam ederse:"
echo "   a. Xcode'u kapatın"
echo "   b. DerivedData klasörünü temizleyin: rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*"
echo "   c. Xcode'u tekrar açın ve projeyi derleyin" 