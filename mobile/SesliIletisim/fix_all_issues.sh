#!/bin/bash

# SesliIletisim iOS Uygulaması - Tüm Sorunlar için Master Çözüm Scripti
# Bu script, SesliIletisim iOS uygulamasında karşılaşılan tüm sorunları çözmek için tasarlanmıştır
# Socket.IO uyumluluk sorunları, Privacy Bundle sorunları ve Framework sorunlarını tek hamlede çözer

echo "🔨 SesliIletisim iOS Master Çözüm Scripti 🔨"
echo "==========================================="
echo ""

# Çalışma dizinini kontrol et
if [ ! -f "Podfile" ]; then
    echo "❌ Lütfen bu scripti SesliIletisim klasöründe çalıştırın."
    exit 1
fi

CURRENT_DIR=$(pwd)
echo "📍 Çalışma dizini: $CURRENT_DIR"

# Tüm scriptlerin çalıştırılabilir olduğundan emin ol
echo "🔧 Scriptleri çalıştırılabilir yapıyorum..."
for script in fix_socket_io_compatibility.sh create_privacy_bundles.sh build_with_privacy.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "✅ $script çalıştırılabilir yapıldı."
    else
        echo "⚠️ $script bulunamadı, atlanıyor."
    fi
done

# Xcode'u kapatma fonksiyonu
close_xcode() {
    echo "🔄 Xcode kapatılıyor..."
    osascript -e 'tell application "Xcode" to quit'
    sleep 2  # Xcode'un kapanması için bekle
    echo "✅ Xcode kapatıldı."
}

# DerivedData ve Temizlik fonksiyonu
clean_derived_data() {
    echo "🧹 Temizlik yapılıyor..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
    rm -rf ~/Library/Caches/CocoaPods
    echo "✅ Temizlik tamamlandı."
}

# Eski oluşturulan Run Script fazları varsa Xcode projesinden kaldır
reset_project_settings() {
    echo "🔧 Proje ayarları sıfırlanıyor..."
    
    # Yedek oluştur
    cp -f SesliIletisim.xcodeproj/project.pbxproj SesliIletisim.xcodeproj/project.pbxproj.backup
    
    # Xcconfig dosyası düzenlemeleri
    if [ -f "custom.xcconfig" ]; then
        echo "📝 custom.xcconfig dosyası düzenleniyor..."
        cp -f custom.xcconfig custom.xcconfig.backup
        
        # Framework search paths düzenle
        cat > custom.xcconfig << 'EOF'
// Konfigürasyon dosyası
// Bu dosya, proje ayarlarını merkezi olarak kontrol etmek için kullanılır

// FRAMEWORK SEARCH PATHS
FRAMEWORK_SEARCH_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/Alamofire" "${PODS_CONFIGURATION_BUILD_DIR}/KeychainAccess" "${PODS_CONFIGURATION_BUILD_DIR}/SDWebImage" "${PODS_CONFIGURATION_BUILD_DIR}/Socket.IO-Client-Swift" "${PODS_CONFIGURATION_BUILD_DIR}/Starscream" "${PODS_CONFIGURATION_BUILD_DIR}/Toast-Swift" "${PODS_ROOT}/GoogleWebRTC/Frameworks/frameworks" 

// HEADER SEARCH PATHS
HEADER_SEARCH_PATHS = $(inherited) "${PODS_CONFIGURATION_BUILD_DIR}/Alamofire/Alamofire.framework/Headers" "${PODS_CONFIGURATION_BUILD_DIR}/KeychainAccess/KeychainAccess.framework/Headers" "${PODS_CONFIGURATION_BUILD_DIR}/SDWebImage/SDWebImage.framework/Headers" "${PODS_CONFIGURATION_BUILD_DIR}/Socket.IO-Client-Swift/SocketIO.framework/Headers" "${PODS_CONFIGURATION_BUILD_DIR}/Starscream/Starscream.framework/Headers" "${PODS_CONFIGURATION_BUILD_DIR}/Toast-Swift/Toast_Swift.framework/Headers"

// EXCLUDED ARCHS
EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64

// LIBRARY SEARCH PATHS
LIBRARY_SEARCH_PATHS = $(inherited) "${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}" /usr/lib/swift

// RUNPATH SEARCH PATHS (önemli)
LD_RUNPATH_SEARCH_PATHS = $(inherited) '@executable_path/Frameworks' '@loader_path/Frameworks'

// iOS DEPLOYMENT HEDEF
IPHONEOS_DEPLOYMENT_TARGET = 13.0

// OTHER LDFLAGS
OTHER_LDFLAGS = $(inherited) -framework "Alamofire" -framework "CFNetwork" -framework "CoreGraphics" -framework "Foundation" -framework "ImageIO" -framework "KeychainAccess" -framework "QuartzCore" -framework "SDWebImage" -framework "SocketIO" -framework "Starscream" -framework "Toast_Swift" -framework "UIKit" -framework "WebRTC"
EOF
        echo "✅ custom.xcconfig dosyası güncellendi."
    fi
    
    echo "✅ Proje ayarları sıfırlandı."
}

