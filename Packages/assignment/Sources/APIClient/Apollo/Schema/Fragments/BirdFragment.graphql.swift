// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension API {
  struct BirdFragment: API.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment BirdFragment on Bird { __typename id thumb_url image_url latin_name english_name notes { __typename ...NoteFragment } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { API.Objects.Bird }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", API.ID.self),
      .field("thumb_url", String.self),
      .field("image_url", String.self),
      .field("latin_name", String.self),
      .field("english_name", String.self),
      .field("notes", [Note].self),
    ] }

    public var id: API.ID { __data["id"] }
    public var thumb_url: String { __data["thumb_url"] }
    public var image_url: String { __data["image_url"] }
    public var latin_name: String { __data["latin_name"] }
    public var english_name: String { __data["english_name"] }
    public var notes: [Note] { __data["notes"] }

    /// Note
    ///
    /// Parent Type: `Note`
    public struct Note: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { API.Objects.Note }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(NoteFragment.self),
      ] }

      public var id: API.ID { __data["id"] }
      public var comment: String { __data["comment"] }
      public var timestamp: Int { __data["timestamp"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var noteFragment: NoteFragment { _toFragment() }
      }
    }
  }

}