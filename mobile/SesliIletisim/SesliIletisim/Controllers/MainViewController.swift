import UIKit

/**
 * MainViewController - Uygulamanın ana giriş ekranı
 * 
 * Bu ekran kullanıcıyı karşılayan ilk sayfadır ve tur rehberleri ve katılımcılar için 
 * giriş seçenekleri sunar.
 */
class MainViewController: UIViewController {
    
    private var welcomeLabel: UILabel!
    private var appDescriptionLabel: UILabel!
    private var guideLoginButton: UIButton!
    private var participantLoginButton: UIButton!
    private var registerButton: UIButton!
    private var appLogoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 247/255, alpha: 1.0)
        
        // Logo
        appLogoImageView = UIImageView()
        appLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        appLogoImageView.contentMode = .scaleAspectFit
        appLogoImageView.image = UIImage(systemName: "megaphone.fill")
        appLogoImageView.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        view.addSubview(appLogoImageView)
        
        // Hoşgeldiniz etiketi
        welcomeLabel = UILabel()
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.text = "TurSesli"
        welcomeLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        welcomeLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        welcomeLabel.textAlignment = .center
        view.addSubview(welcomeLabel)
        
        // Uygulama açıklaması
        appDescriptionLabel = UILabel()
        appDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        appDescriptionLabel.text = "Tur rehberleri ve katılımcılar için\ngerçek zamanlı sesli iletişim platformu"
        appDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        appDescriptionLabel.textColor = UIColor.darkGray
        appDescriptionLabel.textAlignment = .center
        appDescriptionLabel.numberOfLines = 0
        view.addSubview(appDescriptionLabel)
        
        // Rehber girişi butonu
        guideLoginButton = UIButton(type: .system)
        guideLoginButton.translatesAutoresizingMaskIntoConstraints = false
        guideLoginButton.setTitle("Rehber Girişi", for: .normal)
        guideLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        guideLoginButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        guideLoginButton.setTitleColor(.white, for: .normal)
        guideLoginButton.layer.cornerRadius = 12
        guideLoginButton.addTarget(self, action: #selector(guideLoginTapped), for: .touchUpInside)
        view.addSubview(guideLoginButton)
        
        // Katılımcı girişi butonu
        participantLoginButton = UIButton(type: .system)
        participantLoginButton.translatesAutoresizingMaskIntoConstraints = false
        participantLoginButton.setTitle("Katılımcı Girişi", for: .normal)
        participantLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        participantLoginButton.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        participantLoginButton.setTitleColor(.white, for: .normal)
        participantLoginButton.layer.cornerRadius = 12
        participantLoginButton.addTarget(self, action: #selector(participantLoginTapped), for: .touchUpInside)
        view.addSubview(participantLoginButton)
        
        // Kayıt butonu
        registerButton = UIButton(type: .system)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Yeni Hesap Oluştur", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        registerButton.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        view.addSubview(registerButton)
        
        // Constraint'ler
        NSLayoutConstraint.activate([
            appLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appLogoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            appLogoImageView.widthAnchor.constraint(equalToConstant: 100),
            appLogoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: appLogoImageView.bottomAnchor, constant: 20),
            
            appDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appDescriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10),
            appDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            appDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            guideLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLoginButton.topAnchor.constraint(equalTo: appDescriptionLabel.bottomAnchor, constant: 40),
            guideLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            guideLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            guideLoginButton.heightAnchor.constraint(equalToConstant: 50),
            
            participantLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            participantLoginButton.topAnchor.constraint(equalTo: guideLoginButton.bottomAnchor, constant: 20),
            participantLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            participantLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            participantLoginButton.heightAnchor.constraint(equalToConstant: 50),
            
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: participantLoginButton.bottomAnchor, constant: 30),
            registerButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func guideLoginTapped() {
        let loginVC = LoginViewController()
        loginVC.isGuideLogin = true
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc private func participantLoginTapped() {
        let loginVC = LoginViewController()
        loginVC.isGuideLogin = false
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc private func registerTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
} 