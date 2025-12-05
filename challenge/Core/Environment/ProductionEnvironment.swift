//
//  ProductionEnvironment.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

struct ProductionEnvironment: Environment {
    let domainURL: URL? = URL(string: AppConfiguration.apiBaseURL)
    let type: APIEnvironmentType = .production
}
