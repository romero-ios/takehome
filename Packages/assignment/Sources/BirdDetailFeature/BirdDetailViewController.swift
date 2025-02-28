import BirdsRepository
import Models
import UserInterface
import KingFisherExtension
import UIKit

public protocol BirdDetailViewControllerCoordinating: AnyObject {
    func didTapAddNote(from viewController: BirdDetailViewController, for bird: Bird)
    func didUpdateBird(from viewController: BirdDetailViewController, updatedBird: Bird)
}

public final class BirdDetailViewController: UIViewController {
    private let maxHeaderHeight: CGFloat = 306
    private let minHeaderHeight: CGFloat = 133

    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var notesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var communityNotesLabel: UILabel = {
        let label = UILabel()
        label.text = "Community Notes"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var headerGradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var gradientLayer = CAGradientLayer()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .primaryBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addNoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("add a note", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.contentVerticalAlignment = .center
        button.backgroundColor = .appBlue
        button.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
        return button
    }()
    
    private var headerHeightConstraint: NSLayoutConstraint!
    
    private let minimumContentView = UIView()
    
    private var minimumContentViewConstraints: [NSLayoutConstraint] = []
    
    public weak var coordinator: BirdDetailViewControllerCoordinating?
    private let viewModel: BirdDetailViewModel

    public init(bird: Bird, repository: BirdsRepository = DefaultBirdsRepository()) {
        self.viewModel = BirdDetailViewModel(bird: bird, repository: repository)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBirdImage()
        setupMinimumScrollableContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = viewModel.englishName
        headerGradientView.alpha = 0
    
        // Setup container for notes section
        view.addSubview(headerImageView)
        view.addSubview(notesContainerView)
        view.addSubview(addNoteButton)
        
        // Add components to the notes container
        notesContainerView.addSubview(tableView)
        notesContainerView.addSubview(communityNotesLabel)
        notesContainerView.addSubview(headerGradientView)
        
        // Create header height constraint that we'll animate
        headerHeightConstraint = headerImageView.heightAnchor.constraint(equalToConstant: maxHeaderHeight)
        
        setupGradientLayer()
        
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerHeightConstraint,
            headerImageView.widthAnchor.constraint(equalTo: headerImageView.heightAnchor),
            headerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            notesContainerView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: Spacing.XL),
            notesContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            notesContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            notesContainerView.bottomAnchor.constraint(equalTo: addNoteButton.topAnchor),
            
            communityNotesLabel.topAnchor.constraint(equalTo: notesContainerView.topAnchor),
            communityNotesLabel.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor),
            
