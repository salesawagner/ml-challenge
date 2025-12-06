//
//  ProductionEnvironment.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

struct ProductionEnvironment: Environment {
    var domainURL: URL? = URL(string: AppConfiguration.apiBaseURL)
    var type: APIEnvironmentType = .production
}
