//
//  Shared.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 7/3/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseFunctions
import MapKit

let db: DatabaseReference! = Database.database().reference()
var functions = Functions.functions()
enum Constants
{
    static let publishableKey = "pk_test_E7O4iRuxgXcMDjnMPNJvVtXX"
}


func convertToCurrency(input:Float)->String
{
    //return round(input*1000)/1000 - can be used in the future to actually store float value
    return String(format: "%.2f", input)
}

func limitToTwoDecimal(input:Double)->Double
{
    //return ((input*100).rounded()/100)
    return Double(String(format: "%.2f", input))!
}

protocol RefreshTableViewWhenImgLoadsDelegate: class
{
    func reloadTableView()
}

// parses the address
func parseAddress(selectedItem:MKPlacemark) -> String {
    // put a space between "4" and "Melrose Place"
    let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // put a comma between street and city/state
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    // put a space between "Washington" and "DC"
    let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
        format:"%@%@%@%@%@%@%@",
        // street number
        selectedItem.subThoroughfare ?? "",
        firstSpace,
        // street name
        selectedItem.thoroughfare ?? "",
        comma,
        // city
        selectedItem.locality ?? "",
        secondSpace,
        // state
        selectedItem.administrativeArea ?? ""
    )
    return addressLine
}


func showError(vc: UIViewController, message: String, title: String = "Error")
{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(defaultAction)
    vc.present(alertController, animated: true, completion: nil)
}
