import Foundation

public struct Section<T: Hashable>: Hashable {
    public let title: String?
    public let items: [T]
    
    public init(
        title: String?,
        items: [T]
    ) {
        self.title = title
        self.items = items
    }
}
