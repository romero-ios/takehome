import WatermarkClient
import Kingfisher
import Foundation
import UIKit
import os

public struct WatermarkProcessor: ImageProcessor {
    private let logger = Logger(subsystem: "com.copilot.TakeHome", category: "WatermarkProcessor")
    
    public let identifier = "com.copilot.TakeHome.watermarkProcessor"
    private let watermarkClient: WatermarkClient
    
    public init(
        watermarkClient: WatermarkClient = DefaultWatermarkClient()
    ) {
        self.watermarkClient = watermarkClient
    }
    
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            guard let imageData = image.kf.jpegRepresentation(compressionQuality: 1.0) else {
                return image
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            var processedImage: KFCrossPlatformImage?
            var processingError: Error?
            
            Task {
                do {
                    let watermarkedData = try await watermarkClient.watermarkImage(imageData: imageData)
                    if let watermarkedImage = KFCrossPlatformImage(data: watermarkedData) {
                        processedImage = watermarkedImage
                    }
                } catch {
                    processingError = error
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            if let error = processingError {
                logger.error("Error watermarking image: \(error)")
                return image
            }
            
            return processedImage ?? image
            
        case .data(let data):
            let semaphore = DispatchSemaphore(value: 0)
            var processedImage: KFCrossPlatformImage?
            var processingError: Error?
            
            Task {
                do {
                    let watermarkedData = try await watermarkClient.watermarkImage(imageData: data)
                    if let watermarkedImage = KFCrossPlatformImage(data: watermarkedData) {
                        processedImage = watermarkedImage
                    }
                } catch {
                    processingError = error
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            if let error = processingError {
                logger.error("Error watermarking image: \(error)")
                if let originalImage = KFCrossPlatformImage(data: data) {
                    return originalImage
                }
                return nil
            }
            
            return processedImage
        }
    }
}

public class LoadingPlaceholderView: UIView, Placeholder {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let label = UILabel()
    
    public init(text: String = "Watermarking...") {
        super.init(frame: .zero)
        setupView(text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView(text: String = "Watermarking...") {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        ])
    }
}

extension KingfisherWrapper where Base: KFCrossPlatformImageView {
    @discardableResult
    public func setWatermarkedImage(
        with resource: Resource?,
        placeholder: Placeholder? = LoadingPlaceholderView(),
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) -> DownloadTask? {
        let processor = WatermarkProcessor()
        
        return setImage(
            with: resource,
            placeholder: placeholder,
            options: [.processor(processor)],
            progressBlock: progressBlock,
            completionHandler: completionHandler
        )
    }
}

