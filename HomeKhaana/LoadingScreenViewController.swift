//
//  LoadingScreenViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 9/2/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoaderController.sharedInstance.showLoader(indicatorText: "", holdingView: self.view)
        User.initialize( completion: {
            LoaderController.sharedInstance.removeLoader();
            
            //this also needs to be moved into its own asynchronous load
            DataManager.generateTestData()
            
            if(User.sharedInstance!.isAdmin)
            {
                self.takeMeToAdminPage()
            }
            else if(User.userJustCreated)
            {
                self.takeUserToInitialWalkThrough()
            }
            else
            {
                self.takeMeHome()
            }
        })
        // Do any additional setup after loading the view.
    }

    func takeMeToAdminPage()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Delivery")
        self.present(vc!, animated: false, completion: nil)
    }
    
    func takeMeHome()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: false, completion: nil)
    }
    
    func takeUserToInitialWalkThrough()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Notifications")
        self.present(vc!, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
