import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Uygulama başlatıldığında çalışan ilk metod
        // Burada uygulama başlangıç konfigürasyonları yapılabilir
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Scene yapılandırması için çağrılır
        // Yeni bir scene oluşturulacağı zaman bu metod çalışır
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Kullanıcı tarafından kapatılan scene'leri yönetmek için çağrılır
        // iOS13 ve üzeri için birden fazla scene yönetimi için gereklidir
    }
} 