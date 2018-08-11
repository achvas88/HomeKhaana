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
    
    var inCart:Array<(key:Int, value:Int)> = []
    var currentTotal:Int = 0
    var selectedPayment:PaymentSource?
    var selectedAddress:Address?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.selectedPayment = self.selectedPayment ?? User.sharedInstance!.defaultPaymentSource
        self.selectedAddress = DataManager.getAddressForTitle(title: User.sharedInstance!.defaultAddress)
        
        self.tblItems.dataSource = self
        self.setupButtons()
        self.updateDisplay(initialize: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cnstTblItems.constant = self.tblItems.contentSize.height - 5
        
        //update badge
        if(DataManager.inCart.count == 0) {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = nil}
        else {self.navigationController?.tabBarController?.tabBar.items?[1].badgeValue = String(DataManager.inCart.count)}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cnstTblItems.constant = self.tblItems.contentSize.height - 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateDisplay(initialize: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDisplay(initialize:Bool)
    {
        self.inCart = Array(DataManager.inCart)
        if(self.inCart.count == 0)
        {
            self.btnCheckout.isHidden = true
            self.scrScrollArea.isHidden = true
            self.btnAddPayment.isHidden = true
            self.stkEmptyCart.isHidden = false
        }
        else
        {
            self.btnCheckout.isHidden = false
            self.scrScrollArea.isHidden = false
            self.btnAddPayment.isHidden = false
            self.stkEmptyCart.isHidden = true
            if(!initialize)
            {
                self.tblItems.reloadData()
            }
            self.calculatePrice()
        }
        
        if (self.selectedPayment != nil)
        {
            self.btnAddPayment.setTitle("**** " + self.selectedPayment!.cardNumber, for: .normal)
            self.btnAddPayment.setImage(self.selectedPayment!.cardImage, for: .normal)
        }
        
        if(self.selectedAddress != nil )
        {
            self.btnAddAddress.setTitle(self.selectedAddress!.title, for: .normal)
        }
    }
    
    func calculatePrice()
    {
        var subTotal:Float = 0
        for (id, quantity) in DataManager.inCart {
            let choice = DataManager.getChoiceForId(id: id)
            subTotal = subTotal + (choice.cost * Float(quantity))
        }
        self.lblSubtotal.text = "$\(convertToCurrency(input:subTotal))"
        self.lblTax.text = "$\(convertToCurrency(input:(subTotal*0.05)))"
        self.lblConvenienceFee.text = "$\(convertToCurrency(input:2))"
        self.lblTotal.text = "$\(convertToCurrency(input:(subTotal+(subTotal*0.05)+2)))"
        self.currentTotal = Int(floor((subTotal+(subTotal*0.05)+2)*100))
        self.btnCheckout.setTitle("CHECKOUT - \(self.lblTotal.text!)", for: .normal)
    }
    
    func setupButtons()
    {
        self.btnCheckout.backgroundColor = UIColor(red: 69/255, green: 191/255, blue: 34/255, alpha: 1.0)
        self.btnCheckout.setTitleColor(UIColor.white, for: .normal)
        
        self.tblItems.layer.borderWidth = 0.5
        let borderColor : UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        self.tblItems.layer.borderColor = borderColor.cgColor
        self.tblItems.layer.cornerRadius = 3
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
        guard inCart.count > 0 else {
            //sanity check. This will never happen as the empty cart will start showing.
            let alertController = UIAlertController(title: "Warning",
                                                    message: "Your cart is empty",
                                                    preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            present(alertController, animated: true)
            return
        }
        
        if (User.isUserInitialized)
        {
            let id = User.sharedInstance!.id
            User.sharedInstance!.chargeID = User.sharedInstance!.chargeID + 1
            let chargeID=User.sharedInstance!.chargeID
            
            let newChargeRef = Database.database().reference().child("Charges/\(id)").child(String(chargeID))
            var theCharge:Dictionary<String,Any>=[:]
            theCharge["amount"]=self.currentTotal
            theCharge["source"]=self.selectedPayment!.id
            
             newChargeRef.setValue(theCharge) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Error charging user: \(error).")
                } else {
                    print("Successfuly charged user!")
                    let alertController = UIAlertController(title: "Success",
                                                            message: "Charging complete!",
                                                            preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Cool", style: .default)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                    return
                }
            }
        }
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
            paymentsVC?.selectedPayment = self.selectedPayment ?? User.sharedInstance!.defaultPaymentSource
            paymentsVC?.paymentSourceDelegate = self
        }
        else if(segue.identifier == "chooseAddress")
        {
            let addressesVC: AddressesTableViewController? = segue.destination as? AddressesTableViewController
            addressesVC?.addressDelegate = self
        }
    }
    
    func updateAddress(_ address: Address?) {
         self.selectedAddress = address
    }
    
    func updatePaymentSource(_ paymentSource: PaymentSource?) {
        self.selectedPayment = paymentSource
    }
}
