import UIKit

class AdminDashboardViewController: UIViewController {
    
    // UI Bileşenleri
    private let titleLabel = UILabel()
    private let menuTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Menü seçenekleri
    private let menuSections = [
        "Yönetim",
        "İstatistikler",
        "Ayarlar"
    ]
    
    private let menuItems: [[String]] = [
        ["Kullanıcı Yönetimi", "Grup Yönetimi", "Oturum Yönetimi"], // Yönetim
        ["Sistem İstatistikleri", "Kullanım Analizi", "Performans Raporu"], // İstatistikler
        ["Sistem Ayarları", "Bildirim Ayarları", "Çıkış Yap"] // Ayarlar
    ]
    
    private let menuIcons: [[String]] = [
        ["person.3", "rectangle.3.group", "calendar"], // Yönetim
        ["chart.bar", "chart.pie", "speedometer"], // İstatistikler
        ["gear", "bell", "arrow.right.square"] // Ayarlar
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Admin Paneli"
        
        // Başlık etiketi
        titleLabel.text = "Sistem Yönetimi"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Tablo görünümü
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuTableView)
        
        // Kısıtlamalar
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            menuTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "AdminMenuCell")
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AdminDashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuSections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminMenuCell", for: indexPath)
        
        // Hücre içeriği
        let menuItem = menuItems[indexPath.section][indexPath.row]
        let iconName = menuIcons[indexPath.section][indexPath.row]
        
        // iOS 14+ için hücre yapılandırma
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = menuItem
            content.image = UIImage(systemName: iconName)
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = menuItem
            cell.imageView?.image = UIImage(systemName: iconName)
        }
        
        cell.accessoryType = .disclosureIndicator
        
        // Çıkış Yap için özel stil
        if menuItem == "Çıkış Yap" {
            cell.tintColor = .systemRed
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                content.text = menuItem
                content.image = UIImage(systemName: iconName)
                content.textProperties.color = .systemRed
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.textColor = .systemRed
                cell.imageView?.tintColor = .systemRed
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = menuItems[indexPath.section][indexPath.row]
        
        switch selectedItem {
        case "Kullanıcı Yönetimi":
            let userManagementVC = UserManagementViewController()
            navigationController?.pushViewController(userManagementVC, animated: true)
            
        case "Grup Yönetimi":
            let groupManagementVC = GroupManagementViewController()
            navigationController?.pushViewController(groupManagementVC, animated: true)
            
        case "Oturum Yönetimi":
            let sessionManagementVC = SessionManagementViewController()
            navigationController?.pushViewController(sessionManagementVC, animated: true)
            
        case "Sistem İstatistikleri":
            // Sistem istatistikleri ekranına git
            break
            
        case "Kullanım Analizi":
            // Kullanım analizi ekranına git
            break
            
        case "Performans Raporu":
            // Performans raporu ekranına git
            break
            
        case "Sistem Ayarları":
            // Sistem ayarları ekranına git
            break
            
        case "Bildirim Ayarları":
            // Bildirim ayarları ekranına git
            break
            
        case "Çıkış Yap":
            // Çıkış yap
            logout()
            
        default:
            break
        }
    }
    
    private func logout() {
        // Kullanıcı çıkışı ve ana ekrana dönüş
        let alertController = UIAlertController(title: "Çıkış Yapılıyor", message: "Admin panelinden çıkış yapmak istediğinize emin misiniz?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive, handler: { _ in
            // Ana ekrana dön
            self.navigationController?.setViewControllers([MainViewController()], animated: true)
        }))
        
        present(alertController, animated: true)
    }
}

// MARK: - Stub View Controllers

// Kullanıcı Yönetimi
class UserManagementViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Kullanıcı Yönetimi"
        
        // Gerçek uygulamada burada kullanıcıları listeleme ve yönetme arayüzü olacak
        let label = UILabel()
        label.text = "Kullanıcı Yönetimi Ekranı"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// Grup Yönetimi
class GroupManagementViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Grup Yönetimi"
        
        // Gerçek uygulamada burada grupları listeleme ve yönetme arayüzü olacak
        let label = UILabel()
        label.text = "Grup Yönetimi Ekranı"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// Oturum Yönetimi
class SessionManagementViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Oturum Yönetimi"
        
        // Gerçek uygulamada burada oturumları listeleme ve yönetme arayüzü olacak
        let label = UILabel()
        label.text = "Oturum Yönetimi Ekranı"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
} 