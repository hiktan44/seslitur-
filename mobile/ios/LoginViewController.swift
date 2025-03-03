import UIKit

class LoginViewController: UIViewController {
    
    // UI Bileşenleri
    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let adminLoginSwitch = UISwitch()
    private let adminLoginLabel = UILabel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Giriş Yap"
        
        // Başlık etiketi
        titleLabel.text = "Sesli İletişim Platformuna Hoş Geldiniz"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // E-posta metin alanı
        emailTextField.placeholder = "E-posta Adresi"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Şifre metin alanı
        passwordTextField.placeholder = "Şifre"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // Admin giriş anahtarı
        adminLoginSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adminLoginSwitch)
        
        // Admin giriş etiketi
        adminLoginLabel.text = "Admin olarak giriş yap"
        adminLoginLabel.font = UIFont.systemFont(ofSize: 14)
        adminLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adminLoginLabel)
        
        // Hata etiketi
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // Giriş butonu
        loginButton.setTitle("Giriş Yap", for: .normal)
        loginButton.backgroundColor = UIColor.systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // Şifremi unuttum butonu
        forgotPasswordButton.setTitle("Şifremi Unuttum", for: .normal)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(forgotPasswordButton)
        
        // Admin giriş bilgileri
        let infoLabel = UILabel()
        infoLabel.text = "Admin Giriş Bilgileri:\nE-posta: admin@example.com\nŞifre: 12345"
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.numberOfLines = 0
        infoLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        infoLabel.layer.cornerRadius = 8
        infoLabel.clipsToBounds = true
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        
        // Kısıtlamalar
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            infoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            adminLoginSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            adminLoginSwitch.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            
            adminLoginLabel.leadingAnchor.constraint(equalTo: adminLoginSwitch.trailingAnchor, constant: 10),
            adminLoginLabel.centerYAnchor.constraint(equalTo: adminLoginSwitch.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: adminLoginSwitch.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("E-posta ve şifre alanları boş olamaz.")
            return
        }
        
        // Admin kontrolü
        let isAdminLogin = adminLoginSwitch.isOn
        if (isAdminLogin || email == "admin@example.com") && password != "12345" {
            showError("Admin hesabı için şifre 12345 olmalıdır.")
            return
        }
        
        // Giriş işlemi
        // Gerçek uygulamada API'ye istek gönderilir
        if (isAdminLogin || email == "admin@example.com") && password == "12345" {
            // Admin girişi başarılı
            navigateToDashboard(isAdmin: true)
        } else {
            // Normal kullanıcı girişi
            // Burada gerçek bir API çağrısı yapılacak
            // Şimdilik başarılı kabul ediyoruz
            navigateToDashboard(isAdmin: false)
        }
    }
    
    @objc private func forgotPasswordTapped() {
        let forgotPasswordVC = ForgotPasswordViewController()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func navigateToDashboard(isAdmin: Bool) {
        let dashboardVC = DashboardViewController(isAdmin: isAdmin)
        navigationController?.setViewControllers([dashboardVC], animated: true)
    }
} 