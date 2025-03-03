import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let mainVC = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func createMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // Dashboard (Ana Sayfa)
        let dashboardVC = DashboardViewController()
        dashboardVC.tabBarItem = UITabBarItem(title: "Ana Sayfa", image: UIImage(systemName: "house"), tag: 0)
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        
        // Profil
        let profileVC = UIViewController() // Gerçek implementasyon eklenecek
        profileVC.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person"), tag: 1)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        // Ayarlar
        let settingsVC = UIViewController() // Gerçek implementasyon eklenecek
        settingsVC.tabBarItem = UITabBarItem(title: "Ayarlar", image: UIImage(systemName: "gear"), tag: 2)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        tabBarController.viewControllers = [dashboardNav, profileNav, settingsNav]
        
        // Görünümü özelleştir
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
        }
        
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Sahne kapatıldığında çağrılır
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Sahne aktif olduğunda çağrılır
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Sahne pasif duruma geçtiğinde çağrılır
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Uygulama ön plana çıktığında çağrılır
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Uygulama arka plana gittiğinde çağrılır
    }
} 