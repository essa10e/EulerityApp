//
//  EditViewController.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/7/21.
//

import CoreImage
import UIKit
import Kingfisher

typealias Parameters = [String: String]

class EditViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    
    var selectedImage: String?
    var context: CIContext!
    var currentFilter: CIFilter!
    var currentImage: UIImage?
    
    private var uploadImage: ImageResponse!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Editing"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                barButtonSystemItem: .save,
                target: self,
                action: #selector(saveImage))
        
        let imageURL = URL(string: selectedImage!)
        let resource = ImageResource(downloadURL: imageURL!)
        imageView?.kf.indicatorType = .activity
        imageView?.kf.setImage(
            with: resource,
            placeholder: nil,
            options: nil,
            progressBlock: nil)
        
        currentImage = imageView.image
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
        guard let image = currentImage else { return }
        let originImage = CIImage(image: image)
        currentFilter.setValue(originImage, forKey: kCIInputImageKey)
    }
    
    func applyFilter() {

        let inputKeys = currentFilter.inputKeys
    
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(
                CIVector(x: currentImage!.size.width / 2,
                y: currentImage!.size.height / 2),
                forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let filteredImage = UIImage(cgImage: cgImage)
            imageView.image = filteredImage
        }
    }
    
    @IBAction func intensityChange(_ sender: Any) {
        applyFilter()
    }

    @IBAction func filterButton(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlue", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        
        currentImage = imageView.image
        currentFilter = CIFilter(name: actionTitle)
        
        guard let image = currentImage else { return }

        let originImage = CIImage(image: image)
        
        currentFilter.setValue(originImage, forKey: kCIInputImageKey)
        applyFilter()
    }
    
    @objc func saveImage() {
        
        var uploadeUrlPath: String = ""
        
        // Network upload Request:
        if self.imageView != nil {
            NetworkManager.shared.fetchUploadURL() { [weak self] result in
                switch result {
                case .success(let results):
                    self?.uploadImage = results
                    self!.postRequest(postUrl: results.url)
                    uploadeUrlPath = results.url
                    print(uploadeUrlPath)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func postRequest(postUrl: String) {
        let urlPath = postUrl
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let mimeType = "image/jpg"
        
        let lineBreak = "\r\n"
        var body = Data()
        var params: Parameters?
        params = ["appid": "isa86@protonmail.com", "session":"Testing"]
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        let imageData = currentImage?.jpegData(compressionQuality: 1.0)
        let filename = "image1"
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageData!)
        body.append("\(lineBreak)")
        body.append("--\(boundary)--\(lineBreak)")
        
        request.httpBody = body as Data

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
