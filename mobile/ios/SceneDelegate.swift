import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Sahne oturumu sonlandırıldığında çağrılır
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Sahne aktif olduğunda çağrılır
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Sahne aktif olmaktan çıktığında çağrılır
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Sahne ön plana geçtiğinde çağrılır
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Sahne arka plana geçtiğinde çağrılır
    }
} 