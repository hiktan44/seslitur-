import UIKit

class DashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Hoş Geldiniz!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activeSessionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Aktif Oturumlar"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 120)
        layout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let upcomingSessionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Yaklaşan Oturumlar"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createSessionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yeni Oturum Oluştur", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var activeSessions: [[String: Any]] = [
        ["id": "1", "title": "Haftalık Ekip Toplantısı", "participants": 12, "isLive": true],
        ["id": "2", "title": "Proje Planlama", "participants": 5, "isLive": true],
        ["id": "3", "title": "Tasarım Değerlendirme", "participants": 8, "isLive": true]
    ]
    
    private var upcomingSessions: [[String: Any]] = [
        ["id": "4", "title": "Yeni Ürün Tanıtımı", "date": "12 Haz 2023, 10:00", "participants": 25],
        ["id": "5", "title": "Müşteri Görüşmesi", "date": "14 Haz 2023, 14:30", "participants": 3],
        ["id": "6", "title": "Stratejik Planlama", "date": "16 Haz 2023, 09:00", "participants": 10],
        ["id": "7", "title": "Eğitim Semineri", "date": "18 Haz 2023, 13:00", "participants": 50]
    ]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTableView()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Ana Sayfa"
        
        // Sağ üst köşeye profil butonu ekle
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(profileButtonTapped))
        navigationItem.rightBarButtonItem = profileButton
        
        // Welcome Label
        view.addSubview(welcomeLabel)
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Active Sessions Label
        view.addSubview(activeSessionsLabel)
        NSLayoutConstraint.activate([
            activeSessionsLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            activeSessionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        // CollectionView
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: activeSessionsLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.heightAnchor.constraint(equalToConstant: 130)
        ])
        
        // Upcoming Sessions Label
        view.addSubview(upcomingSessionsLabel)
        NSLayoutConstraint.activate([
            upcomingSessionsLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            upcomingSessionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        // TableView
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: upcomingSessionsLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
        
        // Create Session Button
        view.addSubview(createSessionButton)
        NSLayoutConstraint.activate([
            createSessionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createSessionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            createSessionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            createSessionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ActiveSessionCell.self, forCellWithReuseIdentifier: "ActiveSessionCell")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UpcomingSessionCell.self, forCellReuseIdentifier: "UpcomingSessionCell")
    }
    
    // MARK: - Actions
    private func setupActions() {
        createSessionButton.addTarget(self, action: #selector(createSessionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func profileButtonTapped() {
        // Profil sayfasına git
        let alert = UIAlertController(title: "Profil", message: "Kullanıcı profili henüz uygulanmadı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func createSessionButtonTapped() {
        // Yeni oturum oluşturma işlemleri
        let alert = UIAlertController(title: "Yeni Oturum", message: "Oturum oluştur menüsü henüz uygulanmadı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeSessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveSessionCell", for: indexPath) as! ActiveSessionCell
        
        let session = activeSessions[indexPath.item]
        cell.configure(with: session)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sessionId = activeSessions[indexPath.item]["id"] as! String
        
        // Oturuma katılma işlemi
        let alert = UIAlertController(title: "Oturuma Katıl", message: "Oturuma katılma fonksiyonu henüz uygulanmadı. Seçilen Oturum ID: \(sessionId)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingSessionCell", for: indexPath) as! UpcomingSessionCell
        
        let session = upcomingSessions[indexPath.row]
        cell.configure(with: session)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sessionId = upcomingSessions[indexPath.row]["id"] as! String
        
        // Oturum detaylarını gösterme işlemi
        let alert = UIAlertController(title: "Oturum Detayları", message: "Oturum detayları henüz uygulanmadı. Seçilen Oturum ID: \(sessionId)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Custom Cells
class ActiveSessionCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let liveIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "CANLI"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Katıl", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .white
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBlue
        layer.cornerRadius = 10
        
        // Title Label
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        
        // Participants Label
        contentView.addSubview(participantsLabel)
        NSLayoutConstraint.activate([
            participantsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            participantsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        ])
        
        // Live Indicator and Label
        contentView.addSubview(liveIndicator)
        contentView.addSubview(liveLabel)
        NSLayoutConstraint.activate([
            liveIndicator.centerYAnchor.constraint(equalTo: participantsLabel.centerYAnchor),
            liveIndicator.leadingAnchor.constraint(equalTo: participantsLabel.trailingAnchor, constant: 10),
            liveIndicator.widthAnchor.constraint(equalToConstant: 10),
            liveIndicator.heightAnchor.constraint(equalToConstant: 10),
            
            liveLabel.centerYAnchor.constraint(equalTo: liveIndicator.centerYAnchor),
            liveLabel.leadingAnchor.constraint(equalTo: liveIndicator.trailingAnchor, constant: 5)
        ])
        
        // Join Button
        contentView.addSubview(joinButton)
        NSLayoutConstraint.activate([
            joinButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            joinButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            joinButton.widthAnchor.constraint(equalToConstant: 80),
            joinButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with session: [String: Any]) {
        titleLabel.text = session["title"] as? String
        let participants = session["participants"] as? Int ?? 0
        participantsLabel.text = "\(participants) Katılımcı"
    }
}

class UpcomingSessionCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Accessory indicator ekle
        accessoryType = .disclosureIndicator
        
        // Title Label
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Date Label
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Participants Label
        contentView.addSubview(participantsLabel)
        NSLayoutConstraint.activate([
            participantsLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            participantsLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 20)
        ])
    }
    
    func configure(with session: [String: Any]) {
        titleLabel.text = session["title"] as? String
        dateLabel.text = session["date"] as? String
        let participants = session["participants"] as? Int ?? 0
        participantsLabel.text = "\(participants) Katılımcı"
    }
} 