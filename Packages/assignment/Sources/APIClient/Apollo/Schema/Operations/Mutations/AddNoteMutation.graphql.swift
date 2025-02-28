// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension API {
  class AddNoteMutation: GraphQLMutation {
    public static let operationName: String = "addNote"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation addNote($birdId: ID!, $comment: String!, $timestamp: Int!) { addNote(birdId: $birdId, comment: $comment, timestamp: $timestamp) }"#
      ))

    public var birdId: ID
    public var comment: String
    public var timestamp: Int

    public init(
      birdId: ID,
      comment: String,
      timestamp: Int
    ) {
      self.birdId = birdId
      self.comment = comment
      self.timestamp = timestamp
    }

    public var __variables: Variables? { [
      "birdId": birdId,
      "comment": comment,
      "timestamp": timestamp
    ] }

    public struct Data: API.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { API.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("addNote", API.ID?.self, arguments: [
          "birdId": .variable("birdId"),
          "comment": .variable("comment"),
          "timestamp": .variable("timestamp")
        ]),
      ] }

      public var addNote: API.ID? { __data["addNote"] }
    }
  }

}