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
