import Foundation

public struct Note: Model, Hashable {
    public let id: String
    public let comment: String
    public let timestamp: Int

    public init(
        id: String, 
        comment: String, 
        timestamp: Int
    ) {
        self.id = id
        self.comment = comment
        self.timestamp = timestamp
    }
}
