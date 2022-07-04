//
//  ImageCache.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 03.07.2022.
//

import UIKit

protocol ImageCacheProtocol {
    subscript(_ url: URL) -> Data? { get set }
}

final class ImageCache: ImageCacheProtocol {
    private let cache: LRUCache<NSURL, Data> = {
        let cache = LRUCache<NSURL, Data>()
        cache.countLimit = 100 // items limit
        cache.totalCostLimit = 1024 * 1024 * 256 // memory limit
        return cache
    }()
    
    subscript(_ key: URL) -> Data? {
        get { cache.value(forKey: key as NSURL) }
        set { cache.setValue(newValue!, forKey: key as NSURL) }
    }
}
