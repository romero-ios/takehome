import Models
import BirdsRepository
import Foundation

public final class AddNoteViewModel {
    private let repository: BirdsRepository
    private let bird: Bird
    
    public init(
        bird: Bird,
        repository: BirdsRepository = DefaultBirdsRepository()
    ) {
        self.bird = bird
        self.repository = repository
    }
    
    public var birdImageUrl: String {
        return bird.thumbUrl
    }
    
    public var birdName: String {
        return bird.englishName
    }
    
    public var birdId: String {
        return bird.id
    }
    
    public func addNote(comment: String) async throws {
        let timestamp = Int(Date().timeIntervalSince1970)
        try await repository.addNote(birdId: bird.id, comment: comment, timestamp: timestamp)
    }
} 
