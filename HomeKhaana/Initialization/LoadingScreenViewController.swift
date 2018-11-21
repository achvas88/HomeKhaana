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
        
        //first load the user data
        User.initialize( completion: {
            //then load miscellaneous non-user data
            DataManager.initData(completion: {
                LoaderController.sharedInstance.removeLoader();
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
        })
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
