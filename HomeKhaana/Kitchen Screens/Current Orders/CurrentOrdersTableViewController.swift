//
//  CurrentOrdersTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 9/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseDatabase


class CurrentOrdersTableViewController: UITableViewController, CurrentOrderActionsDelegate {
    
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentOrders == nil || currentOrders!.count == 0)
        {
            return 1
        }
        else
        {
            return currentOrders!.count
        }
    }
    
    func listenToOrders()
    {
        let currentOrdersQuery = db.child("CurrentOrders/\(User.sharedInstance!.id)") 
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
        if(self.currentOrders != nil && self.currentOrders!.count > 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "order", for: indexPath) as! CurrentOrdersTableViewCell
            cell.delegate = self
            cell.order = self.currentOrders![indexPath.row]
            cell.indexPath = indexPath
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noOrder", for: indexPath)
            return cell
        }
    }

    // Delegates
    func btnCartLinkClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        var cartContents:String = ""
        //generate cart text
        let inCart:[Choice] = order.cart
        
        var choice:Choice
        for choice in inCart
        {
            if(cartContents != "") {
                cartContents = cartContents + ", "
            }
            cartContents = cartContents + " \(choice.displayTitle)(\(choice.quantity!))"
        }
        
        
        let alertController = UIAlertController(title: "Cart Contents",
                                                message: cartContents,
                                                preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func markAsReadyforPickupClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        let alertController = UIAlertController(title: "Confirmation",
                                                message: "This will mark the order as ready for pick-up. Are you sure?",
                                                preferredStyle: .alert)
        var alertAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            order.status = "Ready for Pick-Up"
            LoaderController.sharedInstance.showLoader(indicatorText: "Marking as Ready for Pick-Up", holdingView: self.view)
            let kitchenId=User.sharedInstance!.id
            db.child("CurrentOrders/\(kitchenId)/\(order.orderingUserID)/\(order.id)/\("status")").setValue("Ready for Pick-Up")
            {
                (error:Error?, ref:DatabaseReference) in
                if error == nil {
                    
                    /*db.child("Orders/\(order.orderingUserID)/\(order.id)/\("status")").setValue("Ready for Pick-Up"){
                        (error:Error?, ref:DatabaseReference) in
                        if error != nil {
                            LoaderController.sharedInstance.updateTitle(title: "Failed. Try again")
                        } else {
                            LoaderController.sharedInstance.updateTitle(title: "Complete!")
                        }
                        LoaderController.sharedInstance.removeLoader()
                        self.tableView.reloadData()
                    }*/
                    LoaderController.sharedInstance.removeLoader()
                    self.tableView.reloadData()
                } else {
                    LoaderController.sharedInstance.updateTitle(title: "Failed. Try again")
                    LoaderController.sharedInstance.removeLoader()
                }
            }
        })
        
        alertController.addAction(alertAction)
        alertAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    
    func markAsCompletedClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        let alertController = UIAlertController(title: "Confirmation",
                                                message: "This will mark the order as completed. Are you sure?",
                                                preferredStyle: .alert)
        var alertAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            
            order.status = "Completed"
            LoaderController.sharedInstance.showLoader(indicatorText: "Marking as Completed", holdingView: self.view)
            let kitchenId=User.sharedInstance!.id
            db.child("CurrentOrders/\(kitchenId)/\(order.orderingUserID)/\(order.id)").setValue(nil)
            {
                (error:Error?, ref:DatabaseReference) in
                if error == nil {
                    /*db.child("Orders/\(order.orderingUserID)/\(order.id)/status").setValue("Completed"){
                        (error:Error?, ref:DatabaseReference) in
                        if error != nil {
                            LoaderController.sharedInstance.updateTitle(title: "Failed. Try again")
                        } else {
                            LoaderController.sharedInstance.updateTitle(title: "Complete!")
                        }
                        LoaderController.sharedInstance.removeLoader()
                        self.tableView.reloadData()
                    }*/
                    LoaderController.sharedInstance.removeLoader()
                    self.tableView.reloadData()
                } else {
                    LoaderController.sharedInstance.updateTitle(title: "Failed. Try again")
                    LoaderController.sharedInstance.removeLoader()
                }
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
