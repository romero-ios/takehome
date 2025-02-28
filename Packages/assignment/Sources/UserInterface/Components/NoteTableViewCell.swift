import UIKit

public final class NoteTableViewCell: UITableViewCell {
    public static let reuseIdentifier = String(describing: NoteTableViewCell.self)
    
    private lazy var noteView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(noteView)
        noteView.addSubview(noteLabel)
        
        NSLayoutConstraint.activate([
            noteView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.S),
            noteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.S),
            
            noteLabel.topAnchor.constraint(equalTo: noteView.topAnchor, constant: 14),
            noteLabel.leadingAnchor.constraint(equalTo: noteView.leadingAnchor, constant: Spacing.XL),
            noteLabel.trailingAnchor.constraint(equalTo: noteView.trailingAnchor, constant: -Spacing.XL),
            noteLabel.bottomAnchor.constraint(equalTo: noteView.bottomAnchor, constant: -14)
        ])
    }
    
    public func configure(with note: String) {
        noteLabel.text = note
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        noteLabel.text = nil
    }
}
