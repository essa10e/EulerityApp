//
//  Endpoint.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/7/21.
//

import UIKit

struct Image: Codable {
    let url: String
    let created, updated : String
}


/* it has to be deleted later if not going to be used anymore. **/
struct ImageRequest: Encodable {
    let attachment: String
    let fileName: String
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "image\(arc4random()).jpeg"
        
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}
