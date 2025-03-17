import UIKit
import Combine


@MainActor
final class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView = UIView()
    private let profileImageContainer = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsStackView = UIStackView()
    
    private let viewModel: ProfileViewModel
    var onEditProfile: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    public init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
        fetchUserProfile()
    }
    
    private func setupBindings() {
        viewModel.$profileItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.applySnapshot(with: items)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(with items: [ProfileItem]) {
        guard let userInfo = items.first else {
            print("❌ No user info found")
            return
        }

        DispatchQueue.main.async { [weak self] in
            switch userInfo {
            case .userInfo(let name, let bio, let imageUrl):
                self?.updateProfileUI(name: name, bio: bio, imageUrl: imageUrl)
            case .post:
                print("⚠️ Unexpected ProfileItem: Post detected instead of UserInfo")
            }
        }
    }

    private func updateProfileUI(name: String, bio: String, imageUrl: URL?) {
        nameLabel.text = name
        bioLabel.text = bio

        // 🔥 Load profile image with smooth fade-in
        if let imageUrl = imageUrl {
            loadProfileImage(from: imageUrl)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    private func loadProfileImage(from url: URL) {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    UIView.transition(with: self.profileImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.profileImageView.image = image
                    }, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }

    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Profile"

        setupGradientHeader()
        setupProfileImage()
        setupUserInfo()

        let profileStackView = UIStackView(arrangedSubviews: [nameLabel, bioLabel, statsStackView])
        profileStackView.axis = .vertical
        profileStackView.alignment = .center
        profileStackView.spacing = 10
        profileStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerView)
        view.addSubview(profileImageContainer)
        view.addSubview(profileStackView)

        NSLayoutConstraint.activate([
            profileImageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -40),
            profileImageContainer.widthAnchor.constraint(equalToConstant: 110),
            profileImageContainer.heightAnchor.constraint(equalToConstant: 110),

            profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: profileImageContainer.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            profileStackView.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 12),
            profileStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            statsStackView.heightAnchor.constraint(equalToConstant: 55),
        ])
        
        animateProfileImage()
    }

    private func setupGradientHeader() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)

        headerView.layer.addSublayer(gradientLayer)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func setupProfileImage() {
        profileImageContainer.backgroundColor = .white
        profileImageContainer.layer.cornerRadius = 55
        profileImageContainer.layer.shadowColor = UIColor.black.cgColor
        profileImageContainer.layer.shadowOpacity = 0.2
        profileImageContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        profileImageContainer.layer.shadowRadius = 10
        profileImageContainer.translatesAutoresizingMaskIntoConstraints = false

        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        profileImageContainer.addSubview(profileImageView)
    }

    private func setupUserInfo() {
        nameLabel.font = .boldSystemFont(ofSize: 26)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label

        bioLabel.font = .systemFont(ofSize: 17)
        bioLabel.textColor = .secondaryLabel
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 2

        statsStackView.axis = .horizontal
        statsStackView.spacing = 18
        statsStackView.alignment = .center

        let stats = ["📸 Posts", "👥 Followers", "✅ Following"]
        stats.forEach { title in
            let label = UILabel()
            label.text = "0\n\(title)"
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 18, weight: .medium)
            statsStackView.addArrangedSubview(label)
        }
    }

    private func animateProfileImage() {
        profileImageContainer.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.profileImageContainer.transform = .identity
        }
    }
    
    private func fetchUserProfile() {
        Task {
            if let userProfile = await viewModel.fetchUserProfile() {                
                nameLabel.text = userProfile.name
                bioLabel.text = userProfile.bio
            } else {
                print("❌ No user data retrieved")
            }
        }
    }
}
