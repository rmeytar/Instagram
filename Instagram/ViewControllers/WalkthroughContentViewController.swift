//
//  WalktthroughContentViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 05/01/2021.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var forwardBtn: UIButton!
    
    var index = 0
    var imageFileName = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentLbl.text = content
        backgroundImg.image = UIImage(named: imageFileName)
        pageControl.currentPage = index
        
        switch index {
        case 0...1:
            forwardBtn.setImage(UIImage(named: "arrow.png"), for: UIControl.State.normal)
        case 2:
            forwardBtn.setImage(UIImage(named: "doneIcon.png"), for: UIControl.State.normal)
        default:
            break
        }
    }
    
    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        switch index {
        case 0...1:
            let pageVC = parent as! WalkthroughViewController
            pageVC.forward(index: index)
        case 2:
            let defaults = UserDefaults.standard
            defaults.setValue(true, forKey: "hasViewedWalkthrough")
            
            dismiss(animated: true, completion: nil)
        default:
            print("")
        }
    }
    
}
