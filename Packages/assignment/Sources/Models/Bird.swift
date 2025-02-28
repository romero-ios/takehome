import Foundation

public struct Bird: Model, Hashable {
    public let id: String
    public let thumbUrl: String
    public let imageUrl: String
    public let latinName: String
    public let englishName: String
    public let notes: [Note]
    
    public init(
        id: String,
        thumbUrl: String,
        imageUrl: String,
        latinName: String,
        englishName: String,
        notes: [Note]
    ) {
        self.id = id
        self.thumbUrl = thumbUrl
        self.imageUrl = imageUrl
        self.latinName = latinName
        self.englishName = englishName
        self.notes = notes
    }
}
