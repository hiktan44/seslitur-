#!/bin/bash

echo "Mac M4 ve iOS 13 Uyumluluk Düzeltmeleri Başlatılıyor..."

# Mevcut Xcode işlemlerini kapat
echo "Xcode kapatılıyor..."
pkill -9 Xcode

# Derived Data temizle
echo "Derived Data temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim*
rm -rf ~/Library/Developer/Xcode/DerivedData/Pods*

# Podları temizle
echo "Podlar temizleniyor..."
arch -x86_64 pod deintegrate
rm -rf Pods
rm -f Podfile.lock
rm -rf SesliIletisim.xcworkspace

# Yeniden Podları Kur
echo "Podlar yeniden kuruluyor (Rosetta ile)..."
arch -x86_64 pod install --no-repo-update

# Pod kod düzeltmeleri
echo "Pod kod düzeltmeleri uygulanıyor..."

# Alamofire Concurrency.swift düzeltmesi
ALAMOFIRE_CONCURRENCY_PATH="Pods/Alamofire/Source/Concurrency.swift"
if [ -f "$ALAMOFIRE_CONCURRENCY_PATH" ]; then
    echo "Alamofire Concurrency.swift düzeltiliyor..."
    sed -i '' 's/withTaskCancellationHandler(handler:/withTaskCancellationHandler(operation:/g' "$ALAMOFIRE_CONCURRENCY_PATH"
    sed -i '' 's/operation:/onCancel:/g' "$ALAMOFIRE_CONCURRENCY_PATH"
fi

# Starscream FoundationSecurity.swift düzeltmesi
STARSCREAM_SECURITY_PATH="Pods/Starscream/Sources/Security/FoundationSecurity.swift"
if [ -f "$STARSCREAM_SECURITY_PATH" ]; then
    echo "Starscream FoundationSecurity.swift düzeltiliyor..."
    sed -i '' 's/SecTrustEvaluate(/SecTrustEvaluateWithError(/' "$STARSCREAM_SECURITY_PATH"
fi

# Starscream FoundationTransport.swift düzeltmesi
STARSCREAM_TRANSPORT_PATH="Pods/Starscream/Sources/Transport/FoundationTransport.swift"
if [ -f "$STARSCREAM_TRANSPORT_PATH" ]; then
    echo "Starscream FoundationTransport.swift düzeltiliyor..."
    # Bu kısmı sadece iOS 13+ için kullanılabilir hale getir
    sed -i '' 's/SSLGetPeerDomainNameLength/if #available(iOS 13.0, *) {} else { SSLGetPeerDomainNameLength/g' "$STARSCREAM_TRANSPORT_PATH"
    sed -i '' 's/SSLGetPeerDomainName/if #available(iOS 13.0, *) {} else { SSLGetPeerDomainName/g' "$STARSCREAM_TRANSPORT_PATH"
fi

# Toast-Swift.swift düzeltmesi
TOAST_SWIFT_PATH="Pods/Toast-Swift/Toast/Toast.swift"
if [ -f "$TOAST_SWIFT_PATH" ]; then
    echo "Toast-Swift.swift düzeltiliyor..."
    sed -i '' 's/whiteLarge/large/g' "$TOAST_SWIFT_PATH"
fi

echo "Xcode açılıyor (Rosetta ile)..."
arch -x86_64 open -a Xcode SesliIletisim.xcworkspace

echo "Düzeltmeler tamamlandı! Lütfen şu adımları yapın:"
echo "1. Build Settings > Excluded Architectures > Any iOS Simulator SDK = arm64 olduğunu kontrol edin"
echo "2. Build Settings > Enable Bitcode = NO olduğunu kontrol edin"
echo "3. Build Settings > iOS Deployment Target = 13.0 olduğunu kontrol edin"
echo "4. Product > Clean Build Folder (Shift+Command+K) yapın"
echo "5. Product > Build (Command+B) ile derleyin" 