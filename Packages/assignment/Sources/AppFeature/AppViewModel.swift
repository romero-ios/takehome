import Models
import BirdsRepository
import Foundation

public final class AppViewModel {
    private let repository: BirdsRepository
    private(set) var birds: [Bird] = []
    private(set) var filteredBirds: [Bird] = []
    
    public init(
        repository: BirdsRepository = DefaultBirdsRepository()
    ) {
        self.repository = repository
    }
    
    public func loadBirds() async throws -> [Bird] {
        let birds = try await repository.fetchBirds()
        self.birds = birds
        self.filteredBirds = birds
        return birds
    }
    
    public func filterBirds(with searchText: String) -> [Bird] {
        if searchText.isEmpty {
            filteredBirds = birds
        } else {
            filteredBirds = birds.filter { bird in
                bird.englishName.lowercased().contains(searchText.lowercased()) ||
                bird.latinName.lowercased().contains(searchText.lowercased())
            }
        }
        return filteredBirds
    }
    
    public func updateBird(_ updatedBird: Bird) {
        if let index = birds.firstIndex(where: { $0.id == updatedBird.id }) {
            birds[index] = updatedBird
        }
        
        if let filteredIndex = filteredBirds.firstIndex(where: { $0.id == updatedBird.id }) {
            filteredBirds[filteredIndex] = updatedBird
        }
    }
} 
