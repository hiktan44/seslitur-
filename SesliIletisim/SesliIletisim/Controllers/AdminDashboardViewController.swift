import UIKit

class AdminDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Admin Paneli"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usersStatsView = StatView(icon: "person.3.fill", title: "Kullanıcılar", color: .systemBlue)
    private let groupsStatsView = StatView(icon: "bubble.left.and.bubble.right.fill", title: "Gruplar", color: .systemGreen)
    private let sessionsStatsView = StatView(icon: "headphones", title: "Oturumlar", color: .systemIndigo)
    
    private let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let menuItems: [[String: Any]] = [
        ["title": "Ana Sayfa", "icon": "house.fill", "controller": "DashboardViewController"],
        ["title": "Kullanıcı Yönetimi", "icon": "person.fill", "controller": "UserManagementViewController"],
        ["title": "Grup Yönetimi", "icon": "person.3.fill", "controller": "GroupManagementViewController"],
        ["title": "Oturum Yönetimi", "icon": "headphones", "controller": "SessionManagementViewController"],
        ["title": "Sistem Ayarları", "icon": "gearshape.fill", "controller": "SettingsViewController"],
        ["title": "Raporlar", "icon": "chart.bar.fill", "controller": "ReportsViewController"]
    ]
    
    private let stats: [String: Int] = [
        "users": 1453,
        "groups": 86,
        "sessions": 217
    ]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        updateStats()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        navigationItem.title = "Admin Paneli"
        
        // Çıkış butonu ekle
        let logoutButton = UIBarButtonItem(title: "Çıkış", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logoutButton
        
        // Welcome Label
        view.addSubview(welcomeLabel)
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Stats Container View
        view.addSubview(statsContainerView)
        NSLayoutConstraint.activate([
            statsContainerView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsContainerView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Stats Views
        statsContainerView.addSubview(usersStatsView)
        statsContainerView.addSubview(groupsStatsView)
        statsContainerView.addSubview(sessionsStatsView)
        
        NSLayoutConstraint.activate([
            usersStatsView.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 10),
            usersStatsView.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 10),
            usersStatsView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -10),
            usersStatsView.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.3),
            
            groupsStatsView.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 10),
            groupsStatsView.centerXAnchor.constraint(equalTo: statsContainerView.centerXAnchor),
            groupsStatsView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -10),
            groupsStatsView.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.3),
            
            sessionsStatsView.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 10),
            sessionsStatsView.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -10),
            sessionsStatsView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -10),
            sessionsStatsView.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.3)
        ])
        
        // Menu TableView
        view.addSubview(menuTableView)
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupTableView() {
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.register(AdminMenuCell.self, forCellReuseIdentifier: "AdminMenuCell")
    }
    
    private func updateStats() {
        usersStatsView.updateValue(stats["users"] ?? 0)
        groupsStatsView.updateValue(stats["groups"] ?? 0)
        sessionsStatsView.updateValue(stats["sessions"] ?? 0)
    }
    
    // MARK: - Actions
    @objc private func logoutButtonTapped() {
        // Çıkış işlemi
        let alert = UIAlertController(title: "Çıkış Yap", message: "Oturumunuzu kapatmak istediğinizden emin misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive, handler: { _ in
            // Ana sayfaya dön
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AdminDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminMenuCell", for: indexPath) as! AdminMenuCell
        
        let menuItem = menuItems[indexPath.row]
        cell.configure(title: menuItem["title"] as? String ?? "",
                     icon: menuItem["icon"] as? String ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = menuItems[indexPath.row]
        let controllerName = menuItem["controller"] as? String ?? ""
        
        // Not: Gerçekte reflection ile controller oluşturulabilir, ama örnek için basit bir koşul kullanıyoruz
        var viewController: UIViewController?
        
        switch controllerName {
        case "DashboardViewController":
            viewController = DashboardViewController()
        case "UserManagementViewController":
            // Şimdilik alert göster
            let alert = UIAlertController(title: "Kullanıcı Yönetimi", message: "Bu modül henüz uygulanmadı.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        case "GroupManagementViewController":
            // Şimdilik alert göster
            let alert = UIAlertController(title: "Grup Yönetimi", message: "Bu modül henüz uygulanmadı.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        case "SessionManagementViewController":
            // Şimdilik alert göster
            let alert = UIAlertController(title: "Oturum Yönetimi", message: "Bu modül henüz uygulanmadı.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        case "SettingsViewController":
            // Şimdilik alert göster
            let alert = UIAlertController(title: "Sistem Ayarları", message: "Bu modül henüz uygulanmadı.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        case "ReportsViewController":
            // Şimdilik alert göster
            let alert = UIAlertController(title: "Raporlar", message: "Bu modül henüz uygulanmadı.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        default:
            return
        }
        
        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - Custom Views
class StatView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(icon: String, title: String, color: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.image = UIImage(systemName: icon)
        containerView.backgroundColor = color
        titleLabel.text = title
        valueLabel.text = "0"
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container View
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 40),
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Icon Image View
        containerView.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Title Label
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Value Label
        addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func updateValue(_ value: Int) {
        valueLabel.text = "\(value)"
    }
}

class AdminMenuCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
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
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container View
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Icon Container View
        containerView.addSubview(iconContainerView)
        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Icon Image View
        iconContainerView.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        // Title Label
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
        
        // Accessory image view
        let accessoryImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        accessoryImageView.tintColor = .gray
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(accessoryImageView)
        NSLayoutConstraint.activate([
            accessoryImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 12),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func configure(title: String, icon: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        
        // Her menü öğesi için farklı bir renk kullan
        switch title {
        case "Ana Sayfa":
            iconContainerView.backgroundColor = .systemBlue
        case "Kullanıcı Yönetimi":
            iconContainerView.backgroundColor = .systemGreen
        case "Grup Yönetimi":
            iconContainerView.backgroundColor = .systemOrange
        case "Oturum Yönetimi":
            iconContainerView.backgroundColor = .systemPurple
        case "Sistem Ayarları":
            iconContainerView.backgroundColor = .systemGray
        case "Raporlar":
            iconContainerView.backgroundColor = .systemIndigo
        default:
            iconContainerView.backgroundColor = .systemBlue
        }
    }
} 