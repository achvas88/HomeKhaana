//
//  DeliveryTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 9/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DeliveryTableViewController: UITableViewController, MarkAsDeliveredDelegate {
    
    var currentOrders:[Order]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listenToOrders()
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
        // #warning Incomplete implementation, return the number of rows
        return currentOrders?.count ?? 0
    }
    
    func listenToOrders()
    {
        let currentOrdersQuery = db.child("CurrentOrders")
        currentOrdersQuery.removeAllObservers()
        currentOrdersQuery.observe(.value, with: { (snapshot) in
            self.currentOrders = []
            for user in snapshot.children {
                if let snapshot = user as? DataSnapshot
                {
                    for orderChild in snapshot.children {
                        if let snapshot = orderChild as? DataSnapshot,
                           let order:Order? = Order(snapshot: snapshot)
                        {
                            if(order != nil)
                            {
                                self.currentOrders!.insert(order!, at: 0)
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "delivery", for: indexPath) as! DeliveryTableViewCell
        cell.delegate = self
        cell.order = self.currentOrders![indexPath.row]
        cell.indexPath = indexPath
        return cell
    }

    // Delegates
    func btnCartLinkClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        var cartContents:String = ""
        //generate cart text
        let inCart:Array<(key:String, value:Int)> = Array(order.cart)
        
        var choice:Choice
        for (orderItem, orderQuantity) in inCart
        {
            choice = DataManager.getChoiceForId(id: Int(orderItem)!)
            if(cartContents != "") {
                cartContents = cartContents + ", "
            }
            cartContents = cartContents + " \(choice.displayTitle)(\(orderQuantity))"
        }
        
        
        let alertController = UIAlertController(title: "Cart Contents",
                                                message: cartContents,
                                                preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func markAsDeliveredClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        let alertController = UIAlertController(title: "Confirmation",
                                                message: "This will mark the order as delivered. Are you sure?",
                                                preferredStyle: .alert)
        var alertAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            order.status = "Delivered"
            LoaderController.sharedInstance.showLoader(indicatorText: "Marking as Delivered", holdingView: self.view)
            let userId=User.sharedInstance!.id
            db.child("CurrentOrders/\(userId)/\(order.id)").setValue(nil)
            {
                (error:Error?, ref:DatabaseReference) in
                if error != nil {
                } else {
                }
            }
            db.child("Orders/\(userId)/\(order.id)/status").setValue("Delivered"){
                (error:Error?, ref:DatabaseReference) in
                if error != nil {
                    LoaderController.sharedInstance.updateTitle(title: "Failed. Try again")
                } else {
                    LoaderController.sharedInstance.updateTitle(title: "Complete!")
                }
                LoaderController.sharedInstance.removeLoader()
                self.tableView.reloadData()
            }
        })
        
        alertController.addAction(alertAction)
        alertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
        
    }
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
