#!/bin/bash

# Socket.IO-Client-Swift ve Starscream uyumluluk problemi çözücü
# Bu script, Socket.IO-Client-Swift ve Starscream arasındaki uyumluluk sorunlarını giderir

# Çalışma dizinini kontrol et
if [ ! -f "Podfile" ]; then
    echo "❌ Lütfen bu scripti SesliIletisim klasöründe çalıştırın."
    exit 1
fi

echo "🔄 Socket.IO ve Starscream Uyumluluk Düzenleyici 🔄"
echo "------------------------------------------------"

# Starscream versiyonunu kontrol et
STARSCREAM_PODSPEC_PATH="Pods/Starscream/Starscream.podspec"
SOCKET_IO_PATH="Pods/Socket.IO-Client-Swift"
SOCKET_ENGINE_PATH="${SOCKET_IO_PATH}/Source/SocketIO/Engine/SocketEngine.swift"
SOCKET_ENGINE_SPEC_PATH="${SOCKET_IO_PATH}/Source/SocketIO/Engine/SocketEngineSpec.swift"

# Yedekleme dosyasını oluştur ve orijinali yedekle
echo "📁 Orijinal dosyaları yedekliyorum..."
cp -f "${SOCKET_ENGINE_PATH}" "${SOCKET_ENGINE_PATH}.backup"
cp -f "${SOCKET_ENGINE_SPEC_PATH}" "${SOCKET_ENGINE_SPEC_PATH}.backup"
echo "✅ Yedekleme tamamlandı."

# SocketEngineSpec.swift düzeltmesi (class yerine AnyObject)
echo "🔧 SocketEngineSpec.swift düzeltiliyor..."
sed -i '' 's/protocol SocketEngineSpec: class {/protocol SocketEngineSpec: AnyObject {/' "${SOCKET_ENGINE_SPEC_PATH}"
echo "✅ SocketEngineSpec.swift düzeltildi."

# SocketEngine.swift düzeltmesi (Yeni WebSocketDelegate protokol uyumluluğu)
echo "🔧 SocketEngine.swift WebSocketDelegate uyumluluğu düzeltiliyor..."
# didReceive fonksiyonunu güncelle
sed -i '' 's/public func didReceive(event: WebSocketEvent, client _: WebSocket) {/public func didReceive(event: WebSocketEvent, client: WebSocket) {/' "${SOCKET_ENGINE_PATH}"

# Podfile'ı kontrol etmek için
if grep -q "pod 'Socket.IO-Client-Swift'" "Podfile"; then
    echo "📝 Socket.IO-Client-Swift ve Starscream versiyonlarını Podfile'da düzenliyorum..."
    # Podfile'ı yedekle
    cp -f "Podfile" "Podfile.backup"
    
    # Socket.IO-Client-Swift ve Starscream versiyonlarını düzenle
    sed -i '' 's/pod '"'"'Socket.IO-Client-Swift'"'"'.*$/pod '"'"'Socket.IO-Client-Swift'"'"', '"'"'16.0.1'"'"'/' "Podfile"
    sed -i '' 's/pod '"'"'Starscream'"'"'.*$/pod '"'"'Starscream'"'"', '"'"'4.0.4'"'"'/' "Podfile"
    
    echo "✅ Podfile düzenlemeleri tamamlandı."
    
    # Pod'ları güncelle
    echo "🔄 Pod'lar güncelleniyor..."
    pod deintegrate
    pod clean
    rm -rf "${HOME}/Library/Caches/CocoaPods"
    rm -rf "${HOME}/Library/Developer/Xcode/DerivedData"
    pod install --repo-update
    echo "✅ Pod'lar güncellendi."
else
    echo "⚠️ Podfile'da Socket.IO-Client-Swift bulunamadı. Düzenleme yapılamadı."
fi

# WebSocketDelegate uyumluluk yamalarını eklemek için yeni bir dosya oluşturalım
echo "🔧 WebSocketDelegate uyumluluğu için yeni dosya oluşturuluyor..."
WEBSOCKET_COMPAT_PATH="${SOCKET_IO_PATH}/Source/SocketIO/Engine/WebSocketCompat.swift"

# WebSocketCompat.swift dosyasını oluştur
cat > "${WEBSOCKET_COMPAT_PATH}" << 'EOF'
//
//  WebSocketCompat.swift
//  Socket.IO-Client-Swift
//
//  WebSocket uyumluluk katmanı - Starscream 4.x ile Socket.IO-Client-Swift uyumluluğu için
//

import Foundation
import Starscream

// Starscream 4.x ile Socket.IO-Client-Swift uyumluluğu için gereken uzantılar
extension WebSocketDelegate {
    // Eski Starscream 3.x API'sini taklit eden fonksiyonlar
    public func websocketDidConnect(socket: WebSocketClient) {
        // Bu default implementasyon, eski API ile yeni API arasında uyum sağlar
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        // Bu default implementasyon, eski API ile yeni API arasında uyum sağlar
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // Bu default implementasyon, eski API ile yeni API arasında uyum sağlar
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // Bu default implementasyon, eski API ile yeni API arasında uyum sağlar
    }
}

// WebSocketClient için uyumluluk katmanı
extension WebSocket {
    // Socket.IO-Client-Swift'in ihtiyaç duyduğu eski API metodlarını yeni WebSocket sınıfına ekler
    func write(string: String, completion: (() -> ())?) {
        self.write(string: string)
        completion?()
    }
    
    func write(data: Data, completion: (() -> ())?) {
        self.write(data: data)
        completion?()
    }
}
EOF

echo "✅ WebSocketCompat.swift oluşturuldu."

# Gerekirse podspec dosyasını düzeltmek için
if [ -f "${STARSCREAM_PODSPEC_PATH}" ]; then
    echo "🔧 Starscream podspec dosyası düzeltiliyor..."
    sed -i '' 's/s.ios.deployment_target = .*/s.ios.deployment_target = '"'"'13.0'"'"'/' "${STARSCREAM_PODSPEC_PATH}"
    echo "✅ Starscream podspec dosyası düzeltildi."
fi

echo "🎉 Socket.IO ve Starscream uyumluluk düzenlemeleri tamamlandı!"
echo ""
echo "📋 Şimdi aşağıdaki adımları takip edin:"
echo "1. Xcode'u kapatın (Cmd+Q)"
echo "2. 'pod install' komutunu çalıştırın"
echo "3. Xcode'u tekrar açın ve projeyi derleyin"
echo "4. Sorun devam ederse 'pod update' komutunu çalıştırın ve tekrar deneyin"
echo ""
echo "👨‍�� İyi kodlamalar!" 