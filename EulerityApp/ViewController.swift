//
//  ViewController.swift
//  EulerityApp
//
//  Created by Essa Aldo on 5/7/21.
//

import UIKit
import Kingfisher

class ViewController: UICollectionViewController {
    
    private var downloadedImage = [Image]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Eulerity"
        
        NetworkManager.shared.fetchImagesRequest() { [weak self] result in
            switch result {
            case .success(let results):
                print(results)
                self?.downloadedImage = results

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedImage.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image_id", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue ImageCell.")
        }
        
        let image_url = URL(string: "\(downloadedImage[indexPath.item].url)")!
        
        let resource = ImageResource(downloadURL: image_url)
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(
            with: resource,
            placeholder: nil,
            options: nil,
            progressBlock: nil)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedImage = "\(downloadedImage[indexPath.item].url)"
        self.performSegue(withIdentifier: "editVC", sender: selectedImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedImage = sender as? String else { return }
        
        if segue.identifier == "editVC" {
            guard let destinationVC = segue.destination as? EditViewController else { return }
            destinationVC.selectedImage = selectedImage
        }
    }
}
