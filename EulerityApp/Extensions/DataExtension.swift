//
//  DataExtension.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/10/21.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8){ append(data) }
    }
}
