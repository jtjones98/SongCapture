//
//  ImageLoader.swift
//  SongCapture
//
//  Created by John Jones on 1/16/26.
//

import UIKit

private enum ImageLoaderError: Error {
    case invalidURL
    case decodeFailed
}

protocol ImageLoading: AnyObject {
    func image(for url: String) async throws -> UIImage
}

final class ImageLoader: ImageLoading {
    
    private let cache = NSCache<NSString, UIImage>()
    private var inFlight: [String: Task<UIImage, Error>] = [:]
    
    func image(for url: String) async throws -> UIImage {
        
        if let cached = cache.object(forKey: url as NSString) {
            print("JTJ: Loading cached image for \(url)")
            return cached
        }
        
        if let task = inFlight[url] {
            print("JTJ: task for \(url) is already in flight")
            return try await task.value
        }
        
        let task = Task<UIImage, Error> { [cache] in
            try Task.checkCancellation()
            
            // Validate URL
            guard let imageURL = URL(string: url) else {
                throw ImageLoaderError.invalidURL
            }
            
            var data = Data()
            
            if imageURL.scheme == "musicKit" {
                data = try await Task.detached(priority: .utility) {
                    try Data(contentsOf: imageURL)
                }.value
            } else {
                // Fetch image data
                let (sessionData, response) = try await URLSession.shared.data(from: imageURL)
                data = sessionData
                
                // HTTP status check
                if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
                    throw URLError(.badServerResponse)
                }
            }
            
            // Decode image
            guard let image = UIImage(data: data) else {
                throw ImageLoaderError.decodeFailed
            }
            
            cache.setObject(image, forKey: url as NSString)
            
            return image
        }
        
        inFlight[url] = task
        
        do {
            let image = try await task.value
            inFlight[url] = nil
            print("JTJ: returning image for \(url)")
            return image
        } catch {
            inFlight[url] = nil
            print("JTJ: throwing error from loading image for \(url): \(error.localizedDescription)")
            throw error
        }
    }
    
    private func cachedImage(for url: String) -> UIImage? {
        cache.object(forKey: url as NSString)
    }
}
