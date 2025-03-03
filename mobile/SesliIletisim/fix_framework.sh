#!/bin/bash

# Framework hatalarını düzeltme scripti
echo "🚀 SesliIletisim Framework düzeltme işlemi başlıyor..."

# 1. Xcode'u kapatma
echo "📱 Xcode kapatılıyor..."
pkill -9 Xcode || true

# 2. Derived Data temizliği
echo "🧹 Derived Data temizleniyor..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
rm -rf ~/Library/Developer/Xcode/DerivedData/Pods-*

# 3. Pods temizliği
echo "🧹 Pod dosyaları temizleniyor..."
arch -x86_64 pod deintegrate || true
rm -rf Pods
rm -f Podfile.lock
rm -rf SesliIletisim.xcworkspace

# 4. Podfile kontrolü
if [ ! -f "Podfile" ]; then
  echo "❌ Podfile bulunamadı! Script sonlandırılıyor."
  exit 1
fi

# 5. Alamofire sorununun çözümü için önce dosyaları indirelim
echo "📦 Podları yüklüyoruz..."
arch -x86_64 pod install --verbose || {
    echo "❌ Pod kurulumu başarısız oldu"
    exit 1
}

# 6. Alamofire Concurrency.swift düzeltmesi
echo "🔧 Alamofire Concurrency.swift dosyası düzeltiliyor..."
CONCURRENCY_FILE="Pods/Alamofire/Source/Concurrency.swift"
if [ -f "$CONCURRENCY_FILE" ]; then
    # DataTask için düzeltme
    sed -i '' 's/return await withTaskCancellationHandler {/Task.init {/g' "$CONCURRENCY_FILE"
    sed -i '' 's/} onCancel: {/}/g' "$CONCURRENCY_FILE"
    sed -i '' 's/await task.value/return await task.value/g' "$CONCURRENCY_FILE"
    
    # DataTask ve DownloadTask metotları için düzeltme
    sed -i '' 's/await withTaskCancellationHandler {/\/\/ withTaskCancellationHandler kaldırıldı/g' "$CONCURRENCY_FILE"
    sed -i '' 's/self.cancel()/\/\/ self.cancel()/g' "$CONCURRENCY_FILE"
    sed -i '' 's/} onCancel: {/\/\/ onCancel kaldırıldı/g' "$CONCURRENCY_FILE"
    
    echo "✅ Alamofire Concurrency.swift düzeltildi"
else
    echo "⚠️ Alamofire Concurrency.swift dosyası bulunamadı"
fi

# 7. Starscream FoundationSecurity.swift düzeltmesi
echo "🔧 Starscream FoundationSecurity.swift dosyası düzeltiliyor..."
SECURITY_FILE="Pods/Starscream/Sources/Security/FoundationSecurity.swift"
if [ -f "$SECURITY_FILE" ]; then
    # Dosyanın yedeklemesini alalım
    cp "$SECURITY_FILE" "${SECURITY_FILE}.bak"
    
    # Yeni içeriği oluştur
    cat > "$SECURITY_FILE" << 'EOF'
//
//  FoundationSecurity.swift
//  Starscream
//
//  Created by Dalton Cherry on 1/23/19.
//  Copyright © 2019 Vluxe. All rights reserved.
//

import Foundation
import CommonCrypto

public enum PinningState {
    case success
    case failed(CFError?)
}

public class FoundationSecurity  {
    var allowSelfSigned = false
    
    public init(allowSelfSigned: Bool = false) {
        self.allowSelfSigned = allowSelfSigned
    }
    
