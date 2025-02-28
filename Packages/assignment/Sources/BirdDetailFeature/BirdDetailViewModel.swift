import Models
import BirdsRepository
import Foundation

public final class BirdDetailViewModel {
    private let repository: BirdsRepository
    private(set) var bird: Bird
    
    public init(
        bird: Bird,
        repository: BirdsRepository = DefaultBirdsRepository()
    ) {
        self.bird = bird
        self.repository = repository
    }
    
    public func refreshBirdData() async throws -> Bird? {
        if let updatedBird = try await repository.fetchBird(id: bird.id) {
            self.bird = updatedBird
            return updatedBird
        }
        return nil
    }
    
    public var englishName: String {
        return bird.englishName
    }
    
    public var imageUrl: String {
        return bird.imageUrl
    }
    
    public var notes: [Note] {
        return bird.notes
    }
    
    public var noteCount: Int {
        return bird.notes.count
    }
    
    public func note(at index: Int) -> Note {
        return bird.notes[index]
    }
} 
