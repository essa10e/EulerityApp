//
//  NetworkManager.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/7/21.
//

import Foundation
import UIKit

//typealias Parameters = [String: String]


class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseURL = "https://eulerity-hackathon.appspot.com"
    private let getPathURL = "/image"
    private let uploadPathURL = "/upload"
    
//    func getRequest() {
//        guard let url = URL(string: "https://eulerity-hackathon.appspot.com/upload") else { return }
//        var request = URLRequest(url: url)
//
//        let boundary = "Boundary-\(NSUUID().uuidString)"
//
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        let dataBody = createDataBody(withParameters: nil, media: nil, boundary: boundary)
//        request.httpBody = dataBody
//
//        let session = URLSession.shared
//        session.dataTask(with: request) {(data, response, error) in
//            if let response = response {
//                print(response)
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                } catch {
//                    print(error)
//                }
//            }
//        }.resume()
//
//    }
    
    func fetchUploadURL(completed: @escaping (Result<ImageResponse, ErrorMessage>) -> Void) {
        let endpoint = baseURL + uploadPathURL
                
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidData))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(.failure(.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let imageUrl = try decoder.decode(ImageResponse.self, from: data)
                completed(.success(imageUrl))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        dataTask.resume()
    }
    
    func fetchImagesRequest(completed: @escaping (Result<[Image], ErrorMessage>) -> Void) {
        let endpoint = baseURL + getPathURL
                
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidData))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(.failure(.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let imageUrl = try decoder.decode([Image].self, from: data)
                completed(.success(imageUrl))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        dataTask.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8){ append(data) }
    }
}
