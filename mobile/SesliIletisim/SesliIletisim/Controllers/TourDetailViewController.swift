import UIKit
import AVFoundation

/**
 * Tur detay ekranı kontrolörü
 * Tur bilgilerini gösterir ve sesli oturumlara katılma işlemlerini yönetir
 */
class TourDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Görüntülenen tur
    var tour: Tour!
    
    /// Tura ait aktif sesli oturum
    var activeSession: VoiceSession?
    
    /// WebRTC servis referansı
    private let webRTCService = WebRTCService.shared
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tourImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let tourNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sesli Oturuma Katıl", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    private let sessionStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let sessionStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.text = "Aktif Oturum"
        return label
    }()
    
    private let sessionStatusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "waveform")
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTourDetails()
        checkActiveSession()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll view ve içerik view ekleme
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // UI elementlerini ekleme
        contentView.addSubview(tourImageView)
        contentView.addSubview(tourNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(joinButton)
        contentView.addSubview(sessionStatusView)
        contentView.addSubview(activityIndicator)
        
        // Oturum durumu görünümü
        sessionStatusView.addSubview(sessionStatusIcon)
        sessionStatusView.addSubview(sessionStatusLabel)
        
        // Auto Layout kısıtlamalarını ayarlama
        NSLayoutConstraint.activate([
            // Scroll view kısıtlamaları
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // İçerik view kısıtlamaları
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Tur resmi kısıtlamaları
            tourImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            tourImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tourImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tourImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Tur adı etiketi kısıtlamaları
            tourNameLabel.topAnchor.constraint(equalTo: tourImageView.bottomAnchor, constant: 16),
            tourNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tourNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Oturum durumu görünümü kısıtlamaları
            sessionStatusView.topAnchor.constraint(equalTo: tourNameLabel.bottomAnchor, constant: 8),
            sessionStatusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sessionStatusView.heightAnchor.constraint(equalToConstant: 28),
            
            // Oturum durumu simgesi kısıtlamaları
            sessionStatusIcon.leadingAnchor.constraint(equalTo: sessionStatusView.leadingAnchor, constant: 8),
            sessionStatusIcon.centerYAnchor.constraint(equalTo: sessionStatusView.centerYAnchor),
            sessionStatusIcon.widthAnchor.constraint(equalToConstant: 16),
            sessionStatusIcon.heightAnchor.constraint(equalToConstant: 16),
            
            // Oturum durumu etiketi kısıtlamaları
            sessionStatusLabel.leadingAnchor.constraint(equalTo: sessionStatusIcon.trailingAnchor, constant: 4),
            sessionStatusLabel.trailingAnchor.constraint(equalTo: sessionStatusView.trailingAnchor, constant: -8),
            sessionStatusLabel.centerYAnchor.constraint(equalTo: sessionStatusView.centerYAnchor),
            
            // Tarih etiketi kısıtlamaları
            dateLabel.topAnchor.constraint(equalTo: sessionStatusView.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Açıklama etiketi kısıtlamaları
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Katılımcı sayısı etiketi kısıtlamaları
            participantsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            participantsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            participantsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Katılma butonu kısıtlamaları
            joinButton.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 24),
            joinButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            joinButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            joinButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Aktivite göstergesi kısıtlamaları
            activityIndicator.centerXAnchor.constraint(equalTo: joinButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: joinButton.centerYAnchor)
        ])
        
        // Buton eylemlerini ayarlama
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration Methods
    
    private func configureTourDetails() {
        tourNameLabel.text = tour.name
        descriptionLabel.text = tour.description
        
        // Tarih formatını ayarlama
        if let startDate = DateFormatter.iso8601.date(from: tour.startDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "tr_TR")
            dateLabel.text = dateFormatter.string(from: startDate)
        }
        
        // Eğer tur resmi varsa, yükle
        if let imageUrl = tour.imageUrl, let url = URL(string: imageUrl) {
            // İlerleyen aşamada bir resim yükleme kütüphanesi kullanılabilir (SDWebImage, Kingfisher vb.)
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.tourImageView.image = image
                    }
                }
            }.resume()
        } else {
            tourImageView.image = UIImage(systemName: "map")
        }
        
        // Eğer aktif bir oturum varsa durumu güncelle
        updateSessionStatus()
    }
    
    private func checkActiveSession() {
        activityIndicator.startAnimating()
        joinButton.setTitle("", for: .normal)
        
        APIService.shared.getActiveVoiceSessions { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.joinButton.setTitle("Sesli Oturuma Katıl", for: .normal)
                
                switch result {
                case .success(let sessions):
                    // Tura ait aktif oturumu bul
                    self?.activeSession = sessions.first(where: { $0.tourId == self?.tour.id })
                    self?.updateSessionStatus()
                    
                case .failure(let error):
                    print("Aktif oturumlar alınamadı: \(error.localizedDescription)")
                    self?.showErrorAlert(message: "Aktif oturumlar alınamadı. Lütfen daha sonra tekrar deneyin.")
                }
            }
        }
    }
    
    private func updateSessionStatus() {
        if let activeSession = activeSession {
            sessionStatusView.isHidden = false
            
            // Katılımcı sayısı bilgisini güncelle
            participantsLabel.text = "\(activeSession.participantCount) kişi katılıyor"
            
            // Buton metnini güncelle
            joinButton.setTitle("Sesli Oturuma Katıl", for: .normal)
            joinButton.backgroundColor = .systemBlue
        } else {
            sessionStatusView.isHidden = true
            participantsLabel.text = "Henüz aktif bir oturum yok"
            
            // Şu anki zaman başlangıç zamanını geçtiyse, "Oturum Oluştur" butonu göster
            if let startDate = DateFormatter.iso8601.date(from: tour.startDate),
               Date() >= startDate {
                joinButton.setTitle("Oturum Oluştur", for: .normal)
                joinButton.backgroundColor = .systemGreen
            } else {
                joinButton.setTitle("Oturum Başlangıcını Bekleyin", for: .normal)
                joinButton.backgroundColor = .systemGray
                joinButton.isEnabled = false
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func joinButtonTapped() {
        if let activeSession = activeSession {
            // Aktif oturuma katıl
            joinVoiceSession(sessionId: activeSession.id)
        } else {
            // Yeni oturum oluştur
            createVoiceSession()
        }
    }
    
    private func createVoiceSession() {
        activityIndicator.startAnimating()
        joinButton.setTitle("", for: .normal)
        
        let newSession = CreateVoiceSession(title: tour.name, tourId: tour.id)
        
        APIService.shared.createVoiceSession(session: newSession) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let session):
                    self?.activeSession = session
                    self?.updateSessionStatus()
                    self?.showSuccessAlert(message: "Sesli oturum başarıyla oluşturuldu. Katılınıyor...")
                    self?.joinVoiceSession(sessionId: session.id)
                    
                case .failure(let error):
                    self?.joinButton.setTitle("Oturum Oluştur", for: .normal)
                    self?.showErrorAlert(message: "Oturum oluşturulamadı: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func joinVoiceSession(sessionId: String) {
        activityIndicator.startAnimating()
        joinButton.setTitle("", for: .normal)
        
        // Önce mikrofon izni iste
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if granted {
                    // WebRTC bağlantısını başlat
                    self.webRTCService.connect(sessionId: sessionId) { result in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            
                            switch result {
                            case .success:
                                // Sesli oturum ekranına geçiş yap
                                let voiceViewController = VoiceSessionViewController()
                                voiceViewController.tour = self.tour
                                voiceViewController.session = self.activeSession
                                self.navigationController?.pushViewController(voiceViewController, animated: true)
                                
                            case .failure(let error):
                                self.joinButton.setTitle("Sesli Oturuma Katıl", for: .normal)
                                self.showErrorAlert(message: "Sesli oturuma katılınamadı: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    self.joinButton.setTitle("Sesli Oturuma Katıl", for: .normal)
                    self.showErrorAlert(message: "Mikrofon erişim izni gereklidir. Lütfen ayarlardan izin verin.")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Başarılı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
} 