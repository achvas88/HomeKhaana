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

    @IBOutlet weak var stkPaymentProcessing: UIStackView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var indActivityIndicator: UIActivityIndicatorView!
    
    var order:Order?    //order that is currently being processed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        processPayment()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func processPayment()
    {
        self.indActivityIndicator.startAnimating()
        
        //post payment
        if (User.isUserInitialized)
        {
            let id = User.sharedInstance!.id
            let chargeID=User.sharedInstance!.chargeID
            
            let newChargeRef = Database.database().reference().child("Orders/\(id)").child(String(chargeID))
            let theCharge:Dictionary<String,Any>=self.order!.dictionary
            
            newChargeRef.setValue(theCharge) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Error charging user: \(error).")
                } else {
                    print("Charging initiated successfully!")
                }
            }
            
            //listen to payment posting updates
            listenToPaymentPostingUpdates(uid: id, chargeID: String(chargeID))
            
            //update the chargeID (idempotency key for Stripe)
            User.sharedInstance!.chargeID = User.sharedInstance!.chargeID + 1
        }
    }

    func listenToPaymentPostingUpdates(uid: String, chargeID: String)
    {
        let paymentSourcesRef = db.child("Orders/\(uid)/\(chargeID)/stripeResponse")
        paymentSourcesRef.observe(.value, with: { (snapshot) in
            self.indActivityIndicator.stopAnimating()
            let response = self.order!.processResponse(snapshot: snapshot)
            if(response == "succeeded")
            {
                self.lblStatus.text = "Success!"
                // we should actually go to the upcoming orders screen now. for now, we are simply dismissing the controller.
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.lblStatus.text = response
            }
        })
    }
    /*
     
     let alertController = UIAlertController(title: "Success",
     message: "Charging complete!",
     preferredStyle: .alert)
     let alertAction = UIAlertAction(title: "Cool", style: .default)
     alertController.addAction(alertAction)
     self.present(alertController, animated: true)
     return
     
     
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
