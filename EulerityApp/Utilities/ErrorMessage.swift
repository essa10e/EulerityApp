//
//  ErrorMessage.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/7/21.
//

import Foundation

enum ErrorMessage: String, Error {
    case invalidData = "The data received from the server was invalid. Please try again"
    case invalidResponse = "Invalid response from the server. Please try again"
    case unableToComplet = "Unable to complete your request."
}
