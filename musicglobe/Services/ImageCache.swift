//
//  ImageCache.swift
//  musicglobe
//
//  Simple image caching service
//

import UIKit

actor ImageCache {
  static let shared = ImageCache()

  private var cache: [URL: UIImage] = [:]
  private var loadingTasks: [URL: Task<UIImage?, Error>] = [:]

  private init() {}

  func image(for url: URL) async throws -> UIImage? {
    // Check cache first
    if let cached = cache[url] {
      return cached
    }

    // Check if already loading
    if let task = loadingTasks[url] {
      return try await task.value
    }

    // Start new loading task
    let task = Task<UIImage?, Error> {
      let (data, _) = try await URLSession.shared.data(from: url)
      guard let image = UIImage(data: data) else {
        return nil
      }
      return image
    }

    loadingTasks[url] = task

    defer {
      loadingTasks[url] = nil
    }

    let image = try await task.value

    if let image = image {
      cache[url] = image
    }

    return image
  }

  func clearCache() {
    cache.removeAll()
  }

  func removeImage(for url: URL) {
    cache[url] = nil
  }
}
