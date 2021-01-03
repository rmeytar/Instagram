//
//  FilterViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 02/01/2021.
//

import UIKit
protocol FilterViewControllerDelegate {
    func updatePhoto(image: UIImage)
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterPhoto: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: FilterViewControllerDelegate?
    var selectedImage: UIImage!
    
    var CIfilterNames = ["CIPhotoEffectChrome",
                         "CIPhotoEffectMono",
                         "CIPhotoEffectFade",
                         "CIColorMonochrome",
                         "CIVignette",
                         "CISepiaTone",
                         "CIPhotoEffectInstant",
                         "CIPhotoEffectProcess"]
    
    var context = CIContext(options: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterPhoto.image = selectedImage

    }
    
    @IBAction func cancelBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.updatePhoto(image: self.filterPhoto.image!)
    }
    
    // resize the  filter photos for a quick load
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage!
    }
}


extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIfilterNames.count
    }
    
    
//apply filters on the collection view cell photos
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        let newImage = resizeImage(image: selectedImage, newWidth: 150)
        let ciImage = CIImage(image: newImage)
        let filter = CIFilter(name: CIfilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage  {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            cell.filterPhoto.image = UIImage(cgImage: result!)
        }
        return cell
    }
    
    //apply the filter on the original photo
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: CIfilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage  {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            self.filterPhoto.image = UIImage(cgImage: result!)
        }
        
    }
}

