//
//  BundleExtensions.swift
//  API
//
//  Created by Wagner Sales
//

import Foundation

#if DEBUG
/// Specific for debug
extension Bundle {
    private func fileExists(resourceName: String, ofType ext: String? = "json") -> Bool {
        url(forResource: resourceName, withExtension: ext) != nil
    }

    func url(forResource resourceName: String, ofType ext: String? = "json") -> URL? {
        guard fileExists(resourceName: resourceName, ofType: ext) else {
            return nil
        }

        return url(forResource: resourceName, withExtension: ext, subdirectory: nil)
    }
}
#endif
