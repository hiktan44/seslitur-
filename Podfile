platform :ios, '14.0'

target 'SesliIletisim' do
  # Dinamik framework'leri kullan
  use_frameworks!
  
  # Podlar
  pod 'Alamofire', '~> 5.5.0'
  pod 'GoogleWebRTC', '~> 1.1.31999'
  pod 'SDWebImage', '~> 5.12.0'
  pod 'KeychainAccess', '~> 4.2.2'
  pod 'Socket.IO-Client-Swift', '~> 16.0.1'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'Starscream', '~> 4.0.4'
  
  target 'SesliIletisimTests' do
    inherit! :search_paths
  end

  target 'SesliIletisimUITests' do
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # iOS 14.0 minimum gereksinimi
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      
      # Bitcode desteğini kapat
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # M1 Mac ve simulator sorunlarını çözmek için mimari ayarları
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      
      # Swift sürümü
      config.build_settings['SWIFT_VERSION'] = '5.0'
      
      # Framework arama yolları
      config.build_settings['FRAMEWORK_SEARCH_PATHS'] ||= ['$(inherited)']
      
      # Diğer bağlayıcı bayrakları
      config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
      
      # Hata ayıklama için
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
end 