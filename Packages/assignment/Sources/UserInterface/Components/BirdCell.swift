import UIKit
import KingFisherExtension

public final class BirdCell: UICollectionViewCell {
    public static let reuseIdentifier = String(describing: BirdCell.self)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let vignetteGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        gradient.locations = [0.0, 0.5, 0.75, 1.0]
        return gradient
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        vignetteGradient.frame = bounds
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 0
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.layer.addSublayer(vignetteGradient)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.M),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.M),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.XL)
        ])
    }
    
    public func configure(imageUrl: String, name: String) {
        nameLabel.text = name
        
        if let url = URL(string: imageUrl) {
            imageView.kf.setWatermarkedImage(with: url)
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        nameLabel.text = nil
    }
}
