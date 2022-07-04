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
    static func getRandomCats(page: Int, limit: Int) -> AnyPublisher<SearchModel, Error> {
        let url = base.appendingPathComponent("/search/photos")
        let queryItem = [URLQueryItem(name: "query", value: "cat"),
                         URLQueryItem(name: "orientation", value: "squarish"),
                         URLQueryItem(name: "page", value: "\(page)"),
                         URLQueryItem(name: "per_page", value: "\(limit)"),
                         URLQueryItem(name: "client_id", value: self.keyItem)]
        return agent.run(url: url, parameters: queryItem)
    }
}
