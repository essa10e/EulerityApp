//
//  EditViewController.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/7/21.
//

import CoreImage
import UIKit
import Kingfisher

class EditViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
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
        
        // sometimes crashes: found nil while implicity unwrapping an optional value.
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
        
//        if self.imageView != nil {
//            postRequest(postUrl: uploadeUrlPath)
//        }
    }
    
    func postRequest(postUrl: String) {

        let parameters = ["name" : "TestFile",
                          "description" : "EulerityApp Test"]

        guard let mediaImage = Media(withImage: imageView.image!, forKey: "image") else {
            return
        }


//        guard let url = URL(string: "https://eulerity-hackathon.appspot.com/upload") else { return }

        guard let url = URL(string: postUrl) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(NSUUID().uuidString)"

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("appid", forHTTPHeaderField: "isa86@protonmail.com")

        let dataBody = createDataBody(withParameters: parameters, media: mediaImage, boundary: boundary)
        request.httpBody = dataBody

        let session = URLSession.shared
        session.dataTask(with: request) {(data, response, error) in
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

    func createDataBody(withParameters params: Parameters?, media: Media?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()

        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }

        if let image = media {
           // for image in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.filename)\"\(lineBreak)")
                body.append("Content-Type: \(image.mimeType + lineBreak + lineBreak)")
                body.append(image.data)
                body.append(lineBreak)
            //}
        }

        body.append("--\(boundary)--\(lineBreak)")

        return body
    }
}


