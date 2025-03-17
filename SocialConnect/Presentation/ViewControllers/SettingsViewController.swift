import UIKit
import Combine

@MainActor
final class SettingsViewController: UIViewController {
    
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Section, SettingOption>!
    private var viewModel = SettingsViewModel(authManager: .shared)
    private var cancellables = Set<AnyCancellable>()
    
    var onLogout: (() -> Void)?
    var onOptionSelected: ((SettingOption) -> Void)?

    enum Section: CaseIterable {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        setupBindings()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Settings"
    }

    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        tableView.delegate = self
        view.addSubview(tableView)
        
        configureDataSource()
    }

    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, SettingOption>(tableView: tableView) { tableView, indexPath, setting in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var title: String?

            // Extract the title based on the case
            switch setting {
            case .editProfile(let t),
                 .notifications(let t),
                 .darkMode(let t),
                 .language(let t),
                 .logout(let t),
                 .deleteAccount(let t):
                title = t
            }

            cell.textLabel?.text = title
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    private func setupBindings() {
        viewModel.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.applySnapshot(with: settings)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(with settings: [SettingOption]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SettingOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(settings)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// ✅ Ensure logout option is handled
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedOption = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch selectedOption {
        case .logout:
            onLogout?() 
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
