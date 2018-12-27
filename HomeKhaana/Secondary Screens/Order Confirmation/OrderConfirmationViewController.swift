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
        LoaderController.sharedInstance.showLoader(indicatorText: "Payment Processing", holdingView: self.view)
        
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
            newChargeRef.setValue(theCharge) {
                (error:Error?, ref:DatabaseReference) in
                if error != nil {
                    LoaderController.sharedInstance.updateTitle(title: "Error Processing Payment")
                } else {
                    LoaderController.sharedInstance.updateTitle(title: "Charging Initiated")
                }
            }
            
            //listen to payment posting updates
            listenToPaymentPostingUpdates(uid: id, chargeID: chargeID)
        }
    }

    func listenToPaymentPostingUpdates(uid: String, chargeID: String)
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
