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
    
    var urls: SizeURL
    
    func fullURL() -> URL {
        return URL(string: urls.full)!
    }
    func smallURL() -> URL {
        return URL(string: urls.small)!
    }
}

struct SizeURL: Decodable, Hashable {
    let full: String
    let small: String
}
