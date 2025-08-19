import Foundation
import UIKit
import SwiftUI

/// High-performance image cache with preloading support
@available(iOS 15.0, *)
public class ImageCache: ObservableObject {
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var activeDownloads: Set<String> = []
    private let downloadQueue = DispatchQueue(label: "com.onboardingsdk.imagedownload", qos: .utility)
    
    private init() {
        // Setup cache configuration
        cache.countLimit = 100 // Max 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Setup disk cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("OnboardingSDK/ImageCache")
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        print("OnboardingSDK: 📸 Image cache initialized")
    }
    
    // MARK: - Public API
    
    /// Get cached image synchronously (returns nil if not cached)
    public func getCachedImage(for urlString: String) -> UIImage? {
        return cache.object(forKey: NSString(string: urlString))
    }
    
    /// Load image with caching (async)
    public func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check memory cache first
        if let cachedImage = cache.object(forKey: NSString(string: urlString)) {
            completion(cachedImage)
            return
        }
        
        // Check disk cache
        if let diskImage = loadFromDisk(urlString: urlString) {
            // Store in memory cache
            cache.setObject(diskImage, forKey: NSString(string: urlString))
            completion(diskImage)
            return
        }
        
        // Download if not in cache
        downloadImage(from: urlString, completion: completion)
    }
    
    /// Preload images for an onboarding flow
    public func preloadImages(for flow: OnboardingFlow) {
        let imageURLs = extractImageURLs(from: flow)
        
        print("OnboardingSDK: 🔄 Preloading \(imageURLs.count) images...")
        
        for urlString in imageURLs {
            // Skip if already cached or downloading
            if getCachedImage(for: urlString) != nil || activeDownloads.contains(urlString) {
                continue
            }
            
            downloadQueue.async {
                self.downloadImage(from: urlString) { image in
                    if image != nil {
                        print("OnboardingSDK: ✅ Preloaded image: \(urlString)")
                    }
                }
            }
        }
    }
    
    /// Clear all cached images
    public func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("OnboardingSDK: 🗑️ Image cache cleared")
    }
    
    // MARK: - Private Methods
    
    private func extractImageURLs(from flow: OnboardingFlow) -> [String] {
        var urls: [String] = []
        
        for page in flow.pages {
            if let imageURL = page.imageURL, !imageURL.isEmpty {
                urls.append(imageURL)
            }
        }
        
        return Array(Set(urls)) // Remove duplicates
    }
    
    private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Prevent duplicate downloads
        guard !activeDownloads.contains(urlString) else {
            completion(nil)
            return
        }
        
        activeDownloads.insert(urlString)
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.activeDownloads.remove(urlString)
            }
            
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                completion(nil)
                return
            }
            
            // Store in memory cache
            self?.cache.setObject(image, forKey: NSString(string: urlString))
            
            // Store in disk cache
            self?.saveToDisk(image: image, urlString: urlString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    private func saveToDisk(image: UIImage, urlString: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let filename = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        let fileURL = cacheDirectory.appendingPathComponent("\(filename).jpg")
        
        try? data.write(to: fileURL)
    }
    
    private func loadFromDisk(urlString: String) -> UIImage? {
        let filename = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let fileURL = cacheDirectory.appendingPathComponent("\(filename).jpg")
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
}
