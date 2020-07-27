//
//  UserInitializationErrorViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/5/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class UserInitializationErrorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnRetryClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: true, completion: nil)
    }
}