            // Position the gradient view at the top
            headerGradientView.topAnchor.constraint(equalTo: communityNotesLabel.bottomAnchor, constant: Spacing.XL),
            headerGradientView.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor),
            headerGradientView.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor),
            headerGradientView.heightAnchor.constraint(equalToConstant: 40),
            
            // Position the table view to start at the same place, but adjust content inset to prevent initial overlap
            tableView.topAnchor.constraint(equalTo: communityNotesLabel.bottomAnchor, constant: Spacing.XL),
            tableView.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: notesContainerView.bottomAnchor),
            
            addNoteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addNoteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addNoteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addNoteButton.heightAnchor.constraint(equalToConstant: 95)
        ])
    }
    
    private func setupGradientLayer() {
        gradientLayer.colors = [
            UIColor.primaryBackground.cgColor,
            UIColor.primaryBackground.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        headerGradientView.layer.addSublayer(gradientLayer)
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = [
            UIColor.primaryBackground.cgColor,
            UIColor.primaryBackground.withAlphaComponent(0.0).cgColor
        ]
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Bug workaround: Update gradient colors when switching between light/dark mode
            // CAGradientLayer colors don't automatically adapt to trait changes
            updateGradientColors()
        }
    }
    
    private func loadBirdImage() {
        if let url = URL(string: viewModel.imageUrl) {
            headerImageView.kf.setWatermarkedImage(with: url)
        }
    }
    
    @objc private func addNoteTapped() {
        coordinator?.didTapAddNote(from: self, for: viewModel.bird)
    }
    
    private func setupMinimumScrollableContent() {
        // Create and add a transparent view to force minimum content height
        minimumContentView.backgroundColor = .clear
        minimumContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add it to the table's footer
        let footerContainer = UIView()
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(minimumContentView)
        
        // Set the footer view
        tableView.tableFooterView = footerContainer

        // We'll update its height in viewDidLayoutSubviews
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame
        gradientLayer.frame = headerGradientView.bounds
        
        updateMinimumScrollableContent()
    }
    
    private func updateMinimumScrollableContent() {
        // Force minimal content height that allows full header collapse
        let headerDifference = maxHeaderHeight - minHeaderHeight
        
        // Calculate visible height after the header is collapsed
        let visibleHeight = view.bounds.height - minHeaderHeight - addNoteButton.frame.height
        
        // Calculate current content height (section + rows)
        var currentContentHeight: CGFloat = 0
        for i in 0..<viewModel.noteCount {
            currentContentHeight += tableView(tableView, heightForRowAt: IndexPath(row: i, section: 0))
        }
        
        // Calculate minimum needed height to ensure scrolling works
        let minimumNeededHeight = visibleHeight + headerDifference + 100 // add extra padding
        
        // Set minimum height only if current content is insufficient
        if currentContentHeight < minimumNeededHeight {
            guard let footerView = tableView.tableFooterView else { return }
            
            // Set footer height to make up the difference
            let footerHeight = minimumNeededHeight - currentContentHeight
            
            // Update footer view frame
            var footerFrame = footerView.frame
            footerFrame.size.height = footerHeight
            footerFrame.size.width = tableView.bounds.width
            footerView.frame = footerFrame
            
            // Deactivate previous constraints to avoid conflicts
            NSLayoutConstraint.deactivate(minimumContentViewConstraints)
            minimumContentViewConstraints.removeAll()
            
            // Create and activate new constraints
            let newConstraints = [
                minimumContentView.topAnchor.constraint(equalTo: footerView.topAnchor),
                minimumContentView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
                minimumContentView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
                minimumContentView.heightAnchor.constraint(equalToConstant: footerHeight)
            ]
            
            minimumContentViewConstraints = newConstraints
            NSLayoutConstraint.activate(minimumContentViewConstraints)
            
            // Re-set the footer view to apply changes
            tableView.tableFooterView = footerView
        }
    }
    
    public func refreshBirdData() async {
        do {
            if let updatedBird = try await viewModel.refreshBirdData() {
                await MainActor.run {
                    tableView.reloadData()
                    updateMinimumScrollableContent()
                    coordinator?.didUpdateBird(from: self, updatedBird: updatedBird)
                }
            }
        } catch {
            await MainActor.run {
                let alert = UIAlertController(
                    title: "Error Refreshing Data",
                    message: "There was a problem updating the bird information. Please try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    Task {
                        await self?.refreshBirdData()
                    }
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
            }
        }
    }
}

extension BirdDetailViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Account for content inset when calculating offset
        let adjustedOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        
        // For bird image header animation
        let newHeight = max(minHeaderHeight, maxHeaderHeight - adjustedOffsetY)
        headerHeightConstraint.constant = newHeight
        
        // Update gradient opacity based on scroll position
        let initialFadePoint: CGFloat = 0
        let fullFadePoint: CGFloat = 20
        
        let fadeProgress = min(1.0, max(0.0, (adjustedOffsetY - initialFadePoint) / (fullFadePoint - initialFadePoint)))
        headerGradientView.alpha = fadeProgress
    }
}

extension BirdDetailViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.noteCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else {
            return UITableViewCell()
        }
        
        let note = viewModel.note(at: indexPath.row)
        cell.configure(with: note.comment)
        return cell
    }
}

extension BirdDetailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
