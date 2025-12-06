//
//  LocalEnvironment.swift
//  challenge
//
//  Created by Wagner Sales on 30/11/25.
//

import Foundation

struct LocalEnvironment: Environment {
    var domainURL: URL?
    var type: APIEnvironmentType = .local
}
