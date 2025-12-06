//
//  APIEnvironment.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

protocol Environment {
    var domainURL: URL? { get set }
    var type: APIEnvironmentType { get set }
}
