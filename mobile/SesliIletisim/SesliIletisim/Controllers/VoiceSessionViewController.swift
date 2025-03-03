import UIKit
import AVFoundation

/**
 * Sesli oturum ekranı kontrolörü
 * Sesli oturumları yönetir ve kullanıcıların iletişimini sağlar
 */
class VoiceSessionViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Görüntülenen tur
    var tour: Tour!
    
    /// Aktif sesli oturum
    var session: VoiceSession!
    
    /// WebRTC servis referansı
    private let webRTCService = WebRTCService.shared
    
    /// Katılımcı listesi
    private var participants: [String: String] = [:]
    
    /// Kullanıcı mikrofonunun açık olup olmadığı
    private var isMicrophoneEnabled = false
    
    /// Kullanıcının hoparlör modunun açık olup olmadığı
    private var isSpeakerModeEnabled = true
    
    /// Oturumun bitmesini onaylama mesajı gösterilip gösterilmediği
    private var isEndSessionConfirmationShown = false
    
    // MARK: - UI Elements
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let tourNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private let participantCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(ParticipantCell.self, forCellReuseIdentifier: "ParticipantCell")
        return tableView
    }()
    
    private let controlsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "mic.slash.fill", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let speakerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "speaker.wave.2.fill", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let endCallButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "phone.down.fill", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let raiseHandButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "hand.raised.fill", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemOrange
        button.tintColor = .white
        button.layer.cornerRadius = 25
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSession()
        setupNotifications()
        
        // Default olarak mikrofonu kapalı, hoparlörü açık olarak başlat
        toggleMicrophone(enabled: false)
        toggleSpeakerMode(enabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Ekrandan çıkarken oturumla bağlantıyı kes
        if isMovingFromParent && !isEndSessionConfirmationShown {
            disconnectFromSession()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation bar ayarları
        navigationItem.title = "Sesli Oturum"
        navigationItem.largeTitleDisplayMode = .never
        
        // Geri düğmesini özelleştirme
        let backButton = UIBarButtonItem(title: "Kapat", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        // UI elementlerini ekleme
        view.addSubview(headerView)
        headerView.addSubview(tourNameLabel)
        headerView.addSubview(participantCountLabel)
        
        view.addSubview(tableView)
        
        view.addSubview(controlsContainerView)
        controlsContainerView.addSubview(microphoneButton)
        controlsContainerView.addSubview(speakerButton)
        controlsContainerView.addSubview(endCallButton)
        controlsContainerView.addSubview(raiseHandButton)
        
        // TableView delegasyonu
        tableView.delegate = self
        tableView.dataSource = self
        
        // Auto Layout kısıtlamalarını ayarlama
        NSLayoutConstraint.activate([
            // Header view kısıtlamaları
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Tur adı etiketi kısıtlamaları
            tourNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            tourNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            tourNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Katılımcı sayısı etiketi kısıtlamaları
            participantCountLabel.topAnchor.constraint(equalTo: tourNameLabel.bottomAnchor, constant: 4),
            participantCountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            participantCountLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Tablo görünümü kısıtlamaları
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Kontrol konteyneri görünümü kısıtlamaları
            controlsContainerView.heightAnchor.constraint(equalToConstant: 100),
            controlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: controlsContainerView.topAnchor),
            
            // Mikrofon butonu kısıtlamaları
            microphoneButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            microphoneButton.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 40),
            microphoneButton.widthAnchor.constraint(equalToConstant: 50),
            microphoneButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Hoparlör butonu kısıtlamaları
            speakerButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            speakerButton.leadingAnchor.constraint(equalTo: microphoneButton.trailingAnchor, constant: 20),
            speakerButton.widthAnchor.constraint(equalToConstant: 50),
            speakerButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Görüşmeyi sonlandır butonu kısıtlamaları
            endCallButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            endCallButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -40),
            endCallButton.widthAnchor.constraint(equalToConstant: 50),
            endCallButton.heightAnchor.constraint(equalToConstant: 50),
            
            // El kaldır butonu kısıtlamaları
            raiseHandButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            raiseHandButton.trailingAnchor.constraint(equalTo: endCallButton.leadingAnchor, constant: -20),
            raiseHandButton.widthAnchor.constraint(equalToConstant: 50),
            raiseHandButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Buton eylemlerini ayarlama
        microphoneButton.addTarget(self, action: #selector(microphoneButtonTapped), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(speakerButtonTapped), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)
        raiseHandButton.addTarget(self, action: #selector(raiseHandButtonTapped), for: .touchUpInside)
    }
    
    private func configureSession() {
        // Oturum bilgilerini ayarla
        tourNameLabel.text = tour.name
        updateParticipantCount()
        
        // Katılımcıları API'den al
        fetchParticipants()
    }
    
    private func setupNotifications() {
        // Katılımcı olaylarını dinle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleParticipantJoined),
            name: NSNotification.Name("ParticipantJoined"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleParticipantLeft),
            name: NSNotification.Name("ParticipantLeft"),
            object: nil
        )
    }
    
    private func fetchParticipants() {
        // Katılımcıları API'den al (WebRTCService üzerinden)
        participants = webRTCService.getParticipants()
        tableView.reloadData()
    }
    
    private func updateParticipantCount() {
        let count = participants.count
        participantCountLabel.text = "\(count) katılımcı"
    }
    
    // MARK: - Action Methods
    
    @objc private func backButtonTapped() {
        showEndSessionConfirmation()
    }
    
    @objc private func microphoneButtonTapped() {
        // Mikrofon durumunu tersine çevir
        toggleMicrophone(enabled: !isMicrophoneEnabled)
    }
    
    @objc private func speakerButtonTapped() {
        // Hoparlör modunu tersine çevir
        toggleSpeakerMode(enabled: !isSpeakerModeEnabled)
    }
    
    @objc private func endCallButtonTapped() {
        showEndSessionConfirmation()
    }
    
    @objc private func raiseHandButtonTapped() {
        // El kaldırma özelliği için WebRTC servisi üzerinden işlem yap
        // (İlerleyen aşamada eklenmeli)
        showToast(message: "El kaldırma işlevi yakında eklenecek")
    }
    
    @objc private func handleParticipantJoined(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let id = userInfo["id"] as? String,
              let displayName = userInfo["displayName"] as? String else { return }
        
        // Yeni katılımcıyı listeye ekle
        participants[id] = displayName
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateParticipantCount()
            self.showToast(message: "\(displayName) katıldı")
        }
    }
    
    @objc private func handleParticipantLeft(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let id = userInfo["id"] as? String else { return }
        
        // Ayrılan katılımcının adını al
        let displayName = participants[id] ?? "Katılımcı"
        
        // Katılımcıyı listeden çıkar
        participants.removeValue(forKey: id)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateParticipantCount()
            self.showToast(message: "\(displayName) ayrıldı")
        }
    }
    
    // MARK: - Helper Methods
    
    private func toggleMicrophone(enabled: Bool) {
        isMicrophoneEnabled = enabled
        
        // WebRTC servisi üzerinden mikrofonu aç/kapat
        webRTCService.enableMicrophone(enabled)
        
        // Buton görünümünü güncelle
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        if enabled {
            microphoneButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: config), for: .normal)
            microphoneButton.backgroundColor = .systemGreen
        } else {
            microphoneButton.setImage(UIImage(systemName: "mic.slash.fill", withConfiguration: config), for: .normal)
            microphoneButton.backgroundColor = .systemRed
        }
    }
    
    private func toggleSpeakerMode(enabled: Bool) {
        isSpeakerModeEnabled = enabled
        
        // Ses çıkış modunu değiştir
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                enabled ? .playAndRecord : .playAndRecord,
                mode: .voiceChat,
                options: enabled ? [.defaultToSpeaker, .allowBluetooth] : [.allowBluetooth]
            )
            try audioSession.setActive(true)
            
            // Buton görünümünü güncelle
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            if enabled {
                speakerButton.setImage(UIImage(systemName: "speaker.wave.2.fill", withConfiguration: config), for: .normal)
                speakerButton.backgroundColor = .systemBlue
            } else {
                speakerButton.setImage(UIImage(systemName: "ear", withConfiguration: config), for: .normal)
                speakerButton.backgroundColor = .systemGray
            }
        } catch {
            print("Ses çıkış modu değiştirilemedi: \(error.localizedDescription)")
        }
    }
    
    private func showEndSessionConfirmation() {
        isEndSessionConfirmationShown = true
        
        let alert = UIAlertController(
            title: "Oturumdan Ayrıl",
            message: "Sesli oturumdan ayrılmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel) { _ in
            self.isEndSessionConfirmationShown = false
        })
        
        alert.addAction(UIAlertAction(title: "Ayrıl", style: .destructive) { _ in
            self.disconnectFromSession()
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func disconnectFromSession() {
        // WebRTC bağlantısını kapat
        webRTCService.disconnect()
        
        // Kullanıcıya bağlantının kesildiğini bildir
        showToast(message: "Sesli oturumdan ayrıldınız")
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        let maxWidth = view.frame.width - 80
        let toastHeight = message.height(withConstrainedWidth: maxWidth, font: toastLabel.font) + 20
        
        toastLabel.frame = CGRect(x: 40, y: view.frame.height - 100, width: view.frame.width - 80, height: toastHeight)
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension VoiceSessionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as? ParticipantCell else {
            return UITableViewCell()
        }
        
        let participantId = Array(participants.keys)[indexPath.row]
        let displayName = participants[participantId] ?? "İsimsiz Katılımcı"
        
        cell.configure(with: displayName, isSpeaking: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - String Extension

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

// MARK: - ParticipantCell

class ParticipantCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let avatarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let speakingIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 5
        view.isHidden = true
        return view
    }()
    
    private let microphoneIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "mic.fill")
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        initialsLabel.text = nil
        speakingIndicator.isHidden = true
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // UI elementlerini ekle
        contentView.addSubview(containerView)
        containerView.addSubview(avatarView)
        avatarView.addSubview(initialsLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(speakingIndicator)
        containerView.addSubview(microphoneIcon)
        
        // Auto Layout kısıtlamalarını ayarla
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 36),
            avatarView.heightAnchor.constraint(equalToConstant: 36),
            
            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: microphoneIcon.leadingAnchor, constant: -12),
            
            speakingIndicator.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            speakingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            speakingIndicator.widthAnchor.constraint(equalToConstant: 10),
            speakingIndicator.heightAnchor.constraint(equalToConstant: 10),
            
            microphoneIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            microphoneIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            microphoneIcon.widthAnchor.constraint(equalToConstant: 20),
            microphoneIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with name: String, isSpeaking: Bool) {
        nameLabel.text = name
        
        // Baş harfleri çıkar
        let components = name.components(separatedBy: " ")
        if components.count > 1 {
            if let firstChar = components[0].first, let lastChar = components.last?.first {
                initialsLabel.text = "\(firstChar)\(lastChar)".uppercased()
            }
        } else if let firstChar = name.first {
            initialsLabel.text = String(firstChar).uppercased()
        }
        
        // Konuşma göstergesini ayarla
        speakingIndicator.isHidden = !isSpeaking
        
        // Mikrofon simgesini ayarla (isteğe bağlı olarak değiştirilebilir)
        let microphoneImage = isSpeaking ? 
            UIImage(systemName: "mic.fill") : 
            UIImage(systemName: "mic.slash.fill")
        microphoneIcon.image = microphoneImage
        microphoneIcon.tintColor = isSpeaking ? .systemGreen : .secondaryLabel
    }
} 