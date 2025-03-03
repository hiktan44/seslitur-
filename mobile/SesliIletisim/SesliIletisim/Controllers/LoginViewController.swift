import UIKit
import Foundation
import AVFoundation

/**
 * LoginViewController - Giriş Ekranı
 * 
 * Kullanıcının uygulamaya giriş yapabileceği ve hesap oluşturabileceği ekran.
 * Bu ekran hem rehber hem de katılımcı modlarını destekler.
 */
class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private var titleLabel: UILabel!
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var loginButton: UIButton!
    private var registerButton: UIButton!
    private var toggleButton: UIButton!
    private var forgotPasswordButton: UIButton!
    private var errorLabel: UILabel!
    private var tourCodeTextField: UITextField! // Katılımcılar için tur kodu
    private var activityIndicator: UIActivityIndicatorView!
    private var logoImageView: UIImageView!
    
    // Kullanıcı modunu belirler
    public var isGuideLogin: Bool = false
    
    // MARK: - Lifecycle Methods
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
        
        // Aktivite göstergesi
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
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
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
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
        
        // UI güncellemeleri
        errorLabel.isHidden = true
        setLoading(true)
        
        // API ile giriş işlemi - sınıfın kendi metodu üzerinden
        performLogin(email: email, password: password)
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
    
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            loginButton.isEnabled = false
            loginButton.alpha = 0.7
        } else {
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
        }
    }
    
    // MARK: - API Çağrıları
    
    // MARK: - Auth API yanıt modelleri (geçici tanımlar)
    private struct AuthResponse: Codable {
        let token: String
        let user: UserData
    }
    
    private struct UserData: Codable {
        let id: String
        let name: String
        let email: String
        let role: String
    }
    
    private struct TourResponse: Codable {
        let tour: TourData
    }
    
    private struct TourData: Codable {
        let id: String
        let name: String
    }
    
    // API çağrı metodları
    private func performLogin(email: String, password: String) {
        let urlString = "https://api.sesliiletisim.com/api/auth/login"
        let parameters = ["email": email, "password": password]
        
        // API isteği
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            setLoading(false)
            showError("İstek hazırlanamadı")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoading(false)
                
                if let error = error {
                    self.showError("Bağlantı hatası: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.showError("Veri alınamadı")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let authResponse = try decoder.decode(AuthResponse.self, from: data)
                    
                    // Token'ı kaydet
                    UserDefaults.standard.set(authResponse.token, forKey: "authToken")
                    UserDefaults.standard.set(authResponse.user.id, forKey: "userId")
                    UserDefaults.standard.set(authResponse.user.name, forKey: "userName")
                    UserDefaults.standard.set(authResponse.user.role, forKey: "userRole")
                    
                    // Rehber mi katılımcı mı kontrol et
                    let isGuide = authResponse.user.role == "guide"
                    
                    if isGuide {
                        // Rehber girişi başarılı, doğrudan dashboard'a yönlendir
                        self.navigateToDashboard()
                    } else {
                        // Katılımcı ise tur kodunu kontrol et
                        guard let tourCode = self.tourCodeTextField.text, !tourCode.isEmpty else {
                            self.showError("Tur kodunu girin")
                            return
                        }
                        
                        // Tur kodunu doğrula ve tura katıl
                        self.joinTourWithCode(tourCode: tourCode)
                    }
                } catch {
                    self.showError("Giriş başarısız: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    private func joinTourWithCode(tourCode: String) {
        self.setLoading(true)
        
        let urlString = "https://api.sesliiletisim.com/api/tours/join"
        let parameters = ["code": tourCode]
        
        // API isteği
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Token ekle
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            setLoading(false)
            showError("İstek hazırlanamadı")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoading(false)
                
                if let error = error {
                    self.showError("Bağlantı hatası: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.showError("Veri alınamadı")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let tourResponse = try decoder.decode(TourResponse.self, from: data)
                    
                    // Tur bilgilerini kaydet
                    UserDefaults.standard.set(tourResponse.tour.id, forKey: "currentTourId")
                    UserDefaults.standard.set(tourResponse.tour.name, forKey: "currentTourName")
                    
                    // Dashboard'a yönlendir
                    self.navigateToParticipantDashboard()
                } catch {
                    self.showError("Tur bulunamadı: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
} 