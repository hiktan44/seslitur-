# Sorun Giderme Kılavuzu

## Sık Karşılaşılan Sorunlar ve Çözümleri

### 1. Pod Kurulum Sorunları

#### Pod Install Başarısız Oluyorsa
```bash
# Önce pod'ları temizleyin
pod deintegrate
pod cache clean --all

# Sonra yeniden yükleyin
pod install
```

#### CocoaPods Repo Güncel Değilse
```bash
pod repo update
pod install
```

### 2. Derleme Hataları

#### Genel Derleme Hataları
1. Clean Build yapın (⇧⌘K)
2. Derived Data'yı temizleyin:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Projeyi yeniden açın ve derleyin

#### Signing Hataları
1. Xcode > Preferences > Accounts'dan Apple ID'nizi kontrol edin
2. Signing & Capabilities ayarlarını kontrol edin:
   - Automatic signing açık olmalı
   - Team seçili olmalı
   - Bundle identifier unique olmalı

#### Framework Hataları
1. Pods klasörünü silin
2. Podfile.lock dosyasını silin
3. Pod'ları yeniden yükleyin:
   ```bash
   pod install
   ```

### 3. Çalışma Zamanı Hataları

#### Uygulama Başlatma Sorunları
1. Info.plist ayarlarını kontrol edin
2. Gerekli izinlerin eklendiğinden emin olun:
   - Camera
   - Microphone
   - Photo Library

#### WebRTC Bağlantı Sorunları
1. TURN/STUN sunucu ayarlarını kontrol edin
2. Ağ bağlantısını test edin
3. Firewall ayarlarını kontrol edin

#### Ses/Video Sorunları
1. Cihaz izinlerini kontrol edin
2. Ses ayarlarını kontrol edin
3. Mikrofonun çalıştığından emin olun

### 4. Performance Sorunları

#### Yüksek CPU Kullanımı
1. Profiler ile analiz yapın
2. Background işlemleri kontrol edin
3. Memory leak'leri kontrol edin

#### Yüksek Bellek Kullanımı
1. Instruments ile memory analizi yapın
2. Büyük objeleri kontrol edin
3. Retain cycle'ları kontrol edin

### 5. Ağ Sorunları

#### API Bağlantı Hataları
1. API URL'lerini kontrol edin
2. Network durumunu kontrol edin
3. SSL sertifikalarını kontrol edin

#### Socket.IO Bağlantı Sorunları
1. Socket URL'yi kontrol edin
2. Handshake timeout ayarlarını kontrol edin
3. WebSocket desteğini kontrol edin

### 6. Güvenlik Sorunları

#### Keychain Erişim Hataları
1. Keychain erişim gruplarını kontrol edin
2. Provisioning profile'ı kontrol edin
3. Entitlements ayarlarını kontrol edin

#### SSL Pinning Sorunları
1. Sertifikaları kontrol edin
2. SSL pinning konfigürasyonunu kontrol edin
3. Network security ayarlarını kontrol edin

### 7. Debugging İpuçları

#### Xcode Debugging
1. Breakpoint'leri etkin kullanın
2. Console loglarını kontrol edin
3. Network inspector kullanın

#### Crash Raporları
1. Crash loglarını analiz edin
2. Symbolication işlemini yapın
3. Stack trace'i inceleyin

### 8. Güncelleme Sorunları

#### Xcode Güncelleme Sonrası
1. Command Line Tools'u yeniden yükleyin
2. Pod'ları güncelleyin
3. Clean build yapın

#### iOS Versiyon Değişikliği
1. Deployment target'ı kontrol edin
2. Deprecated API kullanımını kontrol edin
3. Yeni iOS özellikleri için fallback mekanizmaları ekleyin

## Yardımcı Komutlar

### Pod Komutları
```bash
# Pod'ları güncelle
pod update

# Belirli bir pod'u güncelle
pod update [POD_ADI]

# Pod repo'yu güncelle
pod repo update

# Pod cache'i temizle
pod cache clean --all
```

### Xcode Komutları
```bash
# Command Line Tools'u yeniden yükle
xcode-select --install

# Derived Data'yı temizle
rm -rf ~/Library/Developer/Xcode/DerivedData

# Xcode cache'i temizle
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

## İletişim

Eğer yukarıdaki çözümler sorununuzu çözmezse:
1. GitHub Issues açın
2. Stack Overflow'da soru sorun
3. Takım ile iletişime geçin: [email protected] 