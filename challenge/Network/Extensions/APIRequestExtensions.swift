//
//  APIRequestExtensions.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

extension APIRequest {
    var localURL: URL? {
        let fileName = String(describing: type(of: self))
        let localURL = Bundle(for: APIClient.self).url(forResource: fileName)

        return localURL
    }
}
