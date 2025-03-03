import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // UIWindow ve root view controller'ı yapılandırma
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let dashboardVC = DashboardViewController()
        let navigationController = UINavigationController(rootViewController: dashboardVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Scene oturumu sonlandığında çağrılır
        // Bu, uygulamanın sonlandırıldığı anlamına gelmez, sadece scene'in arka plana alındığını gösterir
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Scene aktif hale geldiğinde çağrılır
        // Uygulama ön plana geldiğinde burada gerekli işlemleri yapabilirsiniz
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Scene aktif olmaktan çıktığında çağrılır
        // Örneğin bir telefon çağrısı geldiğinde veya başka bir uygulama ön plana çıktığında
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Scene ön plana çıkacağı zaman çağrılır
        // Arka plandan ön plana geçiş sırasında gerekli işlemleri yapabilirsiniz
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Scene arka plana geçtiğinde çağrılır
        // Veri kaydetme, kaynakları serbest bırakma gibi işlemleri burada yapabilirsiniz
    }
} 