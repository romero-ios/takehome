import BirdsRepository
import Models
import UserInterface
import UIKit
import KingFisherExtension

public protocol AddNoteViewControllerCoordinating: AnyObject {
    func didAddNote(from viewController: AddNoteViewController, to birdId: String)
}

public final class AddNoteViewController: UIViewController {
    public weak var coordinator: AddNoteViewControllerCoordinating?
    private let viewModel: AddNoteViewModel
    
    private let birdImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let noteTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = "Enter a note..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        return textField
    }()
    
    public init(
        bird: Bird
    ) {
        self.viewModel = AddNoteViewModel(bird: bird)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configure()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackground
        title = viewModel.birdName
        noteTextField.delegate = self
        
        view.addSubview(birdImageView)
        view.addSubview(noteTextField)
        
        NSLayoutConstraint.activate([
            birdImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            birdImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            birdImageView.widthAnchor.constraint(equalToConstant: 100),
            birdImageView.heightAnchor.constraint(equalToConstant: 100),
            
            noteTextField.topAnchor.constraint(equalTo: birdImageView.bottomAnchor, constant: 24),
            noteTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noteTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func configure() {
        if let url = URL(string: viewModel.birdImageUrl) {
            birdImageView.kf.setWatermarkedImage(with: url)
        }
    }
}

extension AddNoteViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let noteText = textField.text, !noteText.isEmpty else {
            textField.resignFirstResponder()
            return true
        }
        
        textField.resignFirstResponder()
        
        Task {
            do {
                try await viewModel.addNote(comment: noteText)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.coordinator?.didAddNote(from: self, to: self.viewModel.birdId)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let alert = UIAlertController(
                        title: "Error Adding Note", 
                        message: "There was a problem adding your note. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        
        return true
    }
}
