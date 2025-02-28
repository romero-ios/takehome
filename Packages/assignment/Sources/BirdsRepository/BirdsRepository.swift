import APIClient
import Models
import Foundation

public protocol BirdsRepository {
    func fetchBirds() async throws -> [Bird]
    func fetchBird(id: String) async throws -> Bird?
    func addNote(birdId: String, comment: String, timestamp: Int) async throws
}

public class DefaultBirdsRepository: BirdsRepository {
    private let client: APIClient
    
    public init(
        client: APIClient = DefaultAPIClient.shared
    ) {
        self.client = client
    }
    
    public func fetchBirds() async throws -> [Bird] {
        let query = API.BirdsQuery()
        
        let response = try await client.fetch(
            query: query,
            cachePolicy: .default,
            contextIdentifier: nil,
            queue: .main
        )
        
        return response.birds.map { .init(fragment: $0.fragments.birdFragment) }
    }
    
    public func fetchBird(id: String) async throws -> Bird? {
        let query = API.GetBirdQuery(id: id)
        
        let response = try await client.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheData,
            contextIdentifier: nil,
            queue: .main
        )
        
        if let birdFragment = response.bird?.fragments.birdFragment {
            return .init(fragment: birdFragment)
        } else {
            return nil
        }
    }
    
    public func addNote(birdId: String, comment: String, timestamp: Int) async throws {
        let mutation = API.AddNoteMutation(
            birdId: birdId,
            comment: comment,
            timestamp: timestamp
        )
        
        _ = try await client.perform(
            mutation: mutation,
            publishResultToStore: true,
            queue: .main
        )
    }
}

extension Bird {
    init(fragment: API.BirdFragment) {
        self.init(
            id: fragment.id,
            thumbUrl: fragment.thumb_url,
            imageUrl: fragment.image_url,
            latinName: fragment.latin_name,
            englishName: fragment.english_name,
            notes: fragment.notes.map { .init(fragment: $0.fragments.noteFragment) }
        )
    }
}

extension Note {
    init(fragment: API.NoteFragment) {
        self.init(
            id: fragment.id,
            comment: fragment.comment,
            timestamp: fragment.timestamp
        )
    }
}

