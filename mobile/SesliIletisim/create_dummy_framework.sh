#!/bin/bash

# Hata durumunda script'i durdur
set -e

echo "🛠️ Pods_SesliIletisim.framework Manuel Düzeltme Aracı 🛠️"
echo "-------------------------------------------------"

# Geçici dizin oluşturma
TEMP_DIR="$(pwd)/temp_framework"
mkdir -p "$TEMP_DIR"
echo "📁 Geçici klasör oluşturuldu: $TEMP_DIR"

# Pods dizini ve proje konfigürasyonu
PODS_ROOT="$(pwd)/Pods"
PROJECT_NAME="SesliIletisim"
FRAMEWORK_NAME="Pods_$PROJECT_NAME.framework"
FRAMEWORK_PATH="$PODS_ROOT/Target Support Files/Pods-$PROJECT_NAME"

echo "🔍 Frameworks yolu kontrol ediliyor..."
mkdir -p "${PODS_ROOT}/${FRAMEWORK_NAME}"
mkdir -p "${PODS_ROOT}/${FRAMEWORK_NAME}/Headers"
mkdir -p "${PODS_ROOT}/${FRAMEWORK_NAME}/Modules"

# Framework dosyalarını oluştur
echo "📝 Framework dosyaları hazırlanıyor..."

# 1. Headers klasörüne umbrella header dosyasını oluştur
if [ -f "$FRAMEWORK_PATH/Pods-$PROJECT_NAME-umbrella.h" ]; then
    cp "$FRAMEWORK_PATH/Pods-$PROJECT_NAME-umbrella.h" "${PODS_ROOT}/${FRAMEWORK_NAME}/Headers/"
    echo "✅ Umbrella header kopyalandı."
else
    cat > "${PODS_ROOT}/${FRAMEWORK_NAME}/Headers/Pods-${PROJECT_NAME}-umbrella.h" << EOF
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif


FOUNDATION_EXPORT double Pods_${PROJECT_NAME}VersionNumber;
FOUNDATION_EXPORT const unsigned char Pods_${PROJECT_NAME}VersionString[];
EOF
    echo "✅ Umbrella header oluşturuldu (kopya bulunamadı)."
fi

# 2. Modules klasörüne module.modulemap dosyasını oluştur
cat > "${PODS_ROOT}/${FRAMEWORK_NAME}/Modules/module.modulemap" << EOF
framework module Pods_${PROJECT_NAME} {
  umbrella header "Pods-${PROJECT_NAME}-umbrella.h"

  export *
  module * { export * }
}
EOF
echo "✅ Module.modulemap oluşturuldu."

# 3. Info.plist oluştur
cat > "${PODS_ROOT}/${FRAMEWORK_NAME}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>Pods_${PROJECT_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>org.cocoapods.Pods-${PROJECT_NAME}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Pods_${PROJECT_NAME}</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>NSPrincipalClass</key>
	<string></string>
</dict>
</plist>
EOF
echo "✅ Info.plist oluşturuldu."

# 4. Dummy framework binary oluştur
cat > "${TEMP_DIR}/dummy.c" << EOF
#include <stdint.h>

// Dummy symbols
double Pods_${PROJECT_NAME}VersionNumber = 1.0;
const unsigned char Pods_${PROJECT_NAME}VersionString[] = "1.0.0";
EOF

# Dummy binary'yi compile et
echo "🔨 Framework binary oluşturuluyor..."
xcrun clang -x c "${TEMP_DIR}/dummy.c" -arch arm64 -framework Foundation -dynamiclib -o "${TEMP_DIR}/bin_arm64"
xcrun lipo -create "${TEMP_DIR}/bin_arm64" -output "${PODS_ROOT}/${FRAMEWORK_NAME}/Pods_${PROJECT_NAME}"

# Binary'ye çalıştırma izni ver
chmod +x "${PODS_ROOT}/${FRAMEWORK_NAME}/Pods_${PROJECT_NAME}"
echo "✅ Framework binary oluşturuldu."

# Framework sembolik link oluştur - Xcode build klasörüne
DERIVED_DATA_DIR=~/Library/Developer/Xcode/DerivedData
BUILD_DIR=$(find "${DERIVED_DATA_DIR}" -maxdepth 1 -name "*${PROJECT_NAME}*" -type d 2>/dev/null | head -n 1)

if [ -n "$BUILD_DIR" ]; then
    PRODUCTS_DIR="${BUILD_DIR}/Build/Products"
    
    if [ -d "$PRODUCTS_DIR" ]; then
        for config_dir in $(find "$PRODUCTS_DIR" -maxdepth 1 -type d); do
            if [[ "$config_dir" == *"iphoneos"* || "$config_dir" == *"iphonesimulator"* ]]; then
                mkdir -p "${config_dir}/${FRAMEWORK_NAME}"
                mkdir -p "${config_dir}/${FRAMEWORK_NAME}/Headers"
                mkdir -p "${config_dir}/${FRAMEWORK_NAME}/Modules"
                
                cp -R "${PODS_ROOT}/${FRAMEWORK_NAME}/Headers/" "${config_dir}/${FRAMEWORK_NAME}/Headers/"
                cp -R "${PODS_ROOT}/${FRAMEWORK_NAME}/Modules/" "${config_dir}/${FRAMEWORK_NAME}/Modules/"
                cp "${PODS_ROOT}/${FRAMEWORK_NAME}/Info.plist" "${config_dir}/${FRAMEWORK_NAME}/"
                cp "${PODS_ROOT}/${FRAMEWORK_NAME}/Pods_${PROJECT_NAME}" "${config_dir}/${FRAMEWORK_NAME}/"
                
                echo "✅ Framework ${config_dir} klasörüne kopyalandı."
            fi
        done
    fi
else
    echo "⚠️ DerivedData klasörü bulunamadı. Framework sadece Pods dizinine kopyalandı."
fi

# Temizlik
rm -rf "$TEMP_DIR"
echo "🧹 Geçici dosyalar temizlendi."

echo -e "\n✅ İşlem tamamlandı! Şimdi şunları yapın:"
echo "1. Xcode'da her iki konfigürasyon için custom.xcconfig seçildiğinden emin olun (Project Settings > Info)."
echo "2. Product > Clean Build Folder yapın."
echo "3. Projeyi derleyin."
echo "4. Sorun devam ederse, hata mesajlarını tekrar kontrol edin." 