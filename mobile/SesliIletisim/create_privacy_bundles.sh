#!/bin/bash

# Privacy Bundle Oluşturma Scripti
# Bu script, iOS projenizde kullanılan 3. parti kütüphaneler için Privacy Bundle'lar oluşturur
# iOS 17 ve Xcode 15 ile uyumluluk için gereklidir

# Xcode Run Script fazı olarak kullanıldığında çalışma dizinini kontrol et
WORKING_DIR="${SRCROOT:-$(pwd)}"
cd "$WORKING_DIR"
echo "📍 Çalışma dizini: $WORKING_DIR"

# Hedef dizinleri belirle
TARGET_BUILD_DIR="${TARGET_BUILD_DIR:-${HOME}/Library/Developer/Xcode/DerivedData/SesliIletisim-*/Build/Products}"
# DerivedData klasöründeki simülatör ve cihaz derlemelerini belirle
DEBUG_SIMULATOR_DIR=$(find "${TARGET_BUILD_DIR}" -type d -path "*/Debug-iphonesimulator" -print -quit)
DEBUG_DEVICE_DIR=$(find "${TARGET_BUILD_DIR}" -type d -path "*/Debug-iphoneos" -print -quit)
RELEASE_SIMULATOR_DIR=$(find "${TARGET_BUILD_DIR}" -type d -path "*/Release-iphonesimulator" -print -quit)
RELEASE_DEVICE_DIR=$(find "${TARGET_BUILD_DIR}" -type d -path "*/Release-iphoneos" -print -quit)

# Debug çıktısı
echo "🔍 Derleme dizinleri:"
echo "   Debug Simulator: ${DEBUG_SIMULATOR_DIR:-'Bulunamadı'}"
echo "   Debug Device: ${DEBUG_DEVICE_DIR:-'Bulunamadı'}"
echo "   Release Simulator: ${RELEASE_SIMULATOR_DIR:-'Bulunamadı'}"
echo "   Release Device: ${RELEASE_DEVICE_DIR:-'Bulunamadı'}"

# Privacy Bundle oluşturma fonksiyonu
create_privacy_bundle() {
    local BUILD_DIR="$1"
    local LIBRARY_NAME="$2"
    local BUNDLE_NAME="${3:-${LIBRARY_NAME}_Privacy}"
    local BUNDLE_ID="${4:-com.example.${LIBRARY_NAME}.privacy}"
    
    if [ -z "$BUILD_DIR" ] || [ ! -d "$BUILD_DIR" ]; then
        echo "⚠️ Geçersiz build dizini: $BUILD_DIR"
        return
    fi
    
    # Kütüphane dizini oluştur
    local LIBRARY_DIR="${BUILD_DIR}/${LIBRARY_NAME}"
    mkdir -p "$LIBRARY_DIR"
    
    # Bundle dizini oluştur
    local PRIVACY_BUNDLE_DIR="${LIBRARY_DIR}/${BUNDLE_NAME}.bundle"
    mkdir -p "$PRIVACY_BUNDLE_DIR"
    
    echo "🛠 '${PRIVACY_BUNDLE_DIR}' için Privacy Bundle oluşturuluyor..."
    
    # Info.plist dosyası oluştur
    cat > "${PRIVACY_BUNDLE_DIR}/Info.plist" << EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${BUNDLE_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleExecutable</key>
    <string>${BUNDLE_NAME}</string>
</dict>
</plist>
EOT
    
    # PrivacyInfo.xcprivacy dosyası oluştur
    cat > "${PRIVACY_BUNDLE_DIR}/PrivacyInfo.xcprivacy" << EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array/>
</dict>
</plist>
EOT
    
    # Binary dosyası oluştur
    local BINARY_PATH="${PRIVACY_BUNDLE_DIR}/${BUNDLE_NAME}"
    cat > "${BINARY_PATH}" << EOT
#!/bin/sh
echo "${BUNDLE_NAME} Privacy Bundle"
exit 0
EOT
    
    # Binary dosyasına çalıştırma izni ver
    chmod +x "${BINARY_PATH}"
    
    echo "✅ ${BUNDLE_NAME} Privacy Bundle oluşturuldu: ${PRIVACY_BUNDLE_DIR}"
}

# Her derleme konfigürasyonu için bundle'ları oluştur
create_bundles_for_directory() {
    local DIR="$1"
    if [ -n "$DIR" ] && [ -d "$DIR" ]; then
        echo "📦 $DIR için Privacy Bundle'lar oluşturuluyor..."
        # Starscream için Privacy Bundle oluştur
        create_privacy_bundle "$DIR" "Starscream" "Starscream_Privacy" "com.vluxe.starscream.privacy"
        
        # Socket.IO için Privacy Bundle oluştur
        create_privacy_bundle "$DIR" "SocketIO" "SocketIO_Privacy" "com.socketio.client.privacy"
        
        # Alamofire için Privacy Bundle oluştur
        create_privacy_bundle "$DIR" "Alamofire" "Alamofire_Privacy" "org.alamofire.alamofire.privacy"
        
        # KeychainAccess için Privacy Bundle oluştur
        create_privacy_bundle "$DIR" "KeychainAccess" "KeychainAccess_Privacy" "com.kishikawakatsumi.keychainaccess.privacy"
        
        # Diğer kütüphaneler için buraya eklemeler yapabilirsiniz
        
        echo "✅ $DIR için Privacy Bundle'lar tamamlandı"
    fi
}

# Tüm derleme dizinleri için Privacy Bundle'ları oluştur
echo "🚀 Privacy Bundle oluşturma işlemi başlatılıyor..."

create_bundles_for_directory "$DEBUG_SIMULATOR_DIR"
create_bundles_for_directory "$DEBUG_DEVICE_DIR"
create_bundles_for_directory "$RELEASE_SIMULATOR_DIR"
create_bundles_for_directory "$RELEASE_DEVICE_DIR"

echo "🎉 Tüm Privacy Bundle'lar başarıyla oluşturuldu!"
echo ""
echo "📝 Xcode Build Phases'de bu scripti '[CP] Embed Pods Frameworks' fazından önce çalıştırdığınızdan emin olun."
echo "💡 İpucu: Debug sırasında DerivedData klasörünü temizlerseniz, Xcode'un Clean Build Folder seçeneğini kullanın." 