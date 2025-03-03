#!/bin/bash

# Hata durumunda script'i durdur
set -e

echo "🛠️ XCFilelist Yol Düzeltme Aracı 🛠️"
echo "----------------------------------"

# Proje konfigürasyonu
PROJECT_NAME="SesliIletisim"
PROJECT_PATH="./${PROJECT_NAME}.xcodeproj/project.pbxproj"
PODS_ROOT="$(pwd)/Pods"
TARGET_SUPPORT_FILES="${PODS_ROOT}/Target Support Files/Pods-${PROJECT_NAME}"

# Projeyi kontrol et
if [ ! -f "$PROJECT_PATH" ]; then
    echo "❌ Proje dosyası bulunamadı: $PROJECT_PATH"
    exit 1
fi

# Yedek al
cp "$PROJECT_PATH" "${PROJECT_PATH}.xcfilelist.backup"
echo "✅ Proje dosyası yedeği alındı: ${PROJECT_PATH}.xcfilelist.backup"

# XCFilelist dosyalarının varlığını kontrol et
for file in "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Debug-input-files.xcfilelist" "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Debug-output-files.xcfilelist" "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Release-input-files.xcfilelist" "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Release-output-files.xcfilelist"; do
    if [ ! -f "$file" ]; then
        echo "❌ Dosya bulunamadı: $file"
        echo "XCFilelist dosyaları yeniden oluşturuluyor..."
        ./fix_xcfilelist.sh
        break
    fi
done

echo "🔍 Proje dosyasındaki xcfilelist yollarını düzeltiyorum..."

# Mutlak yolları kullanmak için Proje dosyasında düzenleme yap
ABSOLUTE_TARGET_SUPPORT="$(cd "${TARGET_SUPPORT_FILES}" && pwd)"
PODS_ROOT_ABS="$(cd "${PODS_ROOT}" && pwd)"

# Bu yolları kullanarak, build phases kısmındaki xcfilelist referanslarını düzeltelim
sed -i '' "s|/Target Support Files/Pods-${PROJECT_NAME}|${ABSOLUTE_TARGET_SUPPORT}|g" "$PROJECT_PATH"

# Alternatif olarak, göreceli yolları PODS_ROOT ile birlikte kullanacak şekilde düzeltme
sed -i '' "s|/Target Support Files/Pods-${PROJECT_NAME}|\$(PODS_ROOT)/Target Support Files/Pods-${PROJECT_NAME}|g" "$PROJECT_PATH"

echo "✅ Proje dosyasındaki xcfilelist yolları düzeltildi!"

# Ayrıca scriptfile'ların çalıştırma iznini ayarlayalım
echo "🔧 Frameworks.sh dosyasına çalıştırma izni veriyorum..."
chmod +x "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks.sh"

# Pods.xcodeproj dosyasındaki yolları düzelt
PODS_XCODEPROJ="${PODS_ROOT}/Pods.xcodeproj/project.pbxproj"
if [ -f "$PODS_XCODEPROJ" ]; then
    echo "🔧 Pods.xcodeproj dosyasındaki yolları düzeltiyorum..."
    cp "$PODS_XCODEPROJ" "${PODS_XCODEPROJ}.backup"
    
    # Yolları düzelt
    sed -i '' "s|/Target Support Files/Pods-${PROJECT_NAME}|\$(PODS_ROOT)/Target Support Files/Pods-${PROJECT_NAME}|g" "$PODS_XCODEPROJ"
    
    echo "✅ Pods.xcodeproj dosyasındaki yollar düzeltildi!"
else
    echo "⚠️ Pods.xcodeproj dosyası bulunamadı."
fi

# xcfilelist dosyalarını hem göreceli hem de mutlak yollarla birlikte kopyala
echo "🔧 XCFilelist dosyalarını alternatif konumlara kopyalıyorum..."

# Ana proje klasörüne kopyala
cp "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Debug-input-files.xcfilelist" "./"
cp "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Debug-output-files.xcfilelist" "./"
cp "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Release-input-files.xcfilelist" "./"
cp "${TARGET_SUPPORT_FILES}/Pods-${PROJECT_NAME}-frameworks-Release-output-files.xcfilelist" "./"

# Ana projede yeni bir Build Phase script ekle
echo "🔧 Manuel frameworks ekleme scripti oluşturuyorum..."

cat > "./add_frameworks_manually.sh" << 'EOF'
#!/bin/bash
# Bu script, framework'leri manuel olarak eklemek için kullanılabilir
# Eğer xcfilelist dosyaları hala çalışmıyorsa, bu scripti Build Phases'e ekleyin

FRAMEWORKS_FOLDER_PATH="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "$FRAMEWORKS_FOLDER_PATH"

# Framework kopyalama fonksiyonu
copy_framework() {
    SRC="$1"
    if [ -e "$SRC" ]; then
        echo "Kopyalanıyor: $SRC -> $FRAMEWORKS_FOLDER_PATH"
        cp -R "$SRC" "$FRAMEWORKS_FOLDER_PATH/"
    else
        echo "UYARI: Framework bulunamadı: $SRC"
    fi
}

# Tüm frameworkleri kopyala
copy_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/KeychainAccess/KeychainAccess.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/Socket.IO-Client-Swift/SocketIO.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/Starscream/Starscream.framework"
copy_framework "${BUILT_PRODUCTS_DIR}/Toast-Swift/Toast_Swift.framework"
copy_framework "${PODS_ROOT}/GoogleWebRTC/Frameworks/frameworks/WebRTC.framework"

echo "Framework'ler manuel olarak kopyalandı!"
EOF

chmod +x "./add_frameworks_manually.sh"

echo -e "\n✅ İşlem tamamlandı! Şimdi şunları yapın:"
echo "1. Xcode'da projeyi açın: open ${PROJECT_NAME}.xcworkspace"
echo "2. Xcode'da Build Phases sekmesine gidin"
echo "3. [Embed Pods Frameworks] aşamasını kontrol edin ve Input/Output Files yollarının şöyle olduğundan emin olun:"
echo "   - Input Files: \$(PODS_ROOT)/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks.sh"
echo "   - Input File List: \$(PODS_ROOT)/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks-\$(CONFIGURATION)-input-files.xcfilelist"
echo "   - Output File List: \$(PODS_ROOT)/Target Support Files/Pods-${PROJECT_NAME}/Pods-${PROJECT_NAME}-frameworks-\$(CONFIGURATION)-output-files.xcfilelist"
echo "4. Sorun devam ederse, 'add_frameworks_manually.sh' scriptini kullanarak manuel framework entegrasyonu yapın." 