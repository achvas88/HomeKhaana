//
//  CartViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/1/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import Stripe
import Firebase
import FirebaseDatabase

class CartViewController: UIViewController, UITableViewDataSource,PaymentSourceDelegate,AddressDelegate {
    
    @IBOutlet weak var btnAddAddress: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblConvenienceFee: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var btnAddPayment: CustomUIButton!
    @IBOutlet weak var btnCheckout: UIButton!
    @IBOutlet weak var tblItems: UITableView!
    @IBOutlet weak var cnstTblItems: NSLayoutConstraint!
    @IBOutlet weak var scrScrollArea: UIScrollView!
    @IBOutlet weak var stkEmptyCart: UIStackView!
    @IBOutlet weak var cnstAddPaymentHeight: NSLayoutConstraint!
    @IBOutlet weak var cnstCheckoutHeight: NSLayoutConstraint!
    
    var inCart:Array<(key:String, value:Int)> = []
    var currentOrder:Order?
    var navigateToOrdersScreen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if(self.currentOrder == nil)
        {
            self.currentOrder = Order(id:User.sharedInstance!.chargeID)
            self.currentOrder!.selectedPayment = self.currentOrder!.selectedPayment ?? User.sharedInstance!.defaultPaymentSource
            self.currentOrder!.selectedAddress = DataManager.getAddressForTitle(title: User.sharedInstance!.defaultAddress)
        }
        else
        {
            self.lblTime.text = self.currentOrder!.deliveryDate
        }
        
