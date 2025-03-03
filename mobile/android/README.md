# Sesli İletişim Android Uygulaması

## Proje Hakkında

Bu uygulama, 100-300 kişilik gruplar için gerçek zamanlı sesli iletişim sağlayan bir sistemin Android istemcisidir. WebRTC teknolojisini kullanarak düşük gecikme süresi ve yüksek ses kalitesi sunmayı amaçlar.

## Özellikler

- Gerçek zamanlı sesli iletişim (150ms'den az gecikme)
- 300 kişiye kadar grup desteği
- Şifre korumalı odalar
- Moderatör kontrolü ve konuşma izinleri
- Bluetooth kulaklık desteği
- Arka planda çalışma
- End-to-end şifreleme

## Teknik Özellikler

- WebRTC ile sesli iletişim
- mediasoup SFU (Selective Forwarding Unit) mimarisi
- Opus ses kodeği için optimizasyonlar
- STUN/TURN sunucu desteği
- Düşük bant genişliği koşullarına adaptasyon (20-128 kbps)
- TLS 1.3+ ile şifrelenmiş iletişim

## Kurulum Gereksinimleri

- Android Studio 4.0+
- Android SDK 21+ (Android 5.0 Lollipop ve üzeri)
- Kotlin 1.5+
- Gradle 7.0+

## Bağımlılıklar

```gradle
// app/build.gradle
dependencies {
    // Temel Android bağımlılıkları
    implementation 'androidx.core:core-ktx:1.7.0'
    implementation 'androidx.appcompat:appcompat:1.4.1'
    implementation 'com.google.android.material:material:1.5.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.3'
    
    // Jetpack bileşenleri
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.4.1'
    implementation 'androidx.lifecycle:lifecycle-livedata-ktx:2.4.1'
    implementation 'androidx.navigation:navigation-fragment-ktx:2.4.1'
    implementation 'androidx.navigation:navigation-ui-ktx:2.4.1'
    
    // WebRTC
    implementation 'org.webrtc:google-webrtc:1.0.32006'
    
    // mediasoup client
    implementation 'io.github.haiyangwu:mediasoup-client-android:3.0.8'
    
    // Socket.io ve WebSocket
    implementation 'io.socket:socket.io-client:2.0.1'
    implementation 'com.squareup.okhttp3:okhttp:4.9.3'
    
    // Ağ istekleri
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
    
    // Resim yükleme
    implementation 'com.github.bumptech.glide:glide:4.13.0'
    
    // Dependency Injection
    implementation 'com.google.dagger:hilt-android:2.41'
    kapt 'com.google.dagger:hilt-android-compiler:2.41'
    
    // Kotlin Coroutines
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.0'
    
    // Test bağımlılıkları
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.3'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'
}
```

## Kurulum

1. Depoyu klonlayın:
```
git clone https://github.com/username/voice-communication-app.git
cd voice-communication-app/mobile/android
```

2. Android Studio ile projeyi açın.

3. Gradle sync işlemini çalıştırın.

4. Uygulamayı derleyin ve çalıştırın.

## Proje Yapısı

```
com.example.sesliiletisim/
├── di/                       # Dependency Injection modülleri
├── model/                    # Veri modelleri
│   ├── entity/               # Veritabanı varlıkları
│   ├── request/              # API istek modelleri
│   └── response/             # API yanıt modelleri
├── repository/               # Veri katmanı
│   ├── local/                # Yerel veri kaynakları
│   └── remote/               # Uzak veri kaynakları
├── service/                  # Servisler
│   ├── WebRTCService.kt      # WebRTC servisi
│   ├── SignalingService.kt   # Sinyal servisi
│   └── NotificationService.kt # Bildirim servisi
├── ui/                       # Kullanıcı arayüzü
│   ├── auth/                 # Kimlik doğrulama ekranları
│   │   ├── LoginActivity.kt  # Giriş ekranı
│   │   └── RegisterActivity.kt # Kayıt ekranı
│   ├── dashboard/            # Ana panel
│   ├── group/                # Grup yönetimi
│   ├── session/              # Oturum yönetimi
│   └── admin/                # Admin paneli
├── util/                     # Yardımcı sınıflar
└── MainActivity.kt           # Ana aktivite
```

## WebRTC Entegrasyonu

WebRTC entegrasyonu, `WebRTCService` sınıfı tarafından yönetilir. Bu servis aşağıdaki görevleri yerine getirir:

- Audio oturumunu yapılandırma
- mediasoup SFU ile iletişim
- Transport ve Producer/Consumer yönetimi
- Sinyal protokolü entegrasyonu

```kotlin
// Örnek WebRTC kullanımı
private fun initializeWebRTC() {
    webRTCService = WebRTCService.getInstance(applicationContext)
    webRTCService.delegate = this
    
    // Bir odaya bağlan
    webRTCService.connect(roomId = "sample-room-id", userId = "user-123")
    
    // Mikrofonu aç/kapa
    binding.toggleMicButton.setOnClickListener {
        val isMuted = webRTCService.toggleAudio()
        updateMicrophoneButtonState(isMuted)
    }
}
```

## Görev Arka Plan Servisi

Uygulama, ekran kapalıyken veya arka plandayken bile sesli iletişimi sürdürmek için bir ön plan servisi kullanır.

```kotlin
// Örnek ForegroundService kullanımı
class VoiceCallService : Service() {
    
    private val webRTCService = WebRTCService.getInstance(this)
    private val notificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val roomId = intent?.getStringExtra("roomId") ?: return START_NOT_STICKY
        val userId = intent.getStringExtra("userId") ?: return START_NOT_STICKY
        
        // Ön plan bildirimini oluştur ve başlat
        val notification = createCallNotification()
        startForeground(NOTIFICATION_ID, notification)
        
        // WebRTC servisini başlat
        webRTCService.connect(roomId, userId)
        
        return START_STICKY
    }
    
    // ... Bildirim oluşturma ve kanal yapılandırma yöntemleri ...
}
```

## Ses Ayarları ve Optimizasyonlar

Uygulama, farklı ses cihazları (dahili hoparlör, kulaklık, Bluetooth) için optimize edilmiştir.

```kotlin
private fun setupAudioManager() {
    audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
    
    // Bluetooth kulaklık desteğini etkinleştir
    if (audioManager.isBluetoothScoAvailableOffCall) {
        audioManager.startBluetoothSco()
        audioManager.isBluetoothScoOn = true
    }
    
    // Ses odağını ayarla
    audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
    
    // Hoparlör fonksiyonu
    binding.speakerButton.setOnClickListener {
        val speakerOn = !audioManager.isSpeakerphoneOn
        audioManager.isSpeakerphoneOn = speakerOn
        updateSpeakerButtonState(speakerOn)
    }
}
```

## Sorun Giderme

### Bilinen Sorunlar

1. **Bluetooth Kulaklık Bağlantı Sorunları**:
   - Çözüm: Bluetooth SCO bağlantısını yeniden başlatın.

2. **Arka Planda Ses Kesilmesi**:
   - Çözüm: Pil optimizasyonlarını devre dışı bırakın.

3. **Yüksek Gecikme**:
   - Çözüm: Ağ ayarlarını kontrol edin ve daha düşük bit hızı kullanın.

### Hata Ayıklama

Logcat'te şu etiketleri arayın:
- `WebRTCService`: WebRTC ile ilgili sorunlar için
- `SignalingService`: Sinyal sunucusu iletişimi için
- `AudioManager`: Ses yönetimi sorunları için

## Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## Lisans

Bu proje [LICENSE] lisansı altında lisanslanmıştır.

## İletişim

Sorularınız için: iletisim@example.com 