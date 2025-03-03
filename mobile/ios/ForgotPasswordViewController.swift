import UIKit

class ForgotPasswordViewController: UIViewController {
    
    // UI Bileşenleri
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailTextField = UITextField()
    private let resetButton = UIButton(type: .system)
    private let backToLoginButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private let successLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Şifremi Unuttum"
        
        // Başlık etiketi
        titleLabel.text = "Şifrenizi mi Unuttunuz?"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Alt başlık etiketi
        subtitleLabel.text = "E-posta adresinizi girin, şifre sıfırlama bağlantısı göndereceğiz."
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // E-posta metin alanı
        emailTextField.placeholder = "E-posta Adresi"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Hata etiketi
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // Başarı etiketi
        successLabel.textColor = .systemGreen
        successLabel.textAlignment = .center
        successLabel.font = UIFont.systemFont(ofSize: 14)
        successLabel.numberOfLines = 0
        successLabel.isHidden = true
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successLabel)
        
        // Sıfırlama butonu
        resetButton.setTitle("Şifre Sıfırlama Bağlantısı Gönder", for: .normal)
        resetButton.backgroundColor = UIColor.systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetButton)
        
        // Giriş sayfasına dön butonu
        backToLoginButton.setTitle("Giriş Sayfasına Dön", for: .normal)
        backToLoginButton.addTarget(self, action: #selector(backToLoginTapped), for: .touchUpInside)
        backToLoginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backToLoginButton)
        
        // Kısıtlamalar
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            successLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            successLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 30),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            
            backToLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backToLoginButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20),
        ])
    }
    
    @objc private func resetTapped() {
        // Form doğrulama
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Lütfen e-posta adresinizi girin.")
            return
        }
        
        // E-posta formatı kontrolü
        if !isValidEmail(email) {
            showError("Lütfen geçerli bir e-posta adresi girin.")
            return
        }
        
        // Hata etiketini gizle
        errorLabel.isHidden = true
        
        // API'ye istek gönderme simülasyonu
        resetButton.isEnabled = false
        resetButton.alpha = 0.5
        
        // Gerçek uygulamada burada API'ye istek gönderilir
        // Burada başarılı olduğunu varsayalım
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showSuccess("Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin.")
            self.resetButton.isEnabled = true
            self.resetButton.alpha = 1
        }
    }
    
    @objc private func backToLoginTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        successLabel.isHidden = true
    }
    
    private func showSuccess(_ message: String) {
        successLabel.text = message
        successLabel.isHidden = false
        errorLabel.isHidden = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
} 