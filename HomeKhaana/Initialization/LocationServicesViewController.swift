//
//  LocationServicesViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 3/20/19.
//  Copyright © 2019 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import MapKit

class LocationServicesViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        getLocation()
    }
    
    func getLocation()
    {
        LoaderController.sharedInstance.showLoader(indicatorText: "Getting Location", holdingView: self.view)
        locationManager.requestLocation()
    }
    
    func moveOn()
    {
        LoaderController.sharedInstance.removeLoader()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "howItWorks")
        self.present(vc!, animated: false, completion: nil)
    }

    @IBAction func nextClicked(_ sender: Any) {
        getLocation()
    }
    
    func showLocationDisabledPopUp() {
        
        LoaderController.sharedInstance.removeLoader()
        
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "We need your location to proceed further",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler:
                    nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension LocationServicesViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            LoaderController.sharedInstance.showLoader(indicatorText: "", holdingView: self.view)
        }
        else if status == .denied || status == .restricted  {
            showLocationDisabledPopUp()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            User.sharedInstance!.latitude = location.coordinate.latitude
            User.sharedInstance!.longitude = location.coordinate.longitude
            moveOn()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        showLocationDisabledPopUp()
    }
}
