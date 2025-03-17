import UIKit
import Combine
import SDWebImage

@MainActor
final class HomeViewController: UIViewController {

    // MARK: - Properties
    let viewModel: HomeViewModel
    var onProfileSelected: (() -> Void)?
    var onPostSelected: ((Post) -> Void)?
    var onCreatePost: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    private var fetchDebounceTimer: Timer?
    @Published var isLoading: Bool = false


    // MARK: - Initializer
    init(viewModel: HomeViewModel) {
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
        
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        showLoadingIndicator()
        
        Task {
            await viewModel.fetch()
            self.hideLoadingIndicator()
        }
        
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profileTapped))
        }

        if !view.subviews.contains(createPostButton) {
            view.addSubview(createPostButton)
        }

        createPostButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createPostButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
         viewModel.observeRealtimePosts()
    }
    
    // MARK: - UIActivityIndicatorView

    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        collectionView.isHidden = true
        emptyStateView.isHidden = true
    }

    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        collectionView.isHidden = false
    }
    
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: PostCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let refreshControl = UIRefreshControl()

    // MARK: - Data Source
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Post> = {
        return UICollectionViewDiffableDataSource<Section, Post>(collectionView: collectionView) { collectionView, indexPath, post in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as? PostCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: post)
            return cell
        }
    }()

    // MARK: - Section Enum
    private enum Section {
        case main
    }


    // MARK: - UI Setup
    private func configureUI() {
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        collectionView.delegate = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)

        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profileTapped))
        }

    }

    // MARK: - Actions
    @objc private func refreshPosts() {
        Task {
            await viewModel.fetch()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Navigation Button Actions
    @objc private func profileTapped() {
        onProfileSelected?()
    }
    
    @objc private func createPostTapped() {
        onCreatePost?()
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.applySnapshot(with: posts)
            }
            .store(in: &cancellables)
        
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.applySnapshot(with: state.posts)
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(with posts: [Post]) {
        guard !viewModel.state.isLoading else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])

        if posts.isEmpty && !viewModel.state.isInitialLoad {
            showEmptyState()
        } else {
            hideEmptyState()
            snapshot.appendItems(posts)
        }

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No posts yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()

    private func showEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func hideEmptyState() {
        emptyStateView.removeFromSuperview()
    }
    
    private lazy var createPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Create Post", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(createPostTapped), for: .touchUpInside)
        return button
    }()


    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "photo.on.rectangle"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = "No posts yet. Be the first to share something!"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        let button = UIButton(type: .system)
        button.setTitle("+ Create Post", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(createPostTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [imageView, label, button])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
        ])

        return view
    }()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < viewModel.state.posts.count else {
            print("❌ Index out of range: \(indexPath.item), posts count: \(viewModel.state.posts.count)")
            return
        }

        let selectedPost = viewModel.state.posts[indexPath.item]
        onPostSelected?(selectedPost) // Notify coordinator
    }
}

// MARK: - UICollectionView Delegate
extension HomeViewController: UICollectionViewDelegate {}

// MARK: - Compositional Layout
private extension HomeViewController {
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(250))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(250))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            return section
        }
    }
}


// MARK: - INFINITE SCROLLING - PAGINATION
extension HomeViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // Debug log
        print("Scroll offset: \(offsetY), contentHeight: \(contentHeight), scrollViewHeight: \(scrollViewHeight)")
        
        // Only attempt fetching if we know there's more data and we're not already loading.
        guard viewModel.hasNextPage, !viewModel.isLoading else { return }
        
        // Define a threshold. You might adjust the multiplier based on your UI.
        let threshold = contentHeight - scrollViewHeight * 1.5
        if offsetY > threshold {
            print("Condition met for fetching next page")
            
            // Invalidate any existing timer
            fetchDebounceTimer?.invalidate()
            
            // Schedule a new timer to debounce the fetch call
            fetchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                // Ensure this runs on the main actor since view model properties are MainActor-isolated.
                Task { @MainActor in
                    guard let self = self else { return }
                    // Double-check the condition
                    if self.viewModel.hasNextPage && !self.viewModel.isLoading {
                        print("📡 Triggering fetch for next page...")
                        await self.viewModel.fetch()
                    }
                }
            }
        }
    }
}










final class CreatePostViewController: UIViewController {
    
    var onPostCreated: (() -> Void)?
    
    // UI Elements
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter post title"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Post", for: .normal)
        button.addTarget(self, action: #selector(createPostTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Create Post"
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        view.addSubview(createButton)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(equalToConstant: 150),
            
            createButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func createPostTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            return
        }
        
        let newPost = Post(id: UUID().uuidString, content: content, userId: "123", likes: 0)
        
        Task {
            try await FirebaseDatabaseManager.shared.savePost(newPost)
            onPostCreated?()
            dismiss(animated: true)
        }
    }
}