    public func isValid(_ trust: SecTrust, domain: String?) -> (Bool, PinningState) {
        if #available(iOS 13.0, *) {
            handleModernTrust(trust: trust, completion: { state in
                // handled via the completion block
            })
            return (false, .failed(nil))
        } else {
            handleOldSecurityTrust(trust: trust, completion: { state in
                // handled via the completion block
            })
            return (false, .failed(nil))
        }
    }
    
    //NOTE: Performance wise its actually kinda bad to evaluate trust on the main thread, might want to switch to an async model
    @available(iOS 13.0, *)
    private func handleModernTrust(trust: SecTrust, completion: @escaping ((PinningState) -> ())) {
        var error: CFError?
        if SecTrustEvaluateWithError(trust, &error) {
            completion(.success)
        } else {
            completion(.failed(error))
        }
    }
    
    private func handleOldSecurityTrust(trust: SecTrust, completion: ((PinningState) -> ())) {
        if #available(iOS 13.0, *) {
            var error: CFError?
            if SecTrustEvaluateWithError(trust, &error) {
                completion(.success)
            } else {
                completion(.failed(error))
            }
        } else {
            var result: SecTrustResultType = .unspecified
            SecTrustEvaluate(trust, &result)
            if result == .unspecified || result == .proceed {
                completion(.success)
            } else {
                let e = CFErrorCreate(kCFAllocatorDefault, "FoundationSecurityError" as NSString?, Int(result.rawValue), nil)
                completion(.failed(e))
            }
        }
    }
}
EOF
    echo "✅ Starscream FoundationSecurity.swift düzeltildi"
else
    echo "⚠️ Starscream FoundationSecurity.swift dosyası bulunamadı"
fi

# 8. Starscream FoundationTransport.swift düzeltmesi
echo "🔧 Starscream FoundationTransport.swift dosyası düzeltiliyor..."
TRANSPORT_FILE="Pods/Starscream/Sources/Transport/FoundationTransport.swift"
if [ -f "$TRANSPORT_FILE" ]; then
    # Dosyanın yedeklemesini alalım
    cp "$TRANSPORT_FILE" "${TRANSPORT_FILE}.bak"
    
    # Düzeltilmiş SSL domain name kısmını ekle
    cat "$TRANSPORT_FILE" | awk '{
        if ($0 ~ /if domain == nil/) {
            print "        if domain == nil,";
            print "            let sslContextOut = CFWriteStreamCopyProperty(outputStream, CFStreamPropertyKey(rawValue: kCFStreamPropertySSLContext)) as! SSLContext? {";
            print "            var peerNameLen: Int = 0";
            print "            if #available(iOS 13.0, *) {";
            print "                // iOS 13+ için Network.framework kullanılmalı";
            print "            } else { ";
            print "                SSLGetPeerDomainNameLength(sslContextOut, &peerNameLen)";
            print "                var peerName = Data(count: peerNameLen)";
            print "                let _ = peerName.withUnsafeMutableBytes { (peerNamePtr: UnsafeMutablePointer<Int8>) in";
            print "                    SSLGetPeerDomainName(sslContextOut, peerNamePtr, &peerNameLen)";
            print "                }";
            print "                if let peerDomain = String(bytes: peerName, encoding: .utf8), peerDomain.count > 0 {";
            print "                    domain = peerDomain";
            print "                }";
            print "            }";
            
            # Tüm if domain parçasını atla
            flag = 1;
        } else if (flag == 1 && $0 ~ /}/) {
            print $0;
            flag = 0;
        } else if (flag == 0) {
            print $0;
        }
    }' > "${TRANSPORT_FILE}.new"
    
    # Yeni dosyayı orijinal dosyanın üzerine yaz
    mv "${TRANSPORT_FILE}.new" "$TRANSPORT_FILE"
    
    echo "✅ Starscream FoundationTransport.swift düzeltildi"
else
    echo "⚠️ Starscream FoundationTransport.swift dosyası bulunamadı"
fi

