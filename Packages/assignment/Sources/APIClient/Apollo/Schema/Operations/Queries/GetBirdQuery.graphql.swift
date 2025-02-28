// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension API {
  class GetBirdQuery: GraphQLQuery {
    public static let operationName: String = "getBird"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getBird($id: ID!) { bird(id: $id) { __typename ...BirdFragment } }"#,
        fragments: [BirdFragment.self, NoteFragment.self]
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { API.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("bird", Bird?.self, arguments: ["id": .variable("id")]),
      ] }

      public var bird: Bird? { __data["bird"] }

      /// Bird
      ///
      /// Parent Type: `Bird`
      public struct Bird: API.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { API.Objects.Bird }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(BirdFragment.self),
        ] }

        public var id: API.ID { __data["id"] }
        public var thumb_url: String { __data["thumb_url"] }
        public var image_url: String { __data["image_url"] }
        public var latin_name: String { __data["latin_name"] }
        public var english_name: String { __data["english_name"] }
        public var notes: [Note] { __data["notes"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var birdFragment: BirdFragment { _toFragment() }
        }

        public typealias Note = BirdFragment.Note
      }
    }
  }

}