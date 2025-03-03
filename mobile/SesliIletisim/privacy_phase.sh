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