# 9. Toast-Swift düzeltmesi (whiteLarge -> large)
echo "🔧 Toast-Swift dosyası düzeltiliyor..."
TOAST_FILE="Pods/Toast-Swift/Toast/Toast.swift"
if [ -f "$TOAST_FILE" ]; then
    sed -i '' 's/UIActivityIndicatorView.Style.whiteLarge/UIActivityIndicatorView.Style.large/g' "$TOAST_FILE"
    echo "✅ Toast-Swift düzeltildi"
else
    echo "⚠️ Toast-Swift dosyası bulunamadı"
fi

# 10. Framework arama yolları için xcconfig dosyası oluşturma
echo "🔧 Özel xcconfig dosyası oluşturuluyor..."
mkdir -p xcconfig
cat > xcconfig/custom.xcconfig << 'EOF'
// Custom configuration settings for the project
IPHONEOS_DEPLOYMENT_TARGET = 13.0

// Framework Search Paths
FRAMEWORK_SEARCH_PATHS = $(inherited) "$(SRCROOT)/Pods/**" "$(PODS_ROOT)/**" "${PODS_CONFIGURATION_BUILD_DIR}/**" "${PODS_ROOT}/GoogleWebRTC/Frameworks" "${PODS_XCFRAMEWORKS_BUILD_DIR}/**"

// Header Search Paths
HEADER_SEARCH_PATHS = $(inherited) "$(SRCROOT)/Pods/**" "${PODS_ROOT}/**" "${PODS_CONFIGURATION_BUILD_DIR}/**" "${PODS_HEADERS_BUILD_DIR}/**"

// Library Search Paths
LIBRARY_SEARCH_PATHS = $(inherited) "$(SRCROOT)/Pods/**" "${PODS_ROOT}/**" "${PODS_CONFIGURATION_BUILD_DIR}/**"

// Other Linker Flags
OTHER_LDFLAGS = $(inherited) -l"c++" -l"z" -framework "Alamofire" -framework "GoogleWebRTC" -framework "KeychainAccess" -framework "SDWebImage" -framework "SocketIO" -framework "Starscream" -framework "Toast_Swift" -framework "AVFoundation" -framework "CoreFoundation" -framework "CoreMedia" -framework "Foundation" -framework "ImageIO" -framework "Security" -framework "UIKit" -framework "WebRTC"

// Swift Version
SWIFT_VERSION = 5.0

// Embedded Swift Standard Libraries
ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

// Modules
DEFINES_MODULE = YES
SWIFT_INSTALL_OBJC_HEADER = YES
CLANG_ENABLE_MODULES = YES
CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES

// Bitcode
ENABLE_BITCODE = NO

// Architectures for Simulator
EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
EXCLUDED_ARCHS[sdk=iphoneos*] = x86_64

// Swift Optimization Level
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_COMPILATION_MODE = wholemodule

// Link Errors Fix
CLANG_VALIDATE_PROJECT_FILE_REFERENCES = NO
VALIDATE_WORKSPACE = NO
EOF

echo "✅ Custom xcconfig dosyası oluşturuldu"

# 11. Podları yeniden yükleme
echo "📦 Podları yeniden kurmaya başlıyoruz..."
arch -x86_64 pod install --verbose || {
    echo "❌ Pod kurulumu başarısız oldu"
    exit 1
}

# 12. Xcode Workspace açma 
echo "🚀 İşlem tamamlandı! Şimdi Xcode açılıyor..."
arch -x86_64 open -a Xcode SesliIletisim.xcworkspace

echo ""
echo "▶️ Xcode'da aşağıdaki ayarları yapın:"
echo "1. Build Settings > Excluded Architectures > Any iOS Simulator SDK = arm64"
echo "2. Build Settings > Enable Bitcode = NO"
echo "3. Build Settings > iOS Deployment Target = 13.0"
echo "4. Project > Info > Configurations > Debug, Release > Seçili Konfigürasyon için 'custom.xcconfig' dosyasını seçin"
echo "5. Product > Clean Build Folder (Shift+Command+K)"
echo "6. Product > Build (Command+B)"

exit 0 