//
//  Model.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import Foundation

struct SearchModel: Decodable {
    let total: Int
    var results: [PhotoModel]
}

struct PhotoModel: Decodable, Hashable {
    
    var stringURLs: SizeURL
    
    func fullURL() -> URL {
        return URL(string: stringURLs.full)!
    }
    func smallURL() -> URL {
        return URL(string: stringURLs.small)!
    }
}

struct SizeURL: Decodable, Hashable {
    let full: String
    let small: String
}
