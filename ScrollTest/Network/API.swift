//
//  API.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import Foundation
import Combine

enum API {
    static private let agent = Agent()
    static private let base = URL(string: "https://api.unsplash.com")!
    static private let keyItem = "ZIoOgo_VF7_Fcmb0BAuG-xUsaB3GcdYCRMWCr77RPqg"
}

extension API {
    static func getRandomPhotos(page: Int, limit: Int) -> AnyPublisher<SearchModel, Error> {
        let url = base.appendingPathComponent("/photos/random")
        let queryItem = [URLQueryItem(name: "content_filter", value: "high"),
                         URLQueryItem(name: "orientation", value: "squarish"),
                         URLQueryItem(name: "count", value: "\(limit)"),
                         URLQueryItem(name: "per_page", value: "\(page)"),
                         URLQueryItem(name: "client_id", value: self.keyItem),]
        return agent.run(url: url, parameters: queryItem)
    }
}
