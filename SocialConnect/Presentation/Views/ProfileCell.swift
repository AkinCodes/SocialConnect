import UIKit

final class ProfileCell: UICollectionViewCell {

    // MARK: - Properties
    static let reuseIdentifier = "ProfileCell"

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        let mainStack = UIStackView(arrangedSubviews: [profileImageView, nameLabel, bioLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        contentView.addSubview(followButton)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            mainStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            followButton.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 12),
            followButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.heightAnchor.constraint(equalToConstant: 35),

            contentView.bottomAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 10)
        ])
    }
    

    // MARK: - Configure Cell
    func configure(with item: ProfileItem) {
        switch item {
        case .userInfo(let name, let bio, let imageUrl):
            nameLabel.text = name
            bioLabel.text = bio
            profileImageView.image = UIImage(systemName: "person.circle.fill")

            if let imageUrl = imageUrl {
                profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "person.circle.fill"))
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill") 
            }

        case .post:
            break
        }
    }
}
