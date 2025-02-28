import BirdsRepository
import Models
import UserInterface
import UIKit

private enum SectionID {
    case birds
}

public class AppViewController: UIViewController {
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .label
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(BirdCell.self, forCellWithReuseIdentifier: BirdCell.reuseIdentifier)
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<SectionID, Bird> = {
       return UICollectionViewDiffableDataSource<SectionID, Bird>(collectionView: collectionView) { collectionView, indexPath, bird in
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BirdCell.reuseIdentifier, for: indexPath) as? BirdCell else {
               return UICollectionViewCell()
           }
           cell.configure(imageUrl: bird.thumbUrl, name: bird.englishName)
           return cell
       }
    }()
    
    
    public weak var coordinator: AppViewControllerCoordinating?
    private let viewModel: AppViewModel
    
    public init(
        viewModel: AppViewModel = AppViewModel()
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task {
            await loadData()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        navigationItem.titleView = searchBar
        
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadData() async {
        do {
            await MainActor.run {
                loadingIndicator.startAnimating()
                collectionView.alpha = 0
            }
            
            _ = try await viewModel.loadBirds()
            
            await MainActor.run {
                applySnapshot()
                loadingIndicator.stopAnimating()
                
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.alpha = 1
                }
            }
        } catch {
            await MainActor.run {
                loadingIndicator.stopAnimating()
                
                let alert = UIAlertController(
                    title: "Error Loading Birds",
                    message: "There was a problem loading the bird data. Please try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    Task {
                        await self?.loadData()
                    }
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.alpha = 1
                }
            }
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, Bird>()
        snapshot.appendSections([.birds])
        snapshot.appendItems(viewModel.filteredBirds)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func filterBirds(with searchText: String) {
        _ = viewModel.filterBirds(with: searchText)
        applySnapshot()
    }
    
    public func updateBird(_ updatedBird: Bird) {
        viewModel.updateBird(updatedBird)
        applySnapshot()
    }
}

extension AppViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = width / 2
        let cellHeight = cellWidth * 1.2
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension AppViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterBirds(with: searchText)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterBirds(with: "")
        searchBar.resignFirstResponder()
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
}

extension AppViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bird = viewModel.filteredBirds[indexPath.item]
        coordinator?.didSelectBird(bird)
    }
}
