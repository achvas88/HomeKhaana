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
    var userBeingRated: User?
    var orderForChat:Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listenToOrders()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                        if let snapshot:DataSnapshot = orderChild as? DataSnapshot,
                           let id = (snapshot.value as AnyObject)["id"] as? String?,
                           id != nil,
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
    
    func lblInstructionsClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        let alertController = UIAlertController(title: "Instructions",
                                                message: order.customInstructions ?? "None",
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
                    LoaderController.sharedInstance.removeLoader()
                    
                    //rate the user segue
                    self.rateUser(order: order)
                    
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

    private func rateUser(order: Order)
    {
        User.loadUserFromServer(userID: order.orderingUserID, completion: { (user) in
            if(user != nil)
            {
                self.userBeingRated = user
                self.performSegue(withIdentifier: "rateUser", sender: self)
            }
        })
    }
    
    func btnChatClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        self.orderForChat = order
        self.performSegue(withIdentifier: "chatKitchen", sender: self)
    }
    
    func btnConfirmOrderClicked(at index: IndexPath) {
        let order:Order = self.currentOrders![index.row]
        
        let alert = UIAlertController(title: "Order Confirmation", message: "When can the order be picked up? (Do not give relative times like \"One hour from now\". Give actual times)", preferredStyle: .alert)
        
        //Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Save button
        let saveAction = UIAlertAction(title:"Confirm", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
            
            order.status = "Confirmed"
            order.pickupTime = (alert.textFields![0] as UITextField).text!
            LoaderController.sharedInstance.showLoader(indicatorText: "Confirming order", holdingView: self.view)
            let kitchenId=User.sharedInstance!.id
            
            let orderConfirmation = ["status": "Confirmed",
                                     "pickupTime": order.pickupTime!]
            db.child("/CurrentOrders/\(kitchenId)/\(order.orderingUserID)/\(order.id)").updateChildValues(orderConfirmation) {
                (error:Error?, ref:DatabaseReference) in
                if error == nil {
                    LoaderController.sharedInstance.removeLoader()
                    self.tableView.reloadData()
                } else {
                    LoaderController.sharedInstance.updateTitle(title: "Failed. Try again")
                    LoaderController.sharedInstance.removeLoader()
                }
            }
        })
        alert.addAction(saveAction)
        
        //text box for getting time
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = "9 - 10 AM (or) ASAP"
            saveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = textField.text!.count > 0
            }
        })
        
        //present the alert
        self.present(alert, animated: true)

    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "rateUser")
        {
            let ratingVC: RatingViewController? = segue.destination as? RatingViewController
            
            if(ratingVC != nil && self.userBeingRated != nil)
            {
                ratingVC!.currentUser = self.userBeingRated
            }
        }
        else if (segue.identifier == "chatKitchen")
        {
            let destinationNavigationController = segue.destination as! UINavigationController
            let chatVC: ChatViewController? = destinationNavigationController.topViewController as? ChatViewController
            
            if(chatVC != nil && self.orderForChat != nil)
            {
                chatVC!.currentOrder = self.orderForChat
            }
        }
    }
}
