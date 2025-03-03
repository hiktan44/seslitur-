# SesliIletisim Projesi Derleme Talimatları

## Gereksinimler

- Xcode 14.0 veya üzeri
- iOS 14.0 veya üzeri
- CocoaPods 1.11.0 veya üzeri

## Kurulum Adımları

1. Terminal'i açın ve proje dizinine gidin:
   ```bash
   cd /path/to/SesliIletisim
   ```

2. CocoaPods bağımlılıklarını yükleyin:
   ```bash
   pod install
   ```

3. Xcode workspace'i açın:
   ```bash
   open SesliIletisim.xcworkspace
   ```

4. Xcode'da projeyi derlemeden önce şu adımları izleyin:
   - Xcode'u tamamen kapatın ve yeniden açın
   - Xcode > Product > Clean Build Folder (Shift+Command+K) seçeneğini kullanarak derleme klasörünü temizleyin
   - Hedef cihazı seçin (iPhone veya Simulator)
   - Product > Build (Command+B) seçeneğini kullanarak projeyi derleyin

## Derleme Sorunları ve Çözümleri

### Sandbox İzin Hataları

Eğer sandbox izin hataları alıyorsanız:

1. Xcode'u tamamen kapatın
2. Terminal'de şu komutları çalıştırın:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SesliIletisim-*
   rm -rf ~/Library/Caches/com.apple.dt.Xcode
   ```
3. Xcode'u yeniden açın ve projeyi derleyin

### WebRTC Bağımlılık Hataları

Eğer WebRTC ile ilgili hatalar alıyorsanız:

1. Podfile'ı düzenleyin ve GoogleWebRTC sürümünü kontrol edin
2. Pod'ları yeniden yükleyin:
   ```bash
   pod deintegrate
   pod install
   ```
3. Xcode'u yeniden başlatın ve projeyi derleyin

### Diğer Derleme Hataları

Eğer başka derleme hataları alıyorsanız:

1. Xcode'da Build Settings'e gidin
2. "Valid Architectures" ayarını kontrol edin (arm64 ve x86_64 olmalı)
3. "Excluded Architectures" ayarını kontrol edin (iphonesimulator için arm64 hariç tutulmalı)
4. "Enable Bitcode" ayarını NO olarak ayarlayın
5. "Always Embed Swift Standard Libraries" ayarını YES olarak ayarlayın

## Notlar

- GoogleWebRTC pod'u kullanımdan kaldırılmıştır, ancak şu an için projede kullanılmaktadır.
- Simülatörde derleme yaparken, M1/M2 Mac'lerde "Open in Rosetta" seçeneğini etkinleştirmeniz gerekebilir.
- Xcode'un son sürümünde bazı uyumluluk sorunları olabilir, bu durumda Xcode'u güncelleyin veya eski bir sürüme geçin. 