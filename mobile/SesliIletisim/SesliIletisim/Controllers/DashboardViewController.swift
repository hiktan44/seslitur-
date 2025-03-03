import UIKit
#if !DEBUG
import GoogleWebRTC
#endif
import Foundation

// Model dosyalarını import et
import Foundation

// VoiceSession ve diğer modelleri import et
@_exported import struct Foundation.Data
@_exported import struct Foundation.URL

// MARK: - Delegate Protocols
protocol CreateTourViewControllerDelegate: AnyObject {
    func didCreateTour(_ tour: Tour)
}

// Model tanımları
// UserMode CommonModels.swift veya Models.swift'te de tanımlı olabilir
// Bu durumda dosya başına import etmek daha doğru olacaktır
enum UserMode {
    case guide      // Rehber modu
    case participant // Katılımcı modu
}

// Sadece tanımlama amaçlı, gerçek implementasyon başka bir dosyada olacak
class TourDetailViewController: UIViewController {
    init(tour: Tour) {
        super.init(nibName: nil, bundle: nil)
        // Tour ile ilgili işlemler burada yapılır
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Sadece tanımlama amaçlı, gerçek implementasyon başka bir dosyada olacak
class CreateTourViewController: UIViewController {
    weak var delegate: CreateTourViewControllerDelegate?
}

// Sadece tanımlama amaçlı, gerçek implementasyon başka bir dosyada olacak
class ParticipantsViewController: UIViewController {
    init(sessionId: String) {
        super.init(nibName: nil, bundle: nil)
        // Session ID ile ilgili işlemler burada yapılır
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Model tanımları - CommonModels.swift'ten daha önce tanımlandıysa buradakileri kaldırabilirsiniz
// UserMode burada tanımlanmış ama projenin Models klasöründeki dosyalarda da benzer tanımlar var, çakışma yaratabilir

struct Tour: Codable {
    let id: String
    let name: String
    let description: String?
    let startDate: String
    let endDate: String?
    let guideId: String
    let code: String
    let isActive: Bool
    let participantCount: Int
    let createdAt: String
    let updatedAt: String
}

// VoiceSession tanımı
struct VoiceSession: Codable {
    let id: String
    let title: String
    let tourId: String
    let creatorId: String
    let isActive: Bool
    let startTime: String
    let endTime: String?
    let participantCount: Int
    let createdAt: String
    let updatedAt: String
}

struct ToursResponse: Codable {
    let tours: [Tour]
}

struct SessionsResponse: Codable {
    let sessions: [VoiceSession]
}

struct CreateVoiceSession: Codable {
    let title: String
    let tourId: String
    let maxParticipants: Int
    
    init(title: String, tourId: String, maxParticipants: Int = 300) {
        self.title = title
        self.tourId = tourId
        self.maxParticipants = maxParticipants
    }
}

/**
 * DashboardViewController - Ana gösterge paneli
 * 
 * Bu ekran, rehber veya katılımcı moduna göre farklı özellikler sunarak
 * aktif turlar, yaklaşan turlar ve sesli iletişim özellikleri gösterir.
 */
class DashboardViewController: UIViewController {
    
    // MARK: - Properties
    private var _userMode: UserMode = .guide
    
    // UserMode için public getter ve setter
    public var userMode: UserMode {
        get { return _userMode }
        set { _userMode = newValue }
    }
    
    private var titleLabel: UILabel!
    private var activeToursCollectionView: UICollectionView!
    private var upcomingToursTableView: UITableView!
    private var createTourButton: UIButton!
    private var joinTourButton: UIButton!
    private var noActiveToursLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    private var activeTours: [Tour] = []
    private var upcomingTours: [Tour] = []
    private var activeSessions: [VoiceSession] = []
    
    // Kullanıcı bilgileri
    private var userName: String {
        return UserDefaults.standard.string(forKey: "userName") ?? "Kullanıcı"
    }
    
    private var userId: String {
        return UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    
    private var currentTourId: String? {
        return UserDefaults.standard.string(forKey: "currentTourId")
    }
    
    // Sesli iletişim için özellikler
    private var voicePanel: UIView?
    private var voiceStatusLabel: UILabel?
    private var voiceActionButton: UIButton?
    private var participantsButton: UIButton?
    private var isMicrophoneEnabled: Bool = false
    private var isVoiceSessionActive: Bool = false
    private var participantCount: Int = 0
    private var selectedSession: VoiceSession?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        
        // Kullanıcı tipine göre UI elemanlarını ayarla
        determineUserMode()
        
        // Verileri yükle
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ekran her göründüğünde verileri yenile
        fetchData()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        // Ana başlık
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = "Turlarım"
        view.addSubview(titleLabel)
        
        // Aktivite göstergesi
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        
        // Kullanıcı tipine göre UI bileşenlerini ayarla
        setupActiveTourSection()
        
        if _userMode == .guide {
            setupUpcomingTourSection()
            setupCreateTourButton()
        } else {
            setupJoinTourButton()
        }
        
        setupVoicePanel()
        setupConstraints()
    }
    
    private func setupGestures() {
        // Kaydırma hareketlerini tanımla
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    private func setupActiveTourSection() {
        // Aktif turlar için layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.itemSize = CGSize(width: 250, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // Aktif turlar CollectionView
        activeToursCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        activeToursCollectionView.translatesAutoresizingMaskIntoConstraints = false
        activeToursCollectionView.backgroundColor = .clear
        activeToursCollectionView.showsHorizontalScrollIndicator = false
        activeToursCollectionView.register(TourCollectionViewCell.self, forCellWithReuseIdentifier: "TourCell")
        activeToursCollectionView.delegate = self
        activeToursCollectionView.dataSource = self
        view.addSubview(activeToursCollectionView)
        
        // Aktif tur yok etiketi
        noActiveToursLabel = UILabel()
        noActiveToursLabel.translatesAutoresizingMaskIntoConstraints = false
        noActiveToursLabel.text = "Aktif tur bulunamadı"
        noActiveToursLabel.textAlignment = .center
        noActiveToursLabel.textColor = .darkGray
        noActiveToursLabel.font = UIFont.systemFont(ofSize: 16)
        noActiveToursLabel.isHidden = true
        view.addSubview(noActiveToursLabel)
    }
    
    private func setupUpcomingTourSection() {
        // Yaklaşan turlar TableView
        upcomingToursTableView = UITableView()
        upcomingToursTableView.translatesAutoresizingMaskIntoConstraints = false
        upcomingToursTableView.backgroundColor = .clear
        upcomingToursTableView.register(TourTableViewCell.self, forCellReuseIdentifier: "UpcomingTourCell")
        upcomingToursTableView.delegate = self
        upcomingToursTableView.dataSource = self
        upcomingToursTableView.separatorStyle = .none
        upcomingToursTableView.showsVerticalScrollIndicator = false
        upcomingToursTableView.rowHeight = 100
        view.addSubview(upcomingToursTableView)
    }
    
    private func setupCreateTourButton() {
        createTourButton = UIButton(type: .system)
        createTourButton.translatesAutoresizingMaskIntoConstraints = false
        createTourButton.setTitle("Tur Oluştur", for: .normal)
        createTourButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        createTourButton.backgroundColor = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1.0)
        createTourButton.setTitleColor(.white, for: .normal)
        createTourButton.layer.cornerRadius = 10
        createTourButton.addTarget(self, action: #selector(createTourTapped), for: .touchUpInside)
        view.addSubview(createTourButton)
    }
    
    private func setupJoinTourButton() {
        joinTourButton = UIButton(type: .system)
        joinTourButton.translatesAutoresizingMaskIntoConstraints = false
        joinTourButton.setTitle("Tura Katıl", for: .normal)
        joinTourButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        joinTourButton.backgroundColor = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1.0)
        joinTourButton.setTitleColor(.white, for: .normal)
        joinTourButton.layer.cornerRadius = 10
        joinTourButton.addTarget(self, action: #selector(joinTourTapped), for: .touchUpInside)
        view.addSubview(joinTourButton)
    }
    
    private func setupVoicePanel() {
        // Sesli iletişim paneli
        voicePanel = UIView()
        voicePanel?.translatesAutoresizingMaskIntoConstraints = false
        voicePanel?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        voicePanel?.layer.cornerRadius = 15
        voicePanel?.clipsToBounds = true
        voicePanel?.layer.shadowColor = UIColor.black.cgColor
        voicePanel?.layer.shadowOffset = CGSize(width: 0, height: 3)
        voicePanel?.layer.shadowOpacity = 0.2
        voicePanel?.layer.shadowRadius = 4
        voicePanel?.layer.masksToBounds = false
        view.addSubview(voicePanel!)
        
        // Durum etiketi
        voiceStatusLabel = UILabel()
        voiceStatusLabel?.translatesAutoresizingMaskIntoConstraints = false
        voiceStatusLabel?.text = "Sesli oturum aktif değil"
        voiceStatusLabel?.font = UIFont.systemFont(ofSize: 14)
        voiceStatusLabel?.textColor = .darkGray
        voicePanel?.addSubview(voiceStatusLabel!)
        
        // Aksiyon butonu
        voiceActionButton = UIButton(type: .system)
        voiceActionButton?.translatesAutoresizingMaskIntoConstraints = false
        voiceActionButton?.setTitle("Oturum Başlat", for: .normal)
        voiceActionButton?.backgroundColor = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1.0)
        voiceActionButton?.setTitleColor(.white, for: .normal)
        voiceActionButton?.layer.cornerRadius = 8
        voiceActionButton?.addTarget(self, action: #selector(voiceActionTapped), for: .touchUpInside)
        voicePanel?.addSubview(voiceActionButton!)
        
        // Katılımcılar butonu
        participantsButton = UIButton(type: .system)
        participantsButton?.translatesAutoresizingMaskIntoConstraints = false
        participantsButton?.setTitle("Katılımcılar (0)", for: .normal)
        participantsButton?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        participantsButton?.setTitleColor(.darkGray, for: .normal)
        participantsButton?.layer.cornerRadius = 8
        participantsButton?.addTarget(self, action: #selector(showParticipantsTapped), for: .touchUpInside)
        participantsButton?.isHidden = true
        voicePanel?.addSubview(participantsButton!)
    }
    
    private func setupConstraints() {
        guard let voicePanel = voicePanel,
              let voiceStatusLabel = voiceStatusLabel,
              let voiceActionButton = voiceActionButton,
              let participantsButton = participantsButton else { return }
        
            NSLayoutConstraint.activate([
            // Başlık etiketi
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Aktivite göstergesi
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Aktif turlar
            activeToursCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            activeToursCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activeToursCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activeToursCollectionView.heightAnchor.constraint(equalToConstant: 170),
            
            // Aktif tur yok etiketi
            noActiveToursLabel.centerXAnchor.constraint(equalTo: activeToursCollectionView.centerXAnchor),
            noActiveToursLabel.centerYAnchor.constraint(equalTo: activeToursCollectionView.centerYAnchor),
        ])
        
        if _userMode == .guide {
            // Rehber modu constraint'leri
            NSLayoutConstraint.activate([
                // Yaklaşan turlar
                upcomingToursTableView.topAnchor.constraint(equalTo: activeToursCollectionView.bottomAnchor, constant: 20),
                upcomingToursTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                upcomingToursTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                upcomingToursTableView.bottomAnchor.constraint(equalTo: voicePanel.topAnchor, constant: -20),
                
                // Tur oluşturma butonu
                createTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                createTourButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                createTourButton.heightAnchor.constraint(equalToConstant: 50),
                createTourButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        } else {
            // Katılımcı modu constraint'leri
            NSLayoutConstraint.activate([
                // Tura katılma butonu
                joinTourButton.topAnchor.constraint(equalTo: activeToursCollectionView.bottomAnchor, constant: 20),
                joinTourButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                joinTourButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                joinTourButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        // Sesli iletişim paneli
        NSLayoutConstraint.activate([
            voicePanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            voicePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            voicePanel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            voiceStatusLabel.topAnchor.constraint(equalTo: voicePanel.topAnchor, constant: 15),
            voiceStatusLabel.leadingAnchor.constraint(equalTo: voicePanel.leadingAnchor, constant: 15),
            voiceStatusLabel.trailingAnchor.constraint(equalTo: voicePanel.trailingAnchor, constant: -15),
            
            voiceActionButton.topAnchor.constraint(equalTo: voiceStatusLabel.bottomAnchor, constant: 10),
            voiceActionButton.leadingAnchor.constraint(equalTo: voicePanel.leadingAnchor, constant: 15),
            voiceActionButton.heightAnchor.constraint(equalToConstant: 40),
            
            participantsButton.topAnchor.constraint(equalTo: voiceStatusLabel.bottomAnchor, constant: 10),
            participantsButton.leadingAnchor.constraint(equalTo: voiceActionButton.trailingAnchor, constant: 10),
            participantsButton.trailingAnchor.constraint(equalTo: voicePanel.trailingAnchor, constant: -15),
            participantsButton.heightAnchor.constraint(equalToConstant: 40),
            participantsButton.bottomAnchor.constraint(equalTo: voicePanel.bottomAnchor, constant: -15)
        ])
        
        // Rehber modunda voicePanel alt constraint'i
        if _userMode == .guide {
            NSLayoutConstraint.activate([
                voicePanel.bottomAnchor.constraint(equalTo: createTourButton.topAnchor, constant: -20)
            ])
        } else {
            // Katılımcı modunda voicePanel alt constraint'i
            NSLayoutConstraint.activate([
                voicePanel.topAnchor.constraint(equalTo: joinTourButton.bottomAnchor, constant: 20),
                voicePanel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
        }
    }
    
    private func determineUserMode() {
        // Kullanıcı rolünü UserDefaults'tan al
        if let userRole = UserDefaults.standard.string(forKey: "userRole") {
            // Kullanıcı rehber mi yoksa katılımcı mı?
            _userMode = userRole == "guide" ? .guide : .participant
        } else {
            // Varsayılan olarak katılımcı modunu kullan
            _userMode = .participant
        }
        
        // Başlığı güncelle
        titleLabel.text = _userMode == .guide ? "Turlarım" : "Tur Keşfet"
    }
    
    // MARK: - Data Fetching
    private func fetchData() {
        activityIndicator.startAnimating()
        
        // Aktif ve yaklaşan turları ve aktif oturumları eş zamanlı olarak çek
        let dispatchGroup = DispatchGroup()
        
        // Turları çek
        dispatchGroup.enter()
        fetchTours { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tours):
                // Turları tarih durumuna göre ayır
                self.processTours(tours)
            case .failure(let error):
                print("Turlar çekilirken hata oluştu: \(error.localizedDescription)")
            }
            
            dispatchGroup.leave()
        }
        
        // Aktif sesli oturumları çek
        dispatchGroup.enter()
        fetchActiveVoiceSessions { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let sessions):
                self.activeSessions = sessions
            case .failure(let error):
                print("Sesli oturumlar çekilirken hata oluştu: \(error.localizedDescription)")
            }
            
            dispatchGroup.leave()
        }
        
        // Tüm işlemler tamamlandığında
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            self.activeToursCollectionView.reloadData()
            
            if self._userMode == .guide {
                self.upcomingToursTableView.reloadData()
            }
            
            // Aktif oturum varsa göster
            self.updateVoiceSessionUI()
        }
    }
    
    // Turları çek
    private func fetchTours(completion: @escaping (Result<[Tour], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            let error = NSError(domain: "com.sesliiletisim", code: 401, userInfo: [NSLocalizedDescriptionKey: "Oturum hatası"])
            completion(.failure(error))
            return
        }
        
        // API URL
        let urlString = "https://api.sesliiletisim.com/api/tours/guide"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "com.sesliiletisim", code: 0, userInfo: [NSLocalizedDescriptionKey: "Veri alınamadı"])
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let toursResponse = try decoder.decode(ToursResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(toursResponse.tours))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // Aktif sesli oturumları çek
    private func fetchActiveVoiceSessions(completion: @escaping (Result<[VoiceSession], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            let error = NSError(domain: "com.sesliiletisim", code: 401, userInfo: [NSLocalizedDescriptionKey: "Oturum hatası"])
            completion(.failure(error))
            return
        }
        
        // API URL
        let urlString = "https://api.sesliiletisim.com/api/voice-sessions/active"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "com.sesliiletisim", code: 0, userInfo: [NSLocalizedDescriptionKey: "Veri alınamadı"])
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let sessionsResponse = try decoder.decode(SessionsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(sessionsResponse.sessions))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func processTours(_ tours: [Tour]) {
        let now = Date()
        
        // Aktif ve yaklaşan turları ayır
        activeTours = tours.filter { tour in
            // Tour aktif mi kontrol et (şu anki tarih, başlangıç ve bitiş tarihleri arasında mı)
            let isoFormatter = ISO8601DateFormatter()
            if let startDate = isoFormatter.date(from: tour.startDate) {
                if let endDateString = tour.endDate,
                   let endDate = isoFormatter.date(from: endDateString) {
                    // Başlangıç ve bitiş tarihleri var
                    return now >= startDate && now <= endDate
                } else {
                    // Bitiş tarihi yok, sadece başlangıç tarihine göre değerlendir
                    // Başlangıç tarihinden 1 saat sonrasına kadar aktif kabul et
                    let oneHourLater = startDate.addingTimeInterval(3600)
                    return now >= startDate && now <= oneHourLater
                }
            }
            return false
        }
        
        // Kullanıcı rehber ise yaklaşan turları da filtrele
        if _userMode == .guide {
            upcomingTours = tours.filter { tour in
                // Yaklaşan turları bul (başlangıç tarihi gelecekte olanlar)
                let isoFormatter = ISO8601DateFormatter()
                if let startDate = isoFormatter.date(from: tour.startDate) {
                    return startDate > now
                }
                return false
            }
        }
    }
    
    // MARK: - Voice Session Methods
    private func updateVoiceSessionUI() {
        guard let voiceStatusLabel = voiceStatusLabel,
              let voiceActionButton = voiceActionButton else {
            return
        }
        
        if let currentActiveTour = currentTourId, !activeSessions.isEmpty {
            // Aktif sesli oturum var
            let session = activeSessions[0] // İlk aktif oturumu göster
            selectedSession = session
            isVoiceSessionActive = true
            participantCount = session.participantCount
            
            voiceStatusLabel.text = "Aktif Sesli Oturum: \(session.title) (\(participantCount) katılımcı)"
            voiceActionButton.setTitle("Katıl", for: .normal)
            voiceActionButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        } else {
            // Aktif sesli oturum yok
            isVoiceSessionActive = false
            participantCount = 0
            selectedSession = nil as VoiceSession?
            
            voiceStatusLabel.text = "Aktif sesli oturum bulunmuyor"
            
            if _userMode == .guide {
                voiceActionButton.setTitle("Oturum Başlat", for: .normal)
                voiceActionButton.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
            } else {
                voiceActionButton.setTitle("Bekleyin", for: .normal)
                voiceActionButton.backgroundColor = UIColor.lightGray
                voiceActionButton.isEnabled = false
            }
        }
        
        // Katılımcılar butonunu güncelle
        participantsButton?.isEnabled = isVoiceSessionActive
    }
    
    // MARK: - Action Methods
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        // Sağ veya sol kaydırma hareketlerini işle
        if gesture.direction == .right {
            // Sağa kaydırma: Önceki sayfa veya işlem
            print("Sağa kaydırma tespit edildi")
        } else if gesture.direction == .left {
            // Sola kaydırma: Sonraki sayfa veya işlem
            print("Sola kaydırma tespit edildi")
        }
    }
    
    @objc private func createTourTapped() {
        // Tur oluşturma ekranına git
        let createTourVC = CreateTourViewController()
        createTourVC.delegate = self
        let navController = UINavigationController(rootViewController: createTourVC)
        present(navController, animated: true)
    }
    
    @objc private func joinTourTapped() {
        // Tura katılma dialogunu göster
        let alertController = UIAlertController(title: "Tura Katıl", message: "Katılmak istediğiniz turun kodunu girin", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Tur Kodu"
            textField.keyboardType = .asciiCapable
            textField.autocapitalizationType = .allCharacters
        }
        
        let joinAction = UIAlertAction(title: "Katıl", style: .default) { [weak self] _ in
            guard let self = self, 
                  let tourCodeField = alertController.textFields?.first,
                  let tourCode = tourCodeField.text, !tourCode.isEmpty else { return }
            
            // Tur kodunu kullanarak API ile tura katılma isteği gönder
            self.joinTourWithCode(tourCode)
        }
        
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        
        alertController.addAction(joinAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func joinTourWithCode(_ code: String) {
        activityIndicator.startAnimating()
        
        let urlString = "https://api.sesliiletisim.com/api/tours/join"
        let parameters = ["code": code]
        
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
            self.activityIndicator.stopAnimating()
            self.showAlert(title: "Hata", message: "İstek hazırlanamadı")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(title: "Hata", message: "Tura katılırken bir hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.showAlert(title: "Hata", message: "Veri alınamadı")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    struct TourResponse: Codable {
                        let tour: Tour
                    }
                    let tourResponse = try decoder.decode(TourResponse.self, from: data)
                    
                    // Başarılı olursa tura katıl
                    self.showToast(message: "\(tourResponse.tour.name) turuna başarıyla katıldınız!")
                    
                    // Tur bilgilerini kaydet
                    UserDefaults.standard.set(tourResponse.tour.id, forKey: "currentTourId")
                    UserDefaults.standard.set(tourResponse.tour.name, forKey: "currentTourName")
                    
                    self.fetchData() // Verileri yenile
                } catch {
                    self.showAlert(title: "Hata", message: "Tura katılırken bir hata oluştu: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    @objc private func voiceActionTapped() {
        guard let currentSession = selectedSession else {
            showAlert(title: "Hata", message: "Lütfen önce bir tur seçin")
            return
        }
        
        if isVoiceSessionActive {
            // Aktif oturum varsa sonlandır
            endVoiceSession()
            } else {
            // Aktif oturum yoksa yeni oturum başlat
            // Session'ın ait olduğu turu bulalım
            if let tourForSession = activeTours.first(where: { $0.id == currentSession.tourId }) {
                createVoiceSession(for: tourForSession)
            } else {
                showAlert(title: "Hata", message: "Bu sesli oturuma ait tur bulunamadı.")
            }
        }
    }
    
    @objc private func showParticipantsTapped() {
        guard let session = selectedSession else { return }
        
        // Katılımcılar listesi ekranını göster
        let participantsVC = ParticipantsViewController(sessionId: session.id)
        let navController = UINavigationController(rootViewController: participantsVC)
        present(navController, animated: true)
    }
    
    @objc private func logoutTapped() {
        // Oturumdan çık
        if WebRTCService.shared.isSessionActive() {
            WebRTCService.shared.leaveSession { _, _ in
                // Çıkış yapılıyor, hata kontrol etmeye gerek yok
            }
        }
        
        // Kullanıcı verilerini temizle
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "currentTourId")
        UserDefaults.standard.removeObject(forKey: "currentTourName")
        
        // Giriş ekranına yönlendir
        let loginVC = LoginViewController()
        loginVC.isGuideLogin = _userMode == .guide
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 150, y: view.frame.height - 100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 3.0, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func createVoiceSession(for tour: Tour) {
        activityIndicator.startAnimating()
        
        // Yeni sesli oturum oluştur
        let createSession = CreateVoiceSession(title: "Sesli Tur: \(tour.name)", tourId: tour.id)
        
        let urlString = "https://api.sesliiletisim.com/api/voice-sessions"
        
        // API isteği
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Token ekle
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(createSession)
        } catch {
            self.activityIndicator.stopAnimating()
            self.showAlert(title: "Hata", message: "İstek hazırlanamadı")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(title: "Hata", message: "Sesli oturum başlatılırken bir hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.showAlert(title: "Hata", message: "Veri alınamadı")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    struct SessionResponse: Codable {
                        let session: VoiceSession
                    }
                    let sessionResponse = try decoder.decode(SessionResponse.self, from: data)
                    
                    // Başarılı olursa sesli oturumu başlat
                    self.selectedSession = sessionResponse.session
                    self.activeSessions = [sessionResponse.session]
                    self.updateVoiceSessionUI()
                    self.connectToVoiceSession(sessionResponse.session)
                    self.showToast(message: "Sesli oturum başlatıldı!")
                } catch {
                    self.showAlert(title: "Hata", message: "Sesli oturum başlatılırken bir hata oluştu: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func endVoiceSession() {
        guard let session = selectedSession else { return }
        
        activityIndicator.startAnimating()
        
        let urlString = "https://api.sesliiletisim.com/api/voice-sessions/\(session.id)/end"
        
        // API isteği
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Token ekle
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(title: "Hata", message: "Sesli oturum sonlandırılırken bir hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                // HTTP yanıt kodu kontrol et
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    // Başarılı olursa sesli oturumu sonlandır
                    self.disconnectFromVoiceSession()
                    self.selectedSession = nil
                    self.updateVoiceSessionUI()
                    self.showToast(message: "Sesli oturum sonlandırıldı!")
            } else {
                    self.showAlert(title: "Hata", message: "Sesli oturum sonlandırılırken bir hata oluştu.")
                }
            }
        }.resume()
    }
    
    private func connectToVoiceSession(_ session: VoiceSession) {
        // WebRTCService ile bağlantı kur
        WebRTCService.shared.connect(sessionId: session.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updateVoiceSessionUI()
                    
                case .failure(let error):
                    self.showAlert(title: "Bağlantı Hatası", message: "Sesli oturuma bağlanırken bir hata oluştu: \(error.localizedDescription)")
                    // Hata durumunda oturumu sonlandır
                    self.endVoiceSession()
                }
            }
        }
    }
    
    private func disconnectFromVoiceSession() {
        // WebRTCService bağlantısını sonlandır
        WebRTCService.shared.disconnect()
        selectedSession = nil as VoiceSession?
    }
}

// MARK: - Collection View Cell
class TourCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let statusView = UIView()
    private let statusLabel = UILabel()
    private let participantsLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Hücre arka planı
        contentView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1
        
        // Tur başlığı
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        // Durum göstergesi
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusView.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
        statusView.layer.cornerRadius = 5
        contentView.addSubview(statusView)
        
        // Durum etiketi
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = .white
        statusLabel.text = "Aktif"
        statusLabel.textAlignment = .center
        statusView.addSubview(statusLabel)
        
        // Katılımcı sayısı
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.font = UIFont.systemFont(ofSize: 12)
        participantsLabel.textColor = .darkGray
        contentView.addSubview(participantsLabel)
        
        // Zaman etiketi
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .darkGray
        timeLabel.textAlignment = .right
        contentView.addSubview(timeLabel)
        
        // Constraint'ler
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            statusView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statusView.widthAnchor.constraint(equalToConstant: 60),
            statusView.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor),
            
            participantsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            participantsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with tour: Tour, session: VoiceSession?) {
        titleLabel.text = tour.name
        
        if session != nil {
            statusView.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
            statusLabel.text = "Aktif"
        } else {
            statusView.backgroundColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
            statusLabel.text = "Hazır"
        }
        
        // Katılımcı sayısı
        let participantCount = session?.participantCount ?? 0
        participantsLabel.text = "\(participantCount) Katılımcı"
        
        // Zaman bilgisi
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        // String tarihten Date objesine çevirme
        let isoFormatter = ISO8601DateFormatter()
        if let startDate = isoFormatter.date(from: tour.startDate) {
            timeLabel.text = dateFormatter.string(from: startDate)
        } else {
            timeLabel.text = "Tarih Yok"
        }
    }
}

// MARK: - Table View Cell
class TourTableViewCell: UITableViewCell {
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Kart görünümü
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowRadius = 3
        cardView.layer.shadowOpacity = 0.1
        contentView.addSubview(cardView)
        
        // Tur başlığı
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        cardView.addSubview(titleLabel)
        
        // Tarih etiketi
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        cardView.addSubview(dateLabel)
        
        // Durum etiketi
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        statusLabel.textAlignment = .center
        cardView.addSubview(statusLabel)
        
        // Constraint'ler
            NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            dateLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            statusLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            statusLabel.widthAnchor.constraint(equalToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with tour: Tour) {
        titleLabel.text = tour.name
        
        // Tarih formatlama
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        
        // String tarihten Date objesine çevirme
        let isoFormatter = ISO8601DateFormatter()
        if let startDate = isoFormatter.date(from: tour.startDate) {
            dateLabel.text = dateFormatter.string(from: startDate)
        } else {
            dateLabel.text = "Tarih Belirtilmemiş"
        }
        
        // Duruma göre etiket renklendirme
        let now = Date()
        if let startDate = isoFormatter.date(from: tour.startDate), 
           startDate > now {
            statusLabel.text = "Yaklaşan"
            statusLabel.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 0.2)
            statusLabel.textColor = UIColor(red: 184/255, green: 134/255, blue: 11/255, alpha: 1.0)
        } else {
            statusLabel.text = "Geçmiş"
            statusLabel.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 0.2)
            statusLabel.textColor = UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1.0)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if activeTours.isEmpty {
            noActiveToursLabel.isHidden = false
            return 0
        } else {
            noActiveToursLabel.isHidden = true
            return activeTours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TourCell", for: indexPath) as? TourCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tour = activeTours[indexPath.item]
        
        // Bu tur için aktif bir sesli oturum var mı?
        let session = activeSessions.first(where: { $0.tourId == tour.id })
        
        cell.configure(with: tour, session: session)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tour = activeTours[indexPath.item]
        
        // Bu tur için aktif bir oturum var mı?
        if let session = activeSessions.first(where: { $0.tourId == tour.id }) {
            // Aktif oturumu seç
            selectedSession = session
        } else {
            // Aktif oturum yoksa, sadece turu seç
            selectedSession = nil as VoiceSession?
        }
        
        // UI'ı güncelle
        updateVoiceSessionUI()
    }
}

// MARK: - UITableViewDataSource
extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingTours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingTourCell", for: indexPath) as? TourTableViewCell else {
            return UITableViewCell()
        }
        
        let tour = upcomingTours[indexPath.row]
        cell.configure(with: tour)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tour = upcomingTours[indexPath.row]
        
        // Tur detaylarını göster
        let detailVC = TourDetailViewController(tour: tour)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CreateTourViewControllerDelegate
extension DashboardViewController: CreateTourViewControllerDelegate {
    func didCreateTour(_ tour: Tour) {
        // Yeni tur oluşturulduğunda verileri yenile
        fetchData()
    }
} 