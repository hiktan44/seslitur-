# Kurulum Talimatları

## Gereksinimler

### Sistem Gereksinimleri
- macOS 12.0 veya üzeri
- Xcode 14.0 veya üzeri
- iOS 13.0+ cihaz veya simülatör
- Git
- Node.js 16.x veya üzeri
- npm 8.x veya üzeri
- CocoaPods

### Geliştirme Ortamı Kurulumu

1. **Xcode Kurulumu**
   - App Store'dan Xcode'u indirin ve kurun
   - Command Line Tools'u yükleyin:
     ```bash
     xcode-select --install
     ```

2. **CocoaPods Kurulumu**
   ```bash
   sudo gem install cocoapods
   ```

3. **Node.js Kurulumu**
   - [Node.js web sitesinden](https://nodejs.org/) indirin ve kurun
   - veya Homebrew ile kurun:
     ```bash
     brew install node
     ```

## Proje Kurulumu

### 1. Repository'yi Klonlama
```bash
git clone https://github.com/hiktan44/SesliIletisim.git
cd SesliIletisim
```

### 2. Backend Kurulumu
```bash
cd backend
npm install
cp .env.example .env
# .env dosyasını düzenleyin
npm run start
```

### 3. iOS Uygulaması Kurulumu
```bash
cd ../SesliIletisim
pod deintegrate  # Eğer daha önce kurulumda sorun yaşandıysa
pod cache clean --all
pod install
```

### 4. Xcode Yapılandırması
1. `SesliIletisim.xcworkspace` dosyasını Xcode ile açın
2. Signing & Capabilities ayarlarını yapılandırın:
   - Team seçin
   - Bundle Identifier'ı düzenleyin
3. Gerekli izinleri `Info.plist`'e ekleyin:
   - Camera Usage Description
   - Microphone Usage Description
   - Photo Library Usage Description

## Derleme ve Test

### Debug Modunda Çalıştırma
1. Xcode'da bir simülatör veya cihaz seçin
2. Build (⌘+B) yapın
3. Run (⌘+R) ile çalıştırın

### Release Build Oluşturma
1. Xcode'da "Any iOS Device" seçin
2. Product > Archive menüsünü kullanın
3. Organizer'dan dağıtım yöntemini seçin

## Sorun Giderme

### Pod Kurulum Sorunları
```bash
pod deintegrate
pod cache clean --all
pod install
```

### Derleme Hataları
1. Clean Build Folder (Shift + Command + K)
2. Derived Data klasörünü temizleyin:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Projeyi yeniden derleyin

### Bağımlılık Sorunları
1. Pods klasörünü silin
2. Podfile.lock dosyasını silin
3. Pod'ları yeniden yükleyin:
   ```bash
   pod install
   ```

## Güvenlik Notları

1. API anahtarlarını ve hassas bilgileri asla kaynak koduna eklemeyin
2. `.env` dosyasını git'e eklemeyin
3. Geliştirme sertifikalarını güvenli şekilde saklayın
4. Debug modunda hassas logları kapatın

## Canlı Ortam (Production) Hazırlığı

1. Release konfigürasyonunu kontrol edin
2. API URL'lerini production değerleriyle güncelleyin
3. Analytics ve crash reporting sistemlerini etkinleştirin
4. Push notification sertifikalarını yapılandırın

## Yardım ve Destek

Sorun yaşarsanız:
1. GitHub Issues bölümünü kontrol edin
2. Stack Overflow'da arama yapın
3. Takımla iletişime geçin: [email protected] 