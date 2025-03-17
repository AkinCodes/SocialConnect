import UIKit
import Combine

@MainActor
final class MediaDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let media: MediaRepresentable
    private var cancellables = Set<AnyCancellable>()

    var onBackToHome: (() -> Void)?
    var onShowUserProfile: ((String) -> Void)?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.alpha = 0 // Initially hidden for animation
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initializer
    init(media: MediaRepresentable) {
        self.media = media
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMediaDetails()
        animateUIElements()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Media Details"
        
        // Back Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            imageView.heightAnchor.constraint(equalToConstant: 250),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Load Media Data
    private func loadMediaDetails() {
        titleLabel.text = media.title
        descriptionLabel.text = media.description
        
        Task {
            await loadImage()
        }
    }
    
    // MARK: - Load Image Asynchronously
    private func loadImage() async {
        activityIndicator.startAnimating()
        
        do {
            if let cachedImage = ImageCache.shared.getImage(for: media.thumbnailUrl) {
                imageView.image = cachedImage
            } else if let url = URL(string: media.thumbnailUrl) {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: media.thumbnailUrl)
                    imageView.image = image
                }
            }
            activityIndicator.stopAnimating()
        } catch {
            print("❌ Failed to load image: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UI Animations
    private func animateUIElements() {
        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.7) {
            self.imageView.alpha = 1
        }.startAnimation()
    }
    
    // MARK: - Navigation Actions
    @objc private func backTapped() {
        onBackToHome?()
    }
}
