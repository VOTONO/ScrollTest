//
//  AgentErrors.swift
//  ScrollTest
//
//  Created by Vitali Mironov on 01.07.2022.
//

import Foundation

extension Agent {
    
    enum NetworkingError: LocalizedError {
        case badURLResponse(_ url: URL)
        case errorInputData, authError, serverError, unknown
        case badStatusCode(_ statusCode: Int)
        var errorDescription: String {
            switch self {
            case .badURLResponse(let url):
                return "[🔧🔥] Bad response from URL: \(url)"
            case .errorInputData:
                return "[💔🔥] Input data error"
            case .authError:
                return "[🔐🔥] Authorization problem"
            case .badStatusCode(let statusCode):
                return "[❌🔥] Bad status code returned: \(statusCode)"
            case .serverError:
                return "[🌎🔥] Server error"
            case .unknown:
                return "[⚠️🔥] Unknown error occured"
            }
        }
    }
}
