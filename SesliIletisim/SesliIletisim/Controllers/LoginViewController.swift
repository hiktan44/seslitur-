import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Doğrudan dashboard'a yönlendir
        let dashboardVC = DashboardViewController()
        navigationController?.setViewControllers([dashboardVC], animated: false)
    }
}