#!/bin/bash

# Hata durumunda script'i durdur
set -e

echo "⚙️ Proje Konfigürasyon Düzeltme Aracı ⚙️"
echo "--------------------------------------"

# Proje konfigürasyonu
PROJECT_NAME="SesliIletisim"
PROJECT_PATH="./${PROJECT_NAME}.xcodeproj/project.pbxproj"

echo "🔍 Proje dosyasını kontrol ediyorum: ${PROJECT_PATH}"

if [ ! -f "$PROJECT_PATH" ]; then
    echo "❌ Proje dosyası bulunamadı: $PROJECT_PATH"
    exit 1
fi

# Yedek al
cp "$PROJECT_PATH" "${PROJECT_PATH}.backup"
echo "✅ Proje dosyası yedeği alındı: ${PROJECT_PATH}.backup"

# 1. Temizlik: Eski framework referanslarını temizle
echo "🧹 Eski framework referanslarını temizliyorum..."

# 2. Xcconfig entegrasyonu için gerekli değişiklikleri yap
echo "🔧 Xcconfig entegrasyonunu yapıyorum..."

# Başlangıç build ayarlarına custom xcconfig'i ekle
sed -i '' 's/buildSettings = {/buildSettings = { XCCONFIG_INCLUDE = custom.xcconfig;/g' "$PROJECT_PATH"

# Tüm konfigürasyonlara custom xcconfig'i dahil et
sed -i '' 's/baseConfigurationReference = [0-9A-Z]*; \/\* \(.*\)\.xcconfig \*\//baseConfigurationReference = 8A7DEEB82ECCA; \/\* custom.xcconfig \*\//g' "$PROJECT_PATH"

# 3. Framework arama yollarını düzelt
echo "🔧 Framework arama yollarını düzenliyorum..."

# Şimdi bir ruby script ile daha karmaşık değişiklikleri yapalım
cat > update_config.rb << 'EOF'
#!/usr/bin/env ruby
require 'xcodeproj'

# Proje yolu
project_path = 'SesliIletisim.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Ana hedefi bul
main_target = project.targets.find { |t| t.name == 'SesliIletisim' }

if main_target
  main_target.build_configurations.each do |config|
    # Build settings düzenlemeleri
    settings = config.build_settings
    
    # Framework search paths
    if settings['FRAMEWORK_SEARCH_PATHS']
      paths = settings['FRAMEWORK_SEARCH_PATHS']
      if paths.is_a?(Array)
        # Paths diziyse yeni path ekle
        unless paths.include?("$(SRCROOT)/Pods/**")
          paths << "$(SRCROOT)/Pods/**"
        end
        unless paths.include?("${PODS_CONFIGURATION_BUILD_DIR}")
          paths << "${PODS_CONFIGURATION_BUILD_DIR}"
        end
      else
        # Paths dizi değilse, dizi olarak yeniden tanımla
        settings['FRAMEWORK_SEARCH_PATHS'] = ["$(inherited)", "$(SRCROOT)/Pods/**", "${PODS_CONFIGURATION_BUILD_DIR}"]
      end
    else
      # Hiç framework search path yoksa ekle
      settings['FRAMEWORK_SEARCH_PATHS'] = ["$(inherited)", "$(SRCROOT)/Pods/**", "${PODS_CONFIGURATION_BUILD_DIR}"]
    end
    
    # LD FLAGS
    if !settings['OTHER_LDFLAGS'] || settings['OTHER_LDFLAGS'].empty?
      settings['OTHER_LDFLAGS'] = '$(inherited) -ObjC -l"c++" -framework "Pods_SesliIletisim"'
    elsif !settings['OTHER_LDFLAGS'].include?('framework "Pods_SesliIletisim"')
      if settings['OTHER_LDFLAGS'].is_a?(Array)
        settings['OTHER_LDFLAGS'] << '-framework "Pods_SesliIletisim"'
      else
        settings['OTHER_LDFLAGS'] += ' -framework "Pods_SesliIletisim"'
      end
    end
    
    # Diğer önemli ayarlar
    settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
    settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) /usr/lib/swift @executable_path/Frameworks @loader_path/Frameworks'
    settings['DEFINES_MODULE'] = 'YES'
    settings['CLANG_ENABLE_MODULES'] = 'YES'
    settings['SWIFT_VERSION'] = '5.0'
    settings['ENABLE_BITCODE'] = 'NO'
  end
  
  # Değişiklikleri kaydet
  project.save
  puts "✅ Xcode proje ayarları güncellendi."
else
  puts "❌ SesliIletisim hedefi bulunamadı."
end
EOF

if command -v ruby > /dev/null 2>&1; then
    if gem list -i xcodeproj > /dev/null 2>&1; then
        ruby update_config.rb
    else
        echo "⚠️ xcodeproj gem'i bulunamadı. Manuel olarak ayarları yapmalısınız."
        echo "   Gem'i kurmak için: gem install xcodeproj"
    fi
else
    echo "⚠️ Ruby bulunamadı. Manuel olarak ayarları yapmalısınız."
fi

rm -f update_config.rb

# 4. Proje yapısı güncelleme: Asistanı çalıştır
echo "🔧 Proje yapısı güncelleniyor..."

# Temizlik
echo "🧹 Xcode önbelleğini temizliyorum..."
defaults delete com.apple.dt.Xcode IDEIndexDisable 2>/dev/null || true
defaults delete com.apple.dt.Xcode IDEIndexEnable 2>/dev/null || true

# Son temizlik işlemleri
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

echo -e "\n✅ Proje konfigürasyon düzeltme tamamlandı! Şimdi şunları yapın:"
echo "1. Projeyi Xcode'da açın: open ${PROJECT_NAME}.xcworkspace"
echo "2. Product > Clean Build Folder yapın."
echo "3. Projeyi derleyin."
echo ""
echo "⚠️ Eğer hata devam ederse:"
echo "1. Xcode'da proje ayarlarına gidin (Project Settings > Build Settings)."
echo "2. 'Framework Search Paths' ayarını kontrol edin, eksik yollar varsa ekleyin."
echo "3. 'Other Linker Flags' ayarını kontrol edin, '-framework \"Pods_SesliIletisim\"' ekleyin." 