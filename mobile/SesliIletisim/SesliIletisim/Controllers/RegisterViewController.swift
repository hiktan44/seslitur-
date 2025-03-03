import UIKit

class RegisterViewController: UIViewController {
    
    // UI Bileşenleri
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let termsSwitch = UISwitch()
    private let termsLabel = UILabel()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Kayıt Ol"
        
        // Başlık etiketi
        titleLabel.text = "Yeni Hesap Oluştur"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // İsim metin alanı
        nameTextField.placeholder = "Ad Soyad"
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocapitalizationType = .words
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
        
        // E-posta metin alanı
        emailTextField.placeholder = "E-posta Adresi"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Şifre metin alanı
        passwordTextField.placeholder = "Şifre (en az 5 karakter)"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // Şifre onay metin alanı
        confirmPasswordTextField.placeholder = "Şifreyi Tekrar Girin"
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmPasswordTextField)
        
        // Hata etiketi
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // Şartlar ve koşullar anahtarı
        termsSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(termsSwitch)
        
        // Şartlar ve koşullar etiketi
        termsLabel.text = "Kullanım koşullarını ve gizlilik politikasını kabul ediyorum."
        termsLabel.font = UIFont.systemFont(ofSize: 14)
        termsLabel.numberOfLines = 0
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsTapped))
        termsLabel.addGestureRecognizer(tapGesture)
        view.addSubview(termsLabel)
        
        // Kayıt butonu
        registerButton.setTitle("Kayıt Ol", for: .normal)
        registerButton.backgroundColor = UIColor.systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registerButton)
        
        // Kısıtlamalar
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            termsSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            termsSwitch.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            
            termsLabel.leadingAnchor.constraint(equalTo: termsSwitch.trailingAnchor, constant: 10),
            termsLabel.centerYAnchor.constraint(equalTo: termsSwitch.centerYAnchor),
            termsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func registerTapped() {
        // Form doğrulama
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showError("Lütfen tüm alanları doldurun.")
            return
        }
        
        // E-posta formatı kontrolü
        if !isValidEmail(email) {
            showError("Lütfen geçerli bir e-posta adresi girin.")
            return
        }
        
        // Şifre uzunluğu kontrolü
        if password.count < 5 {
            showError("Şifre en az 5 karakter olmalıdır.")
            return
        }
        
        // Şifre eşleşme kontrolü
        if password != confirmPassword {
            showError("Şifreler eşleşmiyor.")
            return
        }
        
        // Şartlar ve koşullar kontrolü
        if !termsSwitch.isOn {
            showError("Devam etmek için kullanım koşullarını kabul etmelisiniz.")
            return
        }
        
        // Kayıt işlemi - Gerçek uygulamada API'ye istek gönderilir
        // Burada başarılı olduğunu varsayalım
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func termsTapped() {
        let alertController = UIAlertController(title: "Kullanım Koşulları", message: "Bu uygulama, grup iletişimi için tasarlanmıştır. Kullanıcılar, diğer kullanıcıların kişisel haklarına saygı göstermeyi ve platformu kötüye kullanmamayı kabul eder.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alertController, animated: true)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
} 