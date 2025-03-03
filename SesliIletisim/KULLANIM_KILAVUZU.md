# Sesli İletişim iOS Uygulaması Kullanım Kılavuzu

## Başlangıç 

Bu doküman, Sesli İletişim iOS uygulamasının nasıl kurulacağını ve kullanılacağını açıklar.

## Kurulum

### Geliştirici Kurulumu

1. Proje dosyalarını bilgisayarınıza indirin
2. Terminal'de SesliIletisim klasörüne gidin
3. XCode'u açın ve SesliIletisim.xcodeproj dosyasını açın:
   ```
   open SesliIletisim.xcodeproj
   ```
4. Simülatörü veya bağlı bir iOS cihazını hedef olarak seçin
5. "Run" butonuna tıklayarak uygulamayı çalıştırın

### Son Kullanıcı Kurulumu

Uygulama App Store'a yüklendiğinde, kullanıcılar doğrudan indirip kullanabilecektir.

## Giriş ve Kayıt İşlemleri

### Kayıt Olma

1. Uygulama ana ekranından "Kaydol" butonuna tıklayın
2. Ad Soyad, E-posta ve Şifre bilgilerinizi girin
3. Şifreniz en az 5 karakterden oluşmalıdır
4. Kullanım koşullarını kabul edin
5. "Kaydol" butonuna tıklayın

### Normal Kullanıcı Girişi

1. Ana ekrandan "Giriş Yap" butonuna tıklayın
2. E-posta ve şifrenizi girin
3. "Giriş Yap" butonuna tıklayın

### Admin Girişi

1. Ana ekrandan "Giriş Yap" butonuna tıklayın
2. E-posta olarak "admin@example.com" ve şifre olarak "12345" girin
3. "Admin olarak giriş yap" seçeneğini etkinleştirin
4. "Giriş Yap" butonuna tıklayın

### Şifre Sıfırlama

1. Giriş ekranında "Şifremi Unuttum" bağlantısına tıklayın
2. E-posta adresinizi girin
3. "Şifremi Sıfırla" butonuna tıklayın
4. E-posta adresinize gönderilen bağlantıyı takip edin

## Kullanıcı Arayüzü

### Ana Ekran (Dashboard)

Kullanıcı başarıyla giriş yaptıktan sonra ana ekran görüntülenir. Bu ekranda:

- Aktif oturumlar
- Yaklaşan oturumlar
- Yeni oturum oluşturma butonu

bulunur.

### Oturuma Katılma

1. Ana ekranda aktif bir oturuma tıklayın
2. "Katıl" butonuna tıklayın
3. Mikrofon izni isteğini onaylayın
4. Oturum arayüzü yüklenecektir

### Oturum Arayüzü

Oturum arayüzünde şu özellikler bulunur:

- Katılımcı listesi
- Mikrofon açma/kapatma butonu
- Sessize alma / sesini açma kontrolleri
- Oturumdan ayrılma butonu
- Ses kalitesi ayarları

### Admin Paneli

Admin olarak giriş yapıldığında erişilebilen panel şu bölümlerden oluşur:

- Genel istatistikler (kullanıcı, grup, oturum sayıları)
- Kullanıcı yönetimi
- Grup yönetimi
- Oturum yönetimi
- Sistem ayarları
- Raporlar

## Sorun Giderme

### Bilinen Sorunlar ve Çözümleri

1. Mikrofon çalışmıyor:
   - Telefonunuzun ayarlarından uygulamanın mikrofon iznini kontrol edin
   - Bluetooth kulaklık kullanıyorsanız bağlantısını kontrol edin

2. Ses kalitesi düşük:
   - İnternet bağlantınızı kontrol edin
   - Ses kalitesi ayarlarını "Yüksek" olarak değiştirin

3. Uygulama donuyor veya kapanıyor:
   - Uygulamayı tamamen kapatıp yeniden başlatın
   - Telefonunuzu yeniden başlatın

### Destek

Teknik sorunlar için:
- E-posta: support@example.com
- Web: www.example.com/support

## Gizlilik ve Güvenlik

Sesli İletişim uygulaması tüm ses iletişimini uçtan uca şifreler. Kullanıcı bilgileri GDPR ve KVKK düzenlemelerine uygun olarak işlenir ve saklanır.

## Performans Tavsiyesi

En iyi performans için:
- Kararlı bir internet bağlantısı kullanın (WiFi tercih edilir)
- Kaliteli kulaklık kullanın
- Telefon bataryasının yeterli olduğundan emin olun
- Arka planda çok sayıda uygulama çalıştırmaktan kaçının 