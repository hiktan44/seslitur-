#!/bin/bash

# Starscream Privacy Bundle sorununu çözen script
# Bu script, eksik Privacy Bundle hatalarını gidermek için çalıştırılabilir

echo "🔒 Starscream Privacy Bundle Düzeltme Aracı 🔒"
echo "-------------------------------------------"

# Proje ve Paths
PROJECT_NAME="SesliIletisim"
WORKSPACE_PATH="${PROJECT_NAME}.xcworkspace"
DERIVED_DATA_PATH="${HOME}/Library/Developer/Xcode/DerivedData"
DERIVED_DATA_FOLDER=$(find "${DERIVED_DATA_PATH}" -name "${PROJECT_NAME}-*" -type d | head -n 1)

if [ -z "$DERIVED_DATA_FOLDER" ]; then
    echo "❌ DerivedData klasörü bulunamadı. Lütfen projeyi Xcode'da en az bir kere derleyin."
    exit 1
fi

echo "📁 DerivedData klasörü: $DERIVED_DATA_FOLDER"

# Privacy Bundle Dosyaları
PRIVACY_SOURCE="${PWD}/Pods/Starscream/Sources/PrivacyInfo.xcprivacy"
BUNDLE_DIR="${DERIVED_DATA_FOLDER}/Build/Products/Debug-iphonesimulator/Starscream/Starscream_Privacy.bundle"
PRIVACY_DEST="${BUNDLE_DIR}/Starscream_Privacy"

# Privacy Bundle oluştur
mkdir -p "${BUNDLE_DIR}"
echo "✅ Bundle klasörü oluşturuldu: ${BUNDLE_DIR}"

# Info.plist dosyasını oluştur
cat > "${BUNDLE_DIR}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.vluxe.starscream.privacy</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Starscream_Privacy</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF
echo "✅ Info.plist dosyası oluşturuldu"

# Privacy içeriğini kopyala veya oluştur
if [ -f "$PRIVACY_SOURCE" ]; then
    cp "$PRIVACY_SOURCE" "$PRIVACY_DEST"
    echo "✅ Privacy info dosyası kopyalandı: ${PRIVACY_SOURCE} -> ${PRIVACY_DEST}"
else
    # Privacy dosyası bulunamadıysa, varsayılan oluştur
    cat > "${PRIVACY_DEST}" << 'EOF'
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
EOF
    echo "✅ Varsayılan privacy dosyası oluşturuldu: ${PRIVACY_DEST}"
fi

# Dummy binary oluştur (eksik olan binary Starscream_Privacy)
# C kod dosyası oluştur
TEMP_DIR=$(mktemp -d)
DUMMY_C_FILE="${TEMP_DIR}/dummy.c"
cat > "${DUMMY_C_FILE}" << 'EOF'
// Dummy C file for Starscream_Privacy bundle
#include <stdio.h>

int main() {
    printf("Starscream Privacy Bundle\n");
    return 0;
}
EOF

# Binary oluştur
clang -o "${BUNDLE_DIR}/Starscream_Privacy" "${DUMMY_C_FILE}" -target x86_64-apple-ios13.0-simulator
echo "✅ Dummy binary oluşturuldu: ${BUNDLE_DIR}/Starscream_Privacy"

# Oluşturulan binary için execute izni ver
chmod +x "${BUNDLE_DIR}/Starscream_Privacy"
echo "✅ Binary için execute izni verildi"

# Build Phases ayarlarını güncelle
XCODEPROJ_PATH="${PROJECT_NAME}.xcodeproj/project.pbxproj"
if [ -f "$XCODEPROJ_PATH" ]; then
    # Yedek al
    cp "$XCODEPROJ_PATH" "${XCODEPROJ_PATH}.privacy.backup"
    echo "✅ Proje dosyası yedeği alındı: ${XCODEPROJ_PATH}.privacy.backup"
    
    # Starscream_Privacy.bundle referansını güncelle
    sed -i '' "s|path = Starscream_Privacy.bundle; sourceTree = BUILT_PRODUCTS_DIR;|path = Starscream_Privacy.bundle; sourceTree = DERIVED_FILE_DIR;|g" "$XCODEPROJ_PATH"
    echo "✅ Proje dosyasında Privacy bundle yolu güncellendi"
fi

