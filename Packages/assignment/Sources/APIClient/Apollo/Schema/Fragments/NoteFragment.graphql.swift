// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension API {
  struct NoteFragment: API.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment NoteFragment on Note { __typename id comment timestamp }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { API.Objects.Note }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", API.ID.self),
      .field("comment", String.self),
      .field("timestamp", Int.self),
    ] }

    public var id: API.ID { __data["id"] }
    public var comment: String { __data["comment"] }
    public var timestamp: Int { __data["timestamp"] }
  }

}