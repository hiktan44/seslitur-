#!/bin/bash

# SesliIletisim projesi için Build Settings güncelleştirme scripti
# M4 Mac için optimize edilmiştir

# Proje dizinine git
cd "$(dirname "$0")/.."

# Xcode projesi ve hedef adı
PROJECT_NAME="SesliIletisim.xcodeproj"
TARGET_NAME="SesliIletisim"

echo "SesliIletisim projesi için Build Settings güncelleniyor..."

# Xcode projesi için Build Settings güncelleme
xcrun xcodebuild -project "$PROJECT_NAME" -target "$TARGET_NAME" -configuration Debug \
    ONLY_ACTIVE_ARCH=YES \
    VALID_ARCHS="arm64 x86_64" \
    EXCLUDED_ARCHS[sdk=iphonesimulator*]="i386" \
    EXCLUDED_ARCHS[sdk=iphoneos*]="armv7" \
    ENABLE_BITCODE=NO \
    ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    -quiet

echo "Build Settings güncellendi."

# Pod'ları temizle ve yeniden yükle
echo "Pod'lar temizleniyor ve yeniden yükleniyor..."
pod deintegrate
rm -rf Pods
rm -rf Podfile.lock
pod install

echo "Pod'lar yeniden yüklendi."

# Xcode'un türetilmiş verilerini temizle
echo "Xcode'un türetilmiş verileri temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*

echo "İşlem tamamlandı. Lütfen Xcode'u yeniden başlatın ve projeyi derleyin."
echo "Not: M4 Mac kullanıyorsanız, Xcode'u Rosetta ile açmayı unutmayın." 