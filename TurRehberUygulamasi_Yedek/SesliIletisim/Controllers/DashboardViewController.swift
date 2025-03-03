import UIKit

/**
 * Kullanıcı türü için enum
 */
enum UserMode {
    case guide     // Rehber
    case participant  // Katılımcı
}

/**
 * DashboardViewController - Ana gösterge paneli
 * 
 * Bu ekran, rehber veya katılımcı moduna göre farklı özellikler sunarak
 * aktif turlar, yaklaşan turlar ve sesli iletişim özellikleri gösterir.
 */
class DashboardViewController: UIViewController {
    
    // MARK: - Properties
    var userMode: UserMode = .guide
    
    private var titleLabel: UILabel!
    private var activeToursCollectionView: UICollectionView!
    private var upcomingToursTableView: UITableView!
    private var createTourButton: UIButton!
    private var joinTourButton: UIButton!
    private var noActiveToursLabel: UILabel!
    
    private let activeTours: [TourModel] = [
        TourModel(id: "1", name: "İstanbul Tarihi Yarımada", destination: "İstanbul", date: Date(), participantCount: 28, status: .active),
        TourModel(id: "2", name: "Kapadokya Turu", destination: "Nevşehir", date: Date().addingTimeInterval(86400), participantCount: 42, status: .active)
    ]
    
    private let upcomingTours: [TourModel] = [
        TourModel(id: "3", name: "Efes & Şirince", destination: "İzmir", date: Date().addingTimeInterval(172800), participantCount: 35, status: .upcoming),
        TourModel(id: "4", name: "Umre Ziyareti", destination: "Mekke", date: Date().addingTimeInterval(604800), participantCount: 120, status: .upcoming),
        TourModel(id: "5", name: "Pamukkale & Hierapolis", destination: "Denizli", date: Date().addingTimeInterval(1209600), participantCount: 28, status: .upcoming)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 247/255, alpha: 1.0)
        
        // Başlık etiketi
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        
        if userMode == .guide {
            titleLabel.text = "Rehber Paneli"
        } else {
            titleLabel.text = "Katılımcı Paneli"
        }
        
        view.addSubview(titleLabel)
        
        // Aktif turlar için CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 280, height: 160)
        layout.minimumLineSpacing = 15
        
        activeToursCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        activeToursCollectionView.translatesAutoresizingMaskIntoConstraints = false
        activeToursCollectionView.backgroundColor = .clear
        activeToursCollectionView.showsHorizontalScrollIndicator = false
        activeToursCollectionView.register(TourCollectionViewCell.self, forCellWithReuseIdentifier: "TourCell")
        activeToursCollectionView.dataSource = self
        activeToursCollectionView.delegate = self
        view.addSubview(activeToursCollectionView)
        
        // Aktif tur yok etiketi
        noActiveToursLabel = UILabel()
        noActiveToursLabel.translatesAutoresizingMaskIntoConstraints = false
        noActiveToursLabel.text = "Aktif tur bulunmuyor"
        noActiveToursLabel.textColor = .gray
        noActiveToursLabel.font = UIFont.systemFont(ofSize: 16)
        noActiveToursLabel.textAlignment = .center
        noActiveToursLabel.isHidden = !activeTours.isEmpty
        view.addSubview(noActiveToursLabel)
        
        // Yaklaşan turlar için TableView
        upcomingToursTableView = UITableView()
        upcomingToursTableView.translatesAutoresizingMaskIntoConstraints = false
        upcomingToursTableView.backgroundColor = .clear
        upcomingToursTableView.separatorStyle = .singleLine
        upcomingToursTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        upcomingToursTableView.register(TourTableViewCell.self, forCellReuseIdentifier: "UpcomingTourCell")
        upcomingToursTableView.dataSource = self
        upcomingToursTableView.delegate = self
        upcomingToursTableView.rowHeight = 80
        view.addSubview(upcomingToursTableView)
        