# Pods project ayarlarını da güncelle
PODS_XCODEPROJ_PATH="Pods/Pods.xcodeproj/project.pbxproj"
if [ -f "$PODS_XCODEPROJ_PATH" ]; then
    # Yedek al
    cp "$PODS_XCODEPROJ_PATH" "${PODS_XCODEPROJ_PATH}.privacy.backup"
    echo "✅ Pods proje dosyası yedeği alındı: ${PODS_XCODEPROJ_PATH}.privacy.backup"
    
    # Starscream_Privacy target ayarlarında EXECUTABLE_NAME'i ekle
    awk '
    BEGIN { print_line = 0; }
    /Starscream-Starscream_Privacy/ { print_line = 1; }
    /buildSettings = {/ {
        if (print_line == 1) {
            print $0;
            print "\t\t\t\tEXECUTABLE_NAME = Starscream_Privacy;";
            print_line = 0;
            next;
        }
    }
    { print $0; }
    ' "${PODS_XCODEPROJ_PATH}" > "${PODS_XCODEPROJ_PATH}.tmp"
    
    mv "${PODS_XCODEPROJ_PATH}.tmp" "${PODS_XCODEPROJ_PATH}"
    echo "✅ Pods proje dosyasında EXECUTABLE_NAME eklendi"
fi

# Diğer farklı yerlere de kopyala
echo "🔧 Privacy Bundle'ı farklı konumlara da kopyalıyorum..."

# Debug ve Release için
for CONFIG in "Debug" "Release"; do
    for SDK in "iphoneos" "iphonesimulator"; do
        TARGET_DIR="${DERIVED_DATA_FOLDER}/Build/Products/${CONFIG}-${SDK}/Starscream/"
        if [ ! -d "$TARGET_DIR" ]; then
            mkdir -p "$TARGET_DIR"
        fi
        
        if [ ! -d "${TARGET_DIR}/Starscream_Privacy.bundle" ]; then
            cp -R "${BUNDLE_DIR}" "${TARGET_DIR}"
            echo "✅ Bundle kopyalandı: ${TARGET_DIR}/Starscream_Privacy.bundle"
        fi
    done
done

# Run script dosyasını oluştur
RUN_SCRIPT_PATH="Pods/Target Support Files/Starscream/FixStarscreamPrivacy.sh"
mkdir -p "$(dirname "$RUN_SCRIPT_PATH")"
cat > "$RUN_SCRIPT_PATH" << EOF
#!/bin/bash

# Bu script, CocoaPods build fazına eklenir
# Starscream_Privacy.bundle için gerekli eksik binary dosyasını kopyalar

BUNDLE_DIR="\${BUILT_PRODUCTS_DIR}/Starscream/Starscream_Privacy.bundle"
mkdir -p "\${BUNDLE_DIR}"

# İçerikleri kopyala
if [ -f "${BUNDLE_DIR}/Info.plist" ]; then
    cp "${BUNDLE_DIR}/Info.plist" "\${BUNDLE_DIR}/"
fi

if [ -f "${BUNDLE_DIR}/Starscream_Privacy" ]; then
    cp "${BUNDLE_DIR}/Starscream_Privacy" "\${BUNDLE_DIR}/"
    chmod +x "\${BUNDLE_DIR}/Starscream_Privacy"
fi

if [ -f "${BUNDLE_DIR}/PrivacyInfo.xcprivacy" ]; then
    cp "${BUNDLE_DIR}/PrivacyInfo.xcprivacy" "\${BUNDLE_DIR}/"
fi

if [ -f "${PRIVACY_SOURCE}" ]; then
    cp "${PRIVACY_SOURCE}" "\${BUNDLE_DIR}/Starscream_Privacy"
fi

exit 0
EOF

chmod +x "$RUN_SCRIPT_PATH"
echo "✅ Run script oluşturuldu: $RUN_SCRIPT_PATH"

# Ana Run Script fazı için bir script daha oluştur
MAIN_SCRIPT_PATH="fix_starscream_privacy_run_phase.sh"
cat > "$MAIN_SCRIPT_PATH" << 'EOF'
#!/bin/bash

# Bu script, Xcode'da Run Script fazı olarak eklenebilir
# Eklemek için: 
# 1. Target > Build Phases > + > New Run Script Phase
# 2. Bu scripti çağıran bir komut ekleyin: sh "${SRCROOT}/fix_starscream_privacy_run_phase.sh"

BUNDLE_DIR="${BUILT_PRODUCTS_DIR}/Starscream/Starscream_Privacy.bundle"
mkdir -p "${BUNDLE_DIR}"

echo "Starscream Privacy Bundle oluşturuluyor: ${BUNDLE_DIR}"

# Info.plist oluştur
cat > "${BUNDLE_DIR}/Info.plist" << 'EOFPLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.vluxe.starscream.privacy</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Starscream_Privacy</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOFPLIST

# Privacy info oluştur
cat > "${BUNDLE_DIR}/Starscream_Privacy" << 'EOFPRIVACY'
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
EOFPRIVACY

echo "Starscream Privacy Bundle başarıyla oluşturuldu!"
EOF

chmod +x "$MAIN_SCRIPT_PATH"
echo "✅ Ana run script fazı için script oluşturuldu: $MAIN_SCRIPT_PATH"

echo -e "\n🎉 İşlem tamamlandı! Lütfen şu adımları izleyin:"
echo "1. Xcode'u kapatın (eğer açıksa)"
echo "2. Terminalde şu komutu çalıştırın: open ${WORKSPACE_PATH}"
echo "3. Xcode -> Product -> Clean Build Folder (Shift+Cmd+K)"
echo "4. Projeyi yeniden build edin (Cmd+B)"
echo "5. Hala sorun devam ediyorsa, aşağıdaki adımları izleyin:"
echo "   a. Target ayarlarına gidin (SesliIletisim target) -> Build Phases -> + -> New Run Script Phase"
echo "   b. Script içeriği olarak şunu ekleyin: sh \"\${SRCROOT}/fix_starscream_privacy_run_phase.sh\""
echo "   c. Bu script fazını \"[CP] Embed Pods Frameworks\" fazından ÖNCE çalışacak şekilde taşıyın (yukarı sürükleyin)"
echo "   d. Tekrar Clean Build Folder yapıp derleyin"

