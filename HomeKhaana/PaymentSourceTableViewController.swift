//
//  PaymentSourceTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/16/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import FirebaseDatabase


class PaymentSourceTableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize payment sources
        let uid = User.sharedInstance!.id
        
        let paymentSourcesRef = db.child("PaymentSources/\(uid)")
        paymentSourcesRef.observe(.value, with: { (snapshot) in
            
            User.sharedInstance?.paymentSources = []
            
            for card in snapshot.children {
                if let snapshot = card as? DataSnapshot,
                   let paymentSource = PaymentSource(snapshot: snapshot)
                {
                    User.sharedInstance?.paymentSources.append(paymentSource)
                }
            }
            self.tableView.reloadData()
        })
        
        self.tableView.separatorStyle = .none

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.sharedInstance!.paymentSources.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row != User.sharedInstance!.paymentSources.count)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentSource", for: indexPath) as! PaymentSourceTableViewCell
            let card:PaymentSource = User.sharedInstance!.paymentSources[indexPath.row]
            cell.lblCardNumber.text = "**** " + String(card.cardNumber)
            cell.imgCardBrand.image = card.cardImage
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addPayment", for: indexPath) as! AddPaymentTableViewCell
            return cell
        }
    }
    
    @IBAction func btnAddPaymentClicked(_ sender: Any) {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        navigationController?.pushViewController(addCardViewController, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//Credit Card Processing
extension PaymentSourceTableViewController: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController,
                               didCreateToken token: STPToken,
                               completion: @escaping STPErrorBlock) {
        
        if (User.isUserInitialized)
        {
            let id = User.sharedInstance!.id
            
            Database.database().reference().child("PaymentSources/\(id)").child(token.tokenId).setValue(token.card!.last4){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Error uploading user data: \(error).")
                    completion(error)
                } else {
                    print("Added Payment!")
                    completion(nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
