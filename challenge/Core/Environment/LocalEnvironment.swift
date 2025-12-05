//
//  LocalEnvironment.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

struct LocalEnvironment: Environment {
    let domainURL: URL? = nil
    let type: APIEnvironmentType = .local
}
