import UIKit
import SDWebImage

final class PostCell: UICollectionViewCell {
    static let reuseIdentifier = "PostCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        [profileImageView, titleLabel, contentLabel, likeButton].forEach { containerView.addSubview($0) }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            profileImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            likeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            likeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            likeButton.widthAnchor.constraint(equalToConstant: 30),
            likeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(with post: Post) {
        titleLabel.text = post.optionalTitle
        contentLabel.text = post.content
        contentLabel.textColor = .red 
        
        if let imageUrl = URL(string: post.optionalImageUrl ?? "") {
            profileImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "person.circle"))
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
