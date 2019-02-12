//
//  ImageCacheManager.swift
//  StylesCloud
//
//  Created by Orest Grabovskyi on 11/15/16.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

import Foundation
import AlamofireImage

public enum ImageFilters {
  case aspectScaledToFill(size: CGSize)
  case circle
  case aspectScaledToFillSizeCircle(size: CGSize)
  
  var aiFilter: ImageFilter {
    switch self {
    case .aspectScaledToFill(let size):
      return AspectScaledToFillSizeFilter(size: size)
      
    case .circle:
      return CircleFilter()
      
    case .aspectScaledToFillSizeCircle(let size):
      return AspectScaledToFillSizeCircleFilter(size: size)
    }
  }
}

public typealias ImageCacheCallback = (_ image:UIImage?, _ key: String) -> ()

/// Function which is return cached or downloader image
///
/// - Parameters:
///   - urlString: remote image url
///   - callback: return image downloaded from internet or from cache if available.
/// - Returns: image from cache if available
public func cacheImage(from urlString: String, filter:ImageFilters? = nil, callback:ImageCacheCallback? = nil) {
  let aiFilter = filter?.aiFilter
  ImageCacheManager.shared.image(from: urlString, filter: aiFilter, callback: callback)
}

final class ImageCacheManager {
  
  static let shared = ImageCacheManager()
  
  let imageDownloader = ImageDownloader(
    configuration: ImageDownloader.defaultURLSessionConfiguration(),
    downloadPrioritization: .fifo,
    maximumActiveDownloads: 15,
    imageCache: AutoPurgingImageCache()
  )
  
  private init() {
  }
  
  /// Function which is return
  ///
  /// - Parameters:
  ///   - urlString: remote image url
  ///   - callback: return image downloaded from internet or from cache if available.
  ///               Callback will be not called if image returned from cache immediatly
  /// - Returns: image from cache if available
  fileprivate func image(from urlString: String, filter:ImageFilter? = nil, callback:ImageCacheCallback? = nil) {
    
    guard let url = URL(string: urlString) else {
      callback?(nil, urlString)
      return
    }
    let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 15.0)
    imageDownloader.download(request, filter:filter) { (response) in
      callback?(response.result.value, urlString)
    }
  }
}
