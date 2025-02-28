import BirdDetailFeature
import AddNoteFeature
import Navigation
import Models
import UIKit

public protocol AppViewControllerCoordinating: AnyObject {
    func didSelectBird(_ bird: Bird)
}

public final class AppCoordinator: Coordinator {
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let viewController = AppViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension AppCoordinator: AppViewControllerCoordinating {
    public func didSelectBird(_ bird: Bird) {
        let detailViewController = BirdDetailViewController(bird: bird)
        let nav = UINavigationController(rootViewController: detailViewController)
        detailViewController.coordinator = self
        navigationController.present(nav, animated: true)
    }
}

extension AppCoordinator: BirdDetailViewControllerCoordinating {
    public func didTapAddNote(from viewController: BirdDetailViewController, for bird: Bird) {
        let addNoteViewController = AddNoteViewController(bird: bird)
        addNoteViewController.coordinator = self
        let nav = UINavigationController(rootViewController: addNoteViewController)
        viewController.present(nav, animated: true)
    }
    
    public func didUpdateBird(from viewController: BirdDetailViewController, updatedBird: Bird) {
        if let appVC = navigationController.viewControllers.first as? AppViewController {
            appVC.updateBird(updatedBird)
        }
    }
}

extension AppCoordinator: AddNoteViewControllerCoordinating {
    public func didAddNote(from viewController: AddNoteViewController, to birdId: String) {
        viewController.dismiss(animated: true)
        
        // Find the bird detail view controller and tell it to refresh
        if let presentedVC = navigationController.presentedViewController as? UINavigationController,
           let detailVC = presentedVC.viewControllers.first as? BirdDetailViewController {
            Task {
                await detailVC.refreshBirdData()
            }
        }
    }
}
