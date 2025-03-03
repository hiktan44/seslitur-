#!/bin/bash

# Xcode Command Line derleme scripti
# Bu script, projeyi Command Line kullanarak derler ve Privacy Bundle sorunlarını çözer

# Çalışma dizinini kontrol et
if [ ! -f "Podfile" ]; then
    echo "❌ Lütfen bu scripti SesliIletisim klasöründe çalıştırın."
    exit 1
fi

echo "📱 Command Line ile iOS Derleyici 📱"
echo "----------------------------------"

# Temizlik işlemleri
echo "🧹 Temizlik işlemleri yapılıyor..."
xcodebuild clean -workspace SesliIletisim.xcworkspace -scheme SesliIletisim
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*/Build/Intermediates.noindex
echo "✅ Temizlik tamamlandı"

# Privacy Bundle scripti entegre et
echo "🔒 Privacy Bundle scripti çalıştırılıyor..."
DERIVED_DATA_PATH="${HOME}/Library/Developer/Xcode/DerivedData"
DERIVED_DATA_FOLDER=$(find "${DERIVED_DATA_PATH}" -name "SesliIletisim-*" -type d | head -n 1)

# Simulatörde derleme
echo "🚀 iOS Simülatör için derleme başlıyor..."
mkdir -p build_log
SIMULATOR="iPhone 16"
LOGFILE="build_log/build_simulator.log"

# Build işlemi öncesi privacy script'i hazırla
cat > privacy_phase.sh << 'EOF'
#!/bin/bash

# Privacy Bundle Fazı
create_privacy_bundle() {
    local PRODUCT_BUNDLES_DIR="$1/Starscream"
    local STARSCREAM_PRIVACY_BUNDLE="${PRODUCT_BUNDLES_DIR}/Starscream_Privacy.bundle"
    local STARSCREAM_BINARY="${STARSCREAM_PRIVACY_BUNDLE}/Starscream_Privacy"
    
    mkdir -p "${STARSCREAM_PRIVACY_BUNDLE}"
    
    # Info.plist
    cat > "${STARSCREAM_PRIVACY_BUNDLE}/Info.plist" << 'EOT'
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
    <key>CFBundleExecutable</key>
    <string>Starscream_Privacy</string>
</dict>
</plist>
EOT
    
    # Privacy info
    cat > "${STARSCREAM_PRIVACY_BUNDLE}/PrivacyInfo.xcprivacy" << 'EOT'
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
    
    # Binary
    cat > "${STARSCREAM_BINARY}" << 'EOT'
#!/bin/sh
echo "Starscream Privacy Bundle"
exit 0
EOT
    chmod +x "${STARSCREAM_BINARY}"
    
    echo "✅ ${STARSCREAM_PRIVACY_BUNDLE} oluşturuldu"
}

create_privacy_bundle "$1"
EOF

chmod +x privacy_phase.sh

echo "🔄 Derleme hazırlanıyor..."
echo "📱 Simulator: $SIMULATOR"

# Öncelikle DerivedData klasörünü oluştur
mkdir -p "${HOME}/Library/Developer/Xcode/DerivedData/SesliIletisim-temp/Build/Products/Debug-iphonesimulator/Starscream"

# Privacy bundle'ı derleme öncesi oluştur
./privacy_phase.sh "${HOME}/Library/Developer/Xcode/DerivedData/SesliIletisim-temp/Build/Products/Debug-iphonesimulator"

# Xcodebuild ile derleme
xcodebuild -workspace SesliIletisim.xcworkspace \
           -scheme SesliIletisim \
           -destination "platform=iOS Simulator,name=${SIMULATOR}" \
           -derivedDataPath "${HOME}/Library/Developer/Xcode/DerivedData/SesliIletisim-temp" \
           -quiet \
           -allowProvisioningUpdates \
           -parallelizeTargets \
           build | tee $LOGFILE

BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo "🎉 Derleme başarılı!"
    echo "✅ Ayrıntılar için log dosyasını kontrol edin: $LOGFILE"
else
    echo "❌ Derleme hatası! Ayrıntılar için log dosyasını kontrol edin: $LOGFILE"
fi

echo "🔍 Şimdi Xcode'u açabilir ve Clean Build Folder (Shift+Cmd+K) yapıp projeyi tekrar derleyebilirsiniz."
echo "📋 Build Phases sekmesinde + butonuna tıklayarak 'New Run Script Phase' ekleyin ve aşağıdaki içeriği yazın:"
echo "   sh \"\${SRCROOT}/create_privacy_bundles.sh\""
echo "   Bu script fazını \"[CP] Embed Pods Frameworks\" fazından önce çalışacak şekilde taşıyın." 