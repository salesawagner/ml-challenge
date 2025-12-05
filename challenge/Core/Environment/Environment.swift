//
//  APIEnvironment.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

protocol Environment {
    var domainURL: URL? { get }
    var type: APIEnvironmentType { get }
}
