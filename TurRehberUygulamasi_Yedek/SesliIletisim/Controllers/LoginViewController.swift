import UIKit

/**
 * LoginViewController - Kullanıcı giriş ekranı
 * 
 * Bu ekran rehber ve katılımcıların giriş yapmasını sağlar.
 * Kullanıcı tipi (rehber/katılımcı) önceki ekrandan belirlenir.
 */
class LoginViewController: UIViewController {
    
    // MARK: - Properties
    var isGuideLogin = false
    
    private var titleLabel: UILabel!
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var loginButton: UIButton!
    private var forgotPasswordButton: UIButton!
    private var errorLabel: UILabel!
    private var tourCodeTextField: UITextField! // Katılımcılar için tur kodu
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 247/255, alpha: 1.0)
        
        // Başlık etiketi
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = isGuideLogin ? "Rehber Girişi" : "Katılımcı Girişi"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = isGuideLogin ? 
            UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0) : 
            UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        view.addSubview(titleLabel)
        
        // E-posta giriş alanı
        emailTextField = UITextField()
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "E-posta"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        view.addSubview(emailTextField)
        
        // Şifre giriş alanı
        passwordTextField = UITextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Şifre"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        
        // Katılımcılar için tur kodu alanı
        if !isGuideLogin {
            tourCodeTextField = UITextField()
            tourCodeTextField.translatesAutoresizingMaskIntoConstraints = false
            tourCodeTextField.placeholder = "Tur Kodu"
            tourCodeTextField.borderStyle = .roundedRect
            tourCodeTextField.autocapitalizationType = .allCharacters
            tourCodeTextField.autocorrectionType = .no
            view.addSubview(tourCodeTextField)
        }
        
        // Giriş butonu
        loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Giriş Yap", for: .normal)
        loginButton.backgroundColor = isGuideLogin ? 
            UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0) : 
            UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.layer.cornerRadius = 12
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        // Şifremi unuttum butonu
        forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitle("Şifremi Unuttum", for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        view.addSubview(forgotPasswordButton)
        
        // Hata etiketi
        errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .systemRed
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
        
        // Constraint'ler
        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ]
        
        var additionalConstraints: [NSLayoutConstraint] = []
        
        if !isGuideLogin {
            // Tur kodu alanı constraint'leri (sadece katılımcı girişinde)
            additionalConstraints = [
                tourCodeTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
                tourCodeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                tourCodeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                tourCodeTextField.heightAnchor.constraint(equalToConstant: 50),
                
                loginButton.topAnchor.constraint(equalTo: tourCodeTextField.bottomAnchor, constant: 40),
                errorLabel.topAnchor.constraint(equalTo: tourCodeTextField.bottomAnchor, constant: 10)
            ]
        } else {
            // Rehber girişinde daha az alan
            additionalConstraints = [
                loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40)
            ]
        }
        
        let finalConstraints = constraints + additionalConstraints + [
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(finalConstraints)
    }
    
    // MARK: - Actions
    @objc private func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("E-posta adresinizi girin")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Şifrenizi girin")
            return
        }
        
        // Katılımcı girişinde tur kodu kontrolü
        if !isGuideLogin {
            guard let tourCode = tourCodeTextField.text, !tourCode.isEmpty else {
                showError("Tur kodunu girin")
                return
            }
            
            // Demo amaçlı basit bir kontrol
            if tourCode.count < 4 {
                showError("Geçersiz tur kodu")
                return
            }
        }
        
        // Demo giriş bilgileri kontrolü
        if isGuideLogin {
            // Rehber girişi
            if email == "rehber@example.com" && password == "12345" {
                navigateToDashboard()
            } else {
                showError("Geçersiz giriş bilgileri")
            }
        } else {
            // Katılımcı girişi
            if email == "katilimci@example.com" && password == "12345" {
                navigateToParticipantDashboard()
            } else {
                showError("Geçersiz giriş bilgileri")
            }
        }
    }
    
    @objc private func forgotPasswordTapped() {
        let forgotPasswordVC = ForgotPasswordViewController()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateToDashboard() {
        let dashboardVC = DashboardViewController()
        dashboardVC.userMode = .guide
        navigationController?.setViewControllers([dashboardVC], animated: true)
    }
    
    private func navigateToParticipantDashboard() {
        let dashboardVC = DashboardViewController()
        dashboardVC.userMode = .participant
        navigationController?.setViewControllers([dashboardVC], animated: true)
    }
    
    // MARK: - Helper Methods
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
} 