        // Tur oluştur / katıl butonları
        if userMode == .guide {
            createTourButton = UIButton(type: .system)
            createTourButton.translatesAutoresizingMaskIntoConstraints = false
            createTourButton.setTitle("Yeni Tur Oluştur", for: .normal)
            createTourButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            createTourButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            createTourButton.setTitleColor(.white, for: .normal)
            createTourButton.layer.cornerRadius = 12
            createTourButton.addTarget(self, action: #selector(createTourTapped), for: .touchUpInside)
            view.addSubview(createTourButton)
        } else {
            joinTourButton = UIButton(type: .system)
            joinTourButton.translatesAutoresizingMaskIntoConstraints = false
            joinTourButton.setTitle("Tura Katıl", for: .normal)
            joinTourButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            joinTourButton.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
            joinTourButton.setTitleColor(.white, for: .normal)
            joinTourButton.layer.cornerRadius = 12
            joinTourButton.addTarget(self, action: #selector(joinTourTapped), for: .touchUpInside)
            view.addSubview(joinTourButton)
        }
        
        // Constraint'ler
        var constraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            activeToursCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            activeToursCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            activeToursCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            activeToursCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            noActiveToursLabel.centerXAnchor.constraint(equalTo: activeToursCollectionView.centerXAnchor),
            noActiveToursLabel.centerYAnchor.constraint(equalTo: activeToursCollectionView.centerYAnchor),
            
            upcomingToursTableView.topAnchor.constraint(equalTo: activeToursCollectionView.bottomAnchor, constant: 30),
            upcomingToursTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upcomingToursTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        if userMode == .guide {
            constraints.append(contentsOf: [
                createTourButton.topAnchor.constraint(equalTo: upcomingToursTableView.bottomAnchor, constant: 20),
                createTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                createTourButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                createTourButton.heightAnchor.constraint(equalToConstant: 50),
                createTourButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                
                upcomingToursTableView.bottomAnchor.constraint(equalTo: createTourButton.topAnchor, constant: -20)
            ])
        } else {
            constraints.append(contentsOf: [
                joinTourButton.topAnchor.constraint(equalTo: upcomingToursTableView.bottomAnchor, constant: 20),
                joinTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                joinTourButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                joinTourButton.heightAnchor.constraint(equalToConstant: 50),
                joinTourButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                
                upcomingToursTableView.bottomAnchor.constraint(equalTo: joinTourButton.topAnchor, constant: -20)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = userMode == .guide ? "Rehber Paneli" : "Katılımcı Paneli"
        
        // Çıkış butonu
        let logoutButton = UIBarButtonItem(title: "Çıkış", style: .plain, target: self, action: #selector(logoutTapped))
        navigationItem.rightBarButtonItem = logoutButton
        
        // Profil butonu
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(profileTapped))
        navigationItem.leftBarButtonItem = profileButton
    }
    
    // MARK: - Actions
    @objc private func createTourTapped() {
        // Yeni tur oluşturma ekranına git
        let alert = UIAlertController(title: "Yeni Tur", message: "Yeni tur oluşturma özelliği yakında!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func joinTourTapped() {
        // Tura katılma diyaloğu göster
        let alert = UIAlertController(title: "Tura Katıl", message: "Lütfen tur kodunu girin", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Tur Kodu"
            textField.keyboardType = .default
            textField.autocapitalizationType = .allCharacters
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Katıl", style: .default) { [weak self] _ in
            guard let tourCode = alert.textFields?.first?.text, !tourCode.isEmpty else { return }
            self?.joinTourWithCode(tourCode)
        })
        
        present(alert, animated: true)
    }
    
    private func joinTourWithCode(_ code: String) {
        // Tur koduna göre tura katılım
        let alert = UIAlertController(title: "Tur Bulunamadı", message: "Girdiğiniz kodla eşleşen bir tur bulunamadı.", preferredStyle: .alert)
        
        // Örnek olarak TOUR1 kodunu kabul edelim
        if code == "TOUR1" {
            alert.title = "Başarılı"
            alert.message = "İstanbul Tarihi Yarımada turuna katıldınız. Rehber yayına başladığında bildirim alacaksınız."
        }
        
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func logoutTapped() {
        // Çıkış işlemi
        navigationController?.setViewControllers([MainViewController()], animated: true)
    }
    
    @objc private func profileTapped() {
        // Profil sayfasına git
        let alert = UIAlertController(title: "Profil", message: "Profil sayfası yakında!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeTours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TourCell", for: indexPath) as! TourCollectionViewCell
        let tour = activeTours[indexPath.item]
        cell.configure(with: tour)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tour = activeTours[indexPath.item]
        showTourDetailOrConnect(tour)
    }
    
    private func showTourDetailOrConnect(_ tour: TourModel) {
        if userMode == .guide {
            // Rehber ise tur detayı ve yayına başlama seçeneği
            let alert = UIAlertController(title: tour.name, message: "Bu tur için ne yapmak istersiniz?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yayına Başla", style: .default) { [weak self] _ in
                self?.startBroadcast(tourId: tour.id)
            })
            
            alert.addAction(UIAlertAction(title: "Detaylar", style: .default) { _ in
                // Tur detaylarını göster
            })
            
            alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
            present(alert, animated: true)
        } else {
            // Katılımcı ise tura bağlanma seçeneği
            let alert = UIAlertController(title: tour.name, message: "Bu tura bağlanmak istiyor musunuz?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Bağlan", style: .default) { [weak self] _ in
                self?.connectToTour(tourId: tour.id)
            })
            
            alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    private func startBroadcast(tourId: String) {
        // WebRTC yayınını başlat
        let alert = UIAlertController(title: "Yayın Başladı", message: "Sesli anlatım başarıyla başlatıldı. Katılımcılar artık sizi duyabilir.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func connectToTour(tourId: String) {
        // Tura bağlan
        let alert = UIAlertController(title: "Bağlanıldı", message: "Rehberin sesli anlatımını dinliyorsunuz.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingTours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTourCell", for: indexPath) as! TourTableViewCell
        let tour = upcomingTours[indexPath.row]
        cell.configure(with: tour)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Yaklaşan Turlar"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tour = upcomingTours[indexPath.row]
        
        // Yaklaşan tur detaylarını göster
        let alert = UIAlertController(title: tour.name, message: "Başlangıç: \(formatDate(tour.date))\nHedef: \(tour.destination)\nKatılımcı: \(tour.participantCount)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Collection View Cell
class TourCollectionViewCell: UICollectionViewCell {
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let destinationLabel = UILabel()
    private let statusLabel = UILabel()
    private let participantLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 4
        contentView.addSubview(containerView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        iconImageView.image = UIImage(systemName: "megaphone.fill")
        containerView.addSubview(iconImageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        containerView.addSubview(nameLabel)
        
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.font = UIFont.systemFont(ofSize: 14)
        destinationLabel.textColor = .darkGray
        containerView.addSubview(destinationLabel)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        containerView.addSubview(statusLabel)
        
        participantLabel.translatesAutoresizingMaskIntoConstraints = false
        participantLabel.font = UIFont.systemFont(ofSize: 12)
        participantLabel.textColor = .darkGray
        containerView.addSubview(participantLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            destinationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            destinationLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            destinationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            statusLabel.topAnchor.constraint(equalTo: destinationLabel.bottomAnchor, constant: 15),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            statusLabel.widthAnchor.constraint(equalToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            
            participantLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            participantLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
    }
    
    func configure(with tour: TourModel) {
        nameLabel.text = tour.name
        destinationLabel.text = tour.destination
        participantLabel.text = "\(tour.participantCount) katılımcı"
        
        if tour.status == .active {
            statusLabel.text = "Aktif"
            statusLabel.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        } else {
            statusLabel.text = "Yaklaşan"
            statusLabel.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        }
    }
}

// MARK: - Table View Cell
class TourTableViewCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let destinationLabel = UILabel()
    private let dateLabel = UILabel()
    private let participantLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .default
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.font = UIFont.systemFont(ofSize: 12)
        destinationLabel.textColor = .darkGray
        contentView.addSubview(destinationLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .darkGray
        dateLabel.textAlignment = .right
        contentView.addSubview(dateLabel)
        
        participantLabel.translatesAutoresizingMaskIntoConstraints = false
        participantLabel.font = UIFont.systemFont(ofSize: 12)
        participantLabel.textColor = .darkGray
        participantLabel.textAlignment = .right
        contentView.addSubview(participantLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 50),
            
            destinationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            destinationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            destinationLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            participantLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            participantLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            participantLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with tour: TourModel) {
        nameLabel.text = tour.name
        destinationLabel.text = tour.destination
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateLabel.text = formatter.string(from: tour.date)
        
        participantLabel.text = "\(tour.participantCount) katılımcı"
    }
}

// MARK: - Tour Model
struct TourModel {
    enum TourStatus {
        case active
        case upcoming
    }
    
    let id: String
    let name: String
    let destination: String
    let date: Date
    let participantCount: Int
    let status: TourStatus
} 