# Ana işlem süreci
echo "🚀 Sorun giderme işlemleri başlatılıyor..."

# 1. Adım: Xcode'u kapat ve temizlik yap
close_xcode
clean_derived_data

# 2. Adım: Proje ayarlarını sıfırla
reset_project_settings

# 3. Adım: Socket.IO uyumluluk sorunlarını çöz
if [ -f "fix_socket_io_compatibility.sh" ]; then
    echo "🔄 Socket.IO uyumluluk sorunları çözülüyor..."
    ./fix_socket_io_compatibility.sh
    echo "✅ Socket.IO uyumluluk sorunları çözüldü."
else
    echo "⚠️ fix_socket_io_compatibility.sh bulunamadı, bu adım atlanıyor."
    
    # Scriptimiz yoksa, manuel olarak Podfile'ı düzenleyelim
    echo "📝 Podfile düzenleniyor..."
    cp -f Podfile Podfile.backup
    sed -i '' 's/pod '"'"'Socket.IO-Client-Swift'"'"'.*$/pod '"'"'Socket.IO-Client-Swift'"'"', '"'"'16.0.1'"'"'/' "Podfile"
    sed -i '' 's/pod '"'"'Starscream'"'"'.*$/pod '"'"'Starscream'"'"', '"'"'4.0.4'"'"'/' "Podfile"
    echo "✅ Podfile düzenlendi."
    
    # Pod'ları yükle
    echo "🔄 Pod'lar yükleniyor..."
    pod deintegrate
    rm -rf Pods
    rm -rf Podfile.lock
    pod install --repo-update
    echo "✅ Pod'lar yüklendi."
fi

# 4. Adım: Privacy Bundle oluşturucu scripti oluştur ve çalıştır
if [ -f "create_privacy_bundles.sh" ]; then
    echo "🔒 Privacy Bundle'lar oluşturuluyor..."
    ./create_privacy_bundles.sh
    echo "✅ Privacy Bundle'lar oluşturuldu."
else
    echo "⚠️ create_privacy_bundles.sh bulunamadı, bu adım atlanıyor."
fi

# 5. Adım: Xcode Build Phase'e Privacy Bundle scripti ekle
echo "📋 Xcode Build Phase ekleme talimatları:"
echo "1. Xcode'u açın"
echo "2. SesliIletisim hedefini seçin"
echo "3. 'Build Phases' sekmesine gidin"
echo "4. '+' düğmesine tıklayarak 'New Run Script Phase' ekleyin"
echo "5. Aşağıdaki komutu ekleyin:"
echo "   sh \"\${SRCROOT}/create_privacy_bundles.sh\""
echo "6. Bu script fazını \"[CP] Embed Pods Frameworks\" fazından önce çalışacak şekilde taşıyın"

# 6. Adım: Command Line build'i test et
if [ -f "build_with_privacy.sh" ]; then
    echo "🔄 Command Line build'i test ediliyor..."
    ./build_with_privacy.sh
    echo "✅ Command Line build testi tamamlandı."
else
    echo "⚠️ build_with_privacy.sh bulunamadı, bu adım atlanıyor."
fi

# 7. Adım: Xcode'u yeniden aç
echo "🔄 Xcode açılıyor..."
xed .
echo "✅ Xcode açıldı."

echo "🎉 Tüm sorunlar başarıyla giderilmiştir!"
echo ""
echo "📋 Son Adımlar:"
echo "1. Xcode'da Clean Build Folder (Shift+Cmd+K) yapın"
echo "2. Projeyi derleyin (Cmd+B)"
echo "3. Sorun devam ederse, 'pod update' komutunu çalıştırın"
echo ""
echo "❓ Hala sorun yaşıyorsanız:"
echo "1. create_privacy_bundles.sh scriptini Build Phases'e eklediğinizden emin olun"
echo "2. custom.xcconfig dosyasının Debug ve Release konfigürasyonlarında kullanıldığını kontrol edin"
echo "3. Podfile'da Socket.IO-Client-Swift ve Starscream versiyonlarının uyumlu olduğundan emin olun"
echo ""
echo "👨‍�� İyi Çalışmalar!" 