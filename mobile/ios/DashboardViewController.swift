import UIKit

class DashboardViewController: UIViewController {
    
    // UI Bileşenleri
    private let welcomeLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let activeSessionsLabel = UILabel()
    private let activeSessionsTableView = UITableView()
    private let upcomingSessionsLabel = UILabel()
    private let upcomingSessionsTableView = UITableView()
    private let groupsLabel = UILabel()
    private let groupsCollectionView: UICollectionView
    private let createGroupButton = UIButton(type: .system)
    private let createSessionButton = UIButton(type: .system)
    
    // Veri
    private var activeSessions: [Session] = []
    private var upcomingSessions: [Session] = []
    private var groups: [Group] = []
    private let isAdmin: Bool
    
    // Hücre tanımlayıcıları
    private let sessionCellId = "SessionCell"
    private let groupCellId = "GroupCell"
    
    // Koleksiyon görünümü için düzen
    private let collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    // Başlatıcı
    init(isAdmin: Bool) {
        self.isAdmin = isAdmin
        self.groupsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        setupCollectionView()
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Dashboard"
        
        // Sağ üst köşe menü butonu
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(menuTapped))
        navigationItem.rightBarButtonItem = menuButton
        
        // Sol üst köşe menü butonu
        let sideMenuButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(sideMenuTapped))
        navigationItem.leftBarButtonItem = sideMenuButton
        
        // Hoş geldiniz etiketi
        welcomeLabel.text = "Hoş Geldiniz!"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        // Alt başlık etiketi
        subtitleLabel.text = "Sesli İletişim Platformu'nda bugün neler yapmak istersiniz?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // Aktif oturumlar etiketi
        activeSessionsLabel.text = "Aktif Oturumlar"
        activeSessionsLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        activeSessionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activeSessionsLabel)
        
        // Aktif oturumlar tablo görünümü
        activeSessionsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activeSessionsTableView)
        
        // Yaklaşan oturumlar etiketi
        upcomingSessionsLabel.text = "Yaklaşan Oturumlar"
        upcomingSessionsLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        upcomingSessionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upcomingSessionsLabel)
        
        // Yaklaşan oturumlar tablo görünümü
        upcomingSessionsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upcomingSessionsTableView)
        
        // Gruplar etiketi
        groupsLabel.text = "Gruplarım"
        groupsLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        groupsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupsLabel)
        
        // Gruplar koleksiyon görünümü
        groupsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupsCollectionView)
        
        // Grup oluştur butonu
        createGroupButton.setTitle("Yeni Grup Oluştur", for: .normal)
        createGroupButton.backgroundColor = UIColor.systemBlue
        createGroupButton.setTitleColor(.white, for: .normal)
        createGroupButton.layer.cornerRadius = 8
        createGroupButton.addTarget(self, action: #selector(createGroupTapped), for: .touchUpInside)
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createGroupButton)
        
        // Oturum oluştur butonu
        createSessionButton.setTitle("Yeni Oturum Oluştur", for: .normal)
        createSessionButton.backgroundColor = UIColor.systemGreen
        createSessionButton.setTitleColor(.white, for: .normal)
        createSessionButton.layer.cornerRadius = 8
        createSessionButton.addTarget(self, action: #selector(createSessionTapped), for: .touchUpInside)
        createSessionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createSessionButton)
        
        // Admin paneli butonu (sadece admin için)
        if isAdmin {
            let adminButton = UIButton(type: .system)
            adminButton.setTitle("Admin Paneli", for: .normal)
            adminButton.backgroundColor = UIColor.systemRed
            adminButton.setTitleColor(.white, for: .normal)
            adminButton.layer.cornerRadius = 8
            adminButton.addTarget(self, action: #selector(adminPanelTapped), for: .touchUpInside)
            adminButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(adminButton)
            
            // Admin butonu kısıtlamaları
            NSLayoutConstraint.activate([
                adminButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                adminButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                adminButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                adminButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                adminButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        // Kısıtlamalar
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activeSessionsLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            activeSessionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            activeSessionsTableView.topAnchor.constraint(equalTo: activeSessionsLabel.bottomAnchor, constant: 10),
            activeSessionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            activeSessionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activeSessionsTableView.heightAnchor.constraint(equalToConstant: 120),
            
            upcomingSessionsLabel.topAnchor.constraint(equalTo: activeSessionsTableView.bottomAnchor, constant: 20),
            upcomingSessionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            upcomingSessionsTableView.topAnchor.constraint(equalTo: upcomingSessionsLabel.bottomAnchor, constant: 10),
            upcomingSessionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            upcomingSessionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            upcomingSessionsTableView.heightAnchor.constraint(equalToConstant: 120),
            
            groupsLabel.topAnchor.constraint(equalTo: upcomingSessionsTableView.bottomAnchor, constant: 20),
            groupsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            groupsCollectionView.topAnchor.constraint(equalTo: groupsLabel.bottomAnchor, constant: 10),
            groupsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            groupsCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            createGroupButton.topAnchor.constraint(equalTo: groupsCollectionView.bottomAnchor, constant: 20),
            createGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createGroupButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            createGroupButton.heightAnchor.constraint(equalToConstant: 44),
            
            createSessionButton.topAnchor.constraint(equalTo: groupsCollectionView.bottomAnchor, constant: 20),
            createSessionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createSessionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            createSessionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupTableViews() {
        // Aktif oturumlar tablo görünümü ayarları
        activeSessionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: sessionCellId)
        activeSessionsTableView.dataSource = self
        activeSessionsTableView.delegate = self
        activeSessionsTableView.rowHeight = 60
        
        // Yaklaşan oturumlar tablo görünümü ayarları
        upcomingSessionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: sessionCellId)
        upcomingSessionsTableView.dataSource = self
        upcomingSessionsTableView.delegate = self
        upcomingSessionsTableView.rowHeight = 60
    }
    
    private func setupCollectionView() {
        // Gruplar koleksiyon görünümü ayarları
        groupsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: groupCellId)
        groupsCollectionView.dataSource = self
        groupsCollectionView.delegate = self
        groupsCollectionView.backgroundColor = .clear
    }
    
    private func loadData() {
        // Örnek veriler
        activeSessions = [
            Session(id: "1", name: "Müşteri Görüşmesi", groupName: "Proje Yönetimi", startTime: Date(), participantCount: 8, maxParticipants: 10),
        ]
        
        upcomingSessions = [
            Session(id: "2", name: "Haftalık Sprint Toplantısı", groupName: "Yazılım Geliştirme", startTime: Date().addingTimeInterval(24 * 60 * 60), participantCount: 0, maxParticipants: 15),
            Session(id: "3", name: "Ürün Tanıtımı", groupName: "Pazarlama Stratejileri", startTime: Date().addingTimeInterval(2 * 24 * 60 * 60), participantCount: 0, maxParticipants: 25),
        ]
        
        groups = [
            Group(id: "1", name: "Yazılım Geliştirme", memberCount: 15),
            Group(id: "2", name: "Proje Yönetimi", memberCount: 8),
            Group(id: "3", name: "Pazarlama Stratejileri", memberCount: 12),
        ]
        
        // Tablo ve koleksiyon görünümlerini yenile
        activeSessionsTableView.reloadData()
        upcomingSessionsTableView.reloadData()
        groupsCollectionView.reloadData()
    }
    
    @objc private func menuTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Profil", style: .default, handler: { _ in
            // Profil sayfasına git
        }))
        
        if isAdmin {
            actionSheet.addAction(UIAlertAction(title: "Admin Paneli", style: .default, handler: { _ in
                self.adminPanelTapped()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive, handler: { _ in
            // Çıkış yap
            self.logout()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    @objc private func sideMenuTapped() {
        // Yan menüyü aç
    }
    
    @objc private func createGroupTapped() {
        // Grup oluşturma sayfasına git
    }
    
    @objc private func createSessionTapped() {
        // Oturum oluşturma sayfasına git
    }
    
    @objc private func adminPanelTapped() {
        // Admin paneline git
        let adminVC = AdminDashboardViewController()
        navigationController?.pushViewController(adminVC, animated: true)
    }
    
    private func logout() {
        // Çıkış yap ve giriş sayfasına dön
        navigationController?.setViewControllers([MainViewController()], animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == activeSessionsTableView {
            return activeSessions.isEmpty ? 1 : activeSessions.count
        } else {
            return upcomingSessions.isEmpty ? 1 : upcomingSessions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sessionCellId, for: indexPath)
        
        if tableView == activeSessionsTableView {
            if activeSessions.isEmpty {
                cell.textLabel?.text = "Şu anda aktif oturum bulunmuyor."
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
            } else {
                let session = activeSessions[indexPath.row]
                cell.textLabel?.text = session.name
                cell.detailTextLabel?.text = "\(session.groupName) • \(session.participantCount)/\(session.maxParticipants) katılımcı"
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            if upcomingSessions.isEmpty {
                cell.textLabel?.text = "Yaklaşan oturum bulunmuyor."
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
            } else {
                let session = upcomingSessions[indexPath.row]
                cell.textLabel?.text = session.name
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let dateString = dateFormatter.string(from: session.startTime)
                cell.detailTextLabel?.text = "\(session.groupName) • \(dateString)"
                cell.accessoryType = .disclosureIndicator
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == activeSessionsTableView && !activeSessions.isEmpty {
            let session = activeSessions[indexPath.row]
            // Oturum detay sayfasına git
        } else if tableView == upcomingSessionsTableView && !upcomingSessions.isEmpty {
            let session = upcomingSessions[indexPath.row]
            // Oturum detay sayfasına git
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.isEmpty ? 1 : groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellId, for: indexPath)
        
        // Hücre içeriğini temizle
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if groups.isEmpty {
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = "Henüz bir gruba üye değilsiniz."
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 0
            cell.contentView.addSubview(label)
        } else {
            let group = groups[indexPath.row]
            
            // Grup adı etiketi
            let nameLabel = UILabel()
            nameLabel.text = group.name
            nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            nameLabel.textAlignment = .center
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Üye sayısı etiketi
            let memberLabel = UILabel()
            memberLabel.text = "\(group.memberCount) üye"
            memberLabel.font = UIFont.systemFont(ofSize: 12)
            memberLabel.textColor = .gray
            memberLabel.textAlignment = .center
            memberLabel.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(nameLabel)
            cell.contentView.addSubview(memberLabel)
            
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                nameLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5),
                nameLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5),
                
                memberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
                memberLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5),
                memberLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5),
            ])
            
            // Hücre görünümü
            cell.contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !groups.isEmpty {
            let group = groups[indexPath.row]
            // Grup detay sayfasına git
        }
    }
}

// MARK: - Veri Modelleri
struct Session {
    let id: String
    let name: String
    let groupName: String
    let startTime: Date
    let participantCount: Int
    let maxParticipants: Int
}

struct Group {
    let id: String
    let name: String
    let memberCount: Int
} 