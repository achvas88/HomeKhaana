//
//  HomeTabBarController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.definesPresentationContext = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        
        if(fromView != toView)
        {
        UIView.transition(from: fromView, to: toView, duration: 0.2, options: [.transitionCrossDissolve], completion: nil)
        return true
        }
        return false
    }
}
