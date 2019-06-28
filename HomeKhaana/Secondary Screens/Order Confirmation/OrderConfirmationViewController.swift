//
//  OrderConfirmationViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/18/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseDatabase

class OrderConfirmationViewController: UIViewController {

    var order:Order?    //order that is currently being processed
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        processPayment()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func processPayment()
    {
        LoaderController.sharedInstance.showLoader(indicatorText: "Placing order", holdingView: self.view)
        
        //post payment
        if (User.isUserInitialized)
        {
            let id = User.sharedInstance!.id
            let chargeID = UUID().uuidString
            self.order!.id = chargeID
            self.order!.populateDates()
            
            let newChargeRef = Database.database().reference().child("Orders/\(id)").child(chargeID)
            
            //create the charge dcitionary that will be filed.
            let theCharge:Dictionary<String,Any>=self.order!.dictionary
            
            //file a charge
            newChargeRef.setValue(theCharge)
            {
                (error:Error?, ref:DatabaseReference) in
                if error != nil
                {
                    LoaderController.sharedInstance.updateTitle(title: "Error placing order. Please try again later.")
                    let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.waitBeforeDismissing(timer:)), userInfo: ["passFail": 0], repeats: false)
                    timer.tolerance = 0.2
                }
                else
                {
                    LoaderController.sharedInstance.updateTitle(title: "Success!")
                    Cart.sharedInstance.cart.removeAll()
                    self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = nil
                    let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.waitBeforeDismissing(timer:)), userInfo: ["passFail": 1], repeats: false)
                    timer.tolerance = 0.2
                }
            }
            
            //listen to payment posting updates
            //listenToPaymentPostingUpdates(uid: id, chargeID: chargeID)
        }
    }
    
    @objc func waitBeforeDismissing(timer: Timer)
    {
        if  let userInfo = timer.userInfo as? [String: Int],
            let passFail = userInfo["passFail"]
        {
            LoaderController.sharedInstance.removeLoader()
            if(passFail == 0)
            {
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.performSegue(withIdentifier: "returnAfterConfirmation", sender: self)
            }
        }
    }

    /*func listenToPaymentPostingUpdates(uid: String, chargeID: String)
    {
        let paymentSourcesRef = db.child("Orders/\(uid)/\(chargeID)/stripeResponse")
        paymentSourcesRef.observe(.value, with: { (snapshot) in
            LoaderController.sharedInstance.updateTitle(title: "Charging Response Received")
            let response = self.order!.processResponse(snapshot: snapshot)
            if(response == "succeeded")
            {
                LoaderController.sharedInstance.updateTitle(title: "Success!")
                LoaderController.sharedInstance.removeLoader()
                Cart.sharedInstance.cart.removeAll()
                self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = nil
                // we should actually go to the upcoming orders screen now. for now, we are simply dismissing the controller.
                self.performSegue(withIdentifier: "returnAfterConfirmation", sender: self)
            }
            else if(response != "")
            {
                LoaderController.sharedInstance.updateTitle(title: response)
                LoaderController.sharedInstance.removeLoader()
                
                //payment processing failed. Tell the user.
                let alertController = UIAlertController(title: "Payment Processing Failed",
                                                        message: "We are sorry. Please try again",
                                                        preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
                
                //dismiss this screen
                self.dismiss(animated: true, completion: nil)
            }
        })
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
