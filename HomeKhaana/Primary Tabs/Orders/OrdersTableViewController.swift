//
//  OrdersTableViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 8/19/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import FirebaseDatabase

class OrdersTableViewController: UITableViewController {

    var mostRecentOrders:[Order]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.listenToOrders()
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
        if(mostRecentOrders == nil)
        {
            return 1
        }
        if(mostRecentOrders!.count == 0)
        {
            return 1
        }
        return mostRecentOrders!.count
    }

    func listenToOrders()
    {
        let mostRecentOrdersQuery = db.child("Orders/\(User.sharedInstance!.id)").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        
        mostRecentOrdersQuery.observe(.value, with: { (snapshot) in
            self.mostRecentOrders = []
            for orderChild in snapshot.children {
                if let snapshot = orderChild as? DataSnapshot,
                    let order:Order? = Order(snapshot: snapshot)
                {
                    if(order != nil)
                    {
                        self.mostRecentOrders!.insert(order!, at: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(self.mostRecentOrders != nil && self.mostRecentOrders!.count>0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "order", for: indexPath) as! OrdersTableViewCell
            cell.order = self.mostRecentOrders![indexPath.row]
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyOrder", for: indexPath) as! EmptyOrderTableViewCell
            cell.mainText!.text = "No orders yet"
            cell.subText!.text = "¯\\_(ツ)_/¯"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(self.mostRecentOrders != nil && self.mostRecentOrders!.count>0)
        {
            let order:Order = self.mostRecentOrders![indexPath.row]
            if(order.status != "Ordered" && order.status != "Ready for Pick-Up")
            {
                return 343 - 120; // here 120 is the height of the image.
            }
            else
            {
                return 343 - 120; // we are hiding images for now. So, always reduce by 120.
            }
        }
        else
        {
            return self.view.frame.height - 100; // 100 is for the tab at the bottom
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "showCart")
        {
            let cartViewVC: CartViewController? = segue.destination as? CartViewController
            let currentRow: OrdersTableViewCell? = sender as! OrdersTableViewCell?
            
            if(cartViewVC != nil && currentRow != nil)
            {
                cartViewVC!.currentOrder = currentRow!.order
            }
        }
    }
}
