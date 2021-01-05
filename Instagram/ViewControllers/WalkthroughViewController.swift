//
//  WalkthroughViewController.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 05/01/2021.
//

import UIKit

class WalkthroughViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageContent = ["See our amazing app", "Made by MEYTAR ROZENBERG", "Have fun!"]
    var pageImage = ["background1", "background2", "background3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let startingVC = viewControllerAtIndex(index: 0) {
            setViewControllers([startingVC], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageContent.count {
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageFileName = pageImage[index]
            return pageContentVC
        }
        return nil
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
            setViewControllers([nextVC], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
    }
}