        self.tblItems.dataSource = self
        self.setupButtons()
        self.updateDisplay(initialize: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func ensurePaymentSourceValidity()
    {
        if(self.currentOrder!.status != "New")
        {
            return
        }
        
        if(User.sharedInstance!.paymentSources == nil)
        {
            clearOffSelectedPaymentSource()
            return
        }
        if (self.currentOrder!.selectedPayment != nil)
        {
            var isValidCard:Bool = false
            for card in User.sharedInstance!.paymentSources!
            {
                if(self.currentOrder!.selectedPayment!.id == card.id)
                {
                    isValidCard = true
                }
            }
            if(isValidCard)
            {
                self.btnAddPayment.setTitle("**** " + self.currentOrder!.selectedPayment!.cardNumber, for: .normal)
                self.btnAddPayment.setImage(self.currentOrder!.selectedPayment!.cardImage, for: .normal)
            }
            else
            {
                clearOffSelectedPaymentSource()
            }
        }
    }
    
    func clearOffSelectedPaymentSource()
    {
        self.currentOrder!.selectedPayment = nil
        self.btnAddPayment.setTitle("Add Payment", for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cnstTblItems.constant = self.tblItems.contentSize.height - 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if the payment processing has failed, then we need to update the order's ID with the updated charge ID.
        self.currentOrder?.id = User.sharedInstance!.chargeID
        
        //update display
        self.updateDisplay(initialize: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDisplay(initialize:Bool)
    {
        if(self.navigateToOrdersScreen == true)
        {
            self.navigateToOrdersScreen = false
            self.navigationController?.tabBarController?.selectedIndex = 2
        }
        
        if(self.currentOrder!.status == "New")
        {
            self.inCart = Array(DataManager.inCart)
        }
        else
        {
            self.inCart = Array(self.currentOrder!.cart)
        }
        
        if(self.inCart.count == 0)
        {
            self.btnCheckout.isHidden = true
            self.scrScrollArea.isHidden = true
            self.btnAddPayment.isHidden = true
            self.stkEmptyCart.isHidden = false
        }
        else
        {
            self.scrScrollArea.isHidden = false
            self.btnCheckout.isHidden = false
            if(self.currentOrder!.status == "New")
            {
                
                self.btnAddPayment.isHidden = false
            }
            else
            {
                self.btnAddPayment.isHidden = true
                self.cnstAddPaymentHeight.constant = 0
            }
            self.stkEmptyCart.isHidden = true
            if(!initialize)
            {
                self.tblItems.reloadData()
            }
            self.calculatePrice()
        }
        
        //set the height of the table view
        self.cnstTblItems.constant = self.tblItems.contentSize.height - 5
        
        //update badge
        if(self.currentOrder!.status == "New")
        {
            if(DataManager.inCart.count == 0) {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = nil}
            else {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = String(DataManager.inCart.count)}
        
            //ensure payment source is still valid.
            ensurePaymentSourceValidity()
        }
        
        if(self.currentOrder!.selectedAddress != nil)
        {
            self.btnAddAddress.setTitle(self.currentOrder!.selectedAddress!.title, for: .normal)
        }
    }
    
    func calculatePrice()
    {
        if(self.currentOrder!.status == "New")
        {
            var subTotal:Float = 0
            for (id, quantity) in DataManager.inCart {
                let choice = DataManager.getChoiceForId(id: Int(id)!)
                subTotal = subTotal + (choice.cost * Float(quantity))
            }
        
            //setup order object
            self.currentOrder!.cart = DataManager.inCart
            self.currentOrder!.subTotal = limitToTwoDecimal(input: subTotal)
            self.currentOrder!.tax = limitToTwoDecimal(input: (self.currentOrder!.subTotal*0.05))
            self.currentOrder!.convenienceFee = limitToTwoDecimal(input:2)
            self.currentOrder!.orderTotal = limitToTwoDecimal(input:(self.currentOrder!.subTotal+(self.currentOrder!.subTotal*0.05)+2))
        }
        
        //update labels
        self.lblSubtotal.text = "$\(convertToCurrency(input: self.currentOrder!.subTotal))"
        self.lblTax.text = "$\(convertToCurrency(input: self.currentOrder!.tax))"
        self.lblConvenienceFee.text = "$\(convertToCurrency(input: self.currentOrder!.convenienceFee))"
        self.lblTotal.text = "$\(convertToCurrency(input: self.currentOrder!.orderTotal))"
        
        if(self.currentOrder!.status == "New")
        {
            //update checkout button title
            self.btnCheckout.setTitle("CHECKOUT - \(self.lblTotal.text!)", for: .normal)
        }
    }
    
    func setupButtons()
    {
        
        self.btnCheckout.backgroundColor = UIColor(red: 69/255, green: 191/255, blue: 34/255, alpha: 1.0)
        self.btnCheckout.setTitleColor(UIColor.white, for: .normal)
        
        self.tblItems.layer.borderWidth = 0.5
        let borderColor : UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        self.tblItems.layer.borderColor = borderColor.cgColor
        self.tblItems.layer.cornerRadius = 3
        
        if(self.currentOrder!.status != "New")
        {
            self.btnAddAddress.setTitleColor(UIColor.black, for: .disabled)
            self.btnCheckout.isHidden = false
            self.btnCheckout.setTitle("Okay", for: .normal)
            self.btnAddPayment.isHidden = true
            self.btnAddAddress.isEnabled = false
        }
    }
    
    // Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inCart.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CartTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        
        // Configure the cell...
        cell.setupCell(id: self.inCart[indexPath.row].key, quantity: self.inCart[indexPath.row].value)
        
        return cell
    }
    
    @IBAction func btnCheckoutClicked(_ sender: Any) {
        if(self.currentOrder!.status != "New")
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        if (identifier == "checkout")
        {
            guard self.currentOrder!.status == "New" else {
                return false
            }
            
            guard self.currentOrder!.selectedAddress != nil else {
                //make sure that there is a payment source selected
                let alertController = UIAlertController(title: "No Address Specified",
                                                        message: "Please choose a valid delivery address to continue",
                                                        preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(alertAction)
                present(alertController, animated: true)
                return false
            }
            
            guard self.currentOrder!.cart.count > 0 else {
                //sanity check. This will never happen as the empty cart will start showing.
                let alertController = UIAlertController(title: "Empty Cart",
                                                        message: "Your cart is empty",
                                                        preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(alertAction)
                present(alertController, animated: true)
                return false
            }
            
            guard self.currentOrder!.selectedPayment != nil else {
                //make sure that there is a payment source selected
                let alertController = UIAlertController(title: "No Payment Source Specified",
                                                        message: "Please add a valid payment source to continue",
                                                        preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(alertAction)
                present(alertController, animated: true)
                return false
            }
            
            return true
        }
        else if(identifier == "cartChoiceDetail")
        {
            if(self.currentOrder!.status != "New")
            {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func btnPayments(_ sender: Any) {
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentSources")
        //navigationController?.pushViewController(vc!, animated: true)
        //self.present(vc!, animated: true, completion: nil)
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "cartChoiceDetail")
        {
            let detailsVC: ChoiceDetailViewController? = segue.destination as? ChoiceDetailViewController
            let currentRow: CartTableViewCell? = sender as! CartTableViewCell?
            
            if(detailsVC != nil && currentRow != nil)
            {
                detailsVC!.theChoice = currentRow!.choice
            }
        }
        else if(segue.identifier == "choosePayment")
        {
            let paymentsVC: PaymentSourceTableViewController? = segue.destination as? PaymentSourceTableViewController
            paymentsVC?.mgmtMode = false
            paymentsVC?.selectedPayment = self.currentOrder!.selectedPayment ?? User.sharedInstance!.defaultPaymentSource
            paymentsVC?.paymentSourceDelegate = self
        }
        else if(segue.identifier == "chooseAddress")
        {
            let addressesVC: AddressesTableViewController? = segue.destination as? AddressesTableViewController
            addressesVC?.addressDelegate = self
        }
        else if (segue.identifier == "checkout")
        {
            let orderConfirmationVC: OrderConfirmationViewController? = segue.destination as? OrderConfirmationViewController
            orderConfirmationVC?.order = self.currentOrder
        }
    }
    
    func updateAddress(_ address: Address?) {
         self.currentOrder!.selectedAddress = address
    }
    
    func updatePaymentSource(_ paymentSource: PaymentSource?) {
        self.currentOrder!.selectedPayment = paymentSource
    }
    
    @IBAction func backFromModal(_ segue: UIStoryboardSegue) {
        //self.navigationController?.tabBarController?.selectedViewController =  self.storyboard?.instantiateViewController(withIdentifier: "Orders")
        self.navigateToOrdersScreen = true
    }
}
