import Foundation
import Apollo
import os

public protocol APIClient {
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy,
        contextIdentifier: UUID?,
        queue: DispatchQueue
    ) async throws -> Query.Data
    
    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool,
        queue: DispatchQueue
    ) async throws -> Mutation.Data
}

public enum APIError: LocalizedError {
    case noData
}

public class DefaultAPIClient: APIClient {
    private let logger = Logger(subsystem: "com.copilot.TakeHome", category: "APIClient")

    public static let shared = DefaultAPIClient(
        accessToken: Bundle.main.object(forInfoDictionaryKey: "API_ACCESS_TOKEN") as? String ?? "",
        endPointURL: URL(string: "https://takehome.graphql.copilot.money")!
    )

    private lazy var apollo: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)

        let client = URLSessionClient()
        let provider = NetworkInterceptorProvider(
            accessToken: accessToken,
            store: store,
            client: client
        )
        let requestChainTransport = RequestChainNetworkTransport(
          interceptorProvider: provider,
          endpointURL: endPointURL
        )
        return ApolloClient(networkTransport: requestChainTransport, store: store)
    }()
    
    private let accessToken: String
    private let endPointURL: URL
    
    init(
        accessToken: String,
        endPointURL: URL
    ) {
        self.accessToken = accessToken
        self.endPointURL = endPointURL
    }
    
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) async throws -> Query.Data {
        return try await withCheckedThrowingContinuation { continuation in
            
            self.apollo.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: contextIdentifier,
                queue: queue
            ) { [weak self] result in
                switch result {
                case let .success(result):
                    if let data = result.data {
                        continuation.resume(returning: data)
                    } else {
                        self?.logger.error("Data was not present for a successful response")
                        continuation.resume(throwing: APIError.noData)
                    }
                case let .failure(error):
                    self?.logger.error("Fetch error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @discardableResult
    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true,
        queue: DispatchQueue = .main
    ) async throws -> Mutation.Data {
        return try await withCheckedThrowingContinuation { continuation in
            self.apollo.perform(
                mutation: mutation,
                publishResultToStore: publishResultToStore,
                queue: queue
            ) { [weak self] result in
                switch result {
                case let .success(result):
                    if let data = result.data {
                        continuation.resume(returning: data)
                    } else {
                        self?.logger.error("Data was not present for a successful response")
                        continuation.resume(throwing: APIError.noData)
                    }
                case let .failure(error):
                    self?.logger.error("Mutation error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

class AuthorizationInterceptor: ApolloInterceptor {
  let id: String = UUID().uuidString

  private let accessToken: String

  init(accessToken: String) {
    self.accessToken = accessToken
  }

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    request.addHeader(name: "Authorization", value: "Bearer \(accessToken)")
    chain.proceedAsync(
      request: request,
      response: response,
      interceptor: self,
      completion: completion
    )
  }
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
  private let store: ApolloStore
  private let client: URLSessionClient
  private let accessToken: String

  init(accessToken: String, store: ApolloStore, client: URLSessionClient) {
    self.store = store
    self.client = client
    self.accessToken = accessToken
    super.init(client: client, store: store)
  }

  override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
    var interceptors = super.interceptors(for: operation)
    interceptors.insert(AuthorizationInterceptor(accessToken: accessToken), at: 0)
    return interceptors
  }
}
