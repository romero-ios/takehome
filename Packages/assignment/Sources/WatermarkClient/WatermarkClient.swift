import Foundation
import os

public protocol WatermarkClient {
    func watermarkImage(imageData: Data) async throws -> Data
}

public class DefaultWatermarkClient: WatermarkClient {
    private let logger = Logger(subsystem: "com.copilot.TakeHome", category: "WatermarkClient")
    
    private let watermarkURL = URL(string: "https://us-central1-copilot-take-home.cloudfunctions.net/watermark")!
    private let session: URLSession
    
    public init(
        session: URLSession = .shared
    ) {
        self.session = session
    }
    
    public func watermarkImage(imageData: Data) async throws -> Data {
        var request = URLRequest(url: watermarkURL)
        request.httpMethod = "POST"
        request.httpBody = imageData
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Invalid Response")
            throw WatermarkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            logger.error("Status code: \(httpResponse.statusCode)")
            throw WatermarkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        guard let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
              contentType == "image/jpeg" else {
            logger.error("Invalid content type")
            throw WatermarkError.invalidContentType
        }
        
        return data
    }
}

public enum WatermarkError: Error {
    case invalidResponse
    case serverError(statusCode: Int)
    case invalidContentType
}
