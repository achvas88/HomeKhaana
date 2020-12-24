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
                if(User.sharedInstance!.isKitchen)
                {
                    let kitchen:Kitchen? = DataManager.kitchens[User.sharedInstance!.id]
                    if(kitchen != nil)
                    {
                        self.takeMeToKitchenHome()
                    }
                    else
                    {
                        self.takeMeToKitchenInitialization()
                    }
                }
                else if(User.userJustCreated)
                {
                    self.takeUserToInitialWalkThrough()
                }
                else
                {
                    self.takeMeToUserHome()
                }
            })
        })
    }

    func takeMeToKitchenInitialization()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "KitchenInitialization")
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: false, completion: nil)
    }
    
    func takeMeToKitchenHome()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "KitchenHome")
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: false, completion: nil)
    }
    
    func takeMeToUserHome()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserHome")
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: false, completion: nil)
    }
    
    func takeUserToInitialWalkThrough()
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Notifications")
        vc!.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
