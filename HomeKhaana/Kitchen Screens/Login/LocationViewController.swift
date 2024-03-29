//
//  LocationViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 3/16/19.
//  Copyright © 2019 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationViewController: UIViewController {

    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var updateAddressDelegate:UpdateAddressDelegate? = nil
    public var currentLatitude: Double?
    public var currentLongitude: Double?

    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup search controller delegate
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // setup search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = resultSearchController?.searchBar
        
        // configure appearance of search controller
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        if(currentLatitude != nil && currentLongitude != nil)
        {
            LoaderController.sharedInstance.showLoader(indicatorText: "Loading your location", holdingView: self.view)
            lookupLocationAndDropPin(location: CLLocation(latitude: currentLatitude!, longitude: currentLongitude!))
        }
        else
        {
            self.enableDisableButtons()
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptClicked(_ sender: Any) {
        self.updateAddressDelegate?.updateAddress(latitude: self.selectedPin!.coordinate.latitude, longitude: self.selectedPin!.coordinate.longitude, title: parseAddress(selectedItem: self.selectedPin!))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentLocationClicked(_ sender: Any) {
        // setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.requestLocation()
        }
        else
        {
            self.showLocationDisabledPopUp()
        }
        LoaderController.sharedInstance.showLoader(indicatorText: "Getting current location", holdingView: self.view)
    }
    
    func enableDisableButtons()
    {
        if(selectedPin == nil)
        {
            self.btnAccept.isEnabled = false
        }
        else
        {
            self.btnAccept.isEnabled = true
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        
        LoaderController.sharedInstance.removeLoader()
        
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "We need your location to proceed further",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            LoaderController.sharedInstance.showLoader(indicatorText: "Getting current location", holdingView: self.view)
        }
        else if status == .denied || status == .restricted || status == .notDetermined {
            showLocationDisabledPopUp()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            lookupLocationAndDropPin(location: self.locationManager.location)
        }
    }
    
    func lookupLocationAndDropPin(location: CLLocation?)
    {
        lookUpLocation(location: location, completionHandler: {(placeMark) in
            LoaderController.sharedInstance.removeLoader()
            if(placeMark != nil)
            {
                self.dropPinZoomIn(placemark: MKPlacemark(placemark: placeMark!))
            }
            else
            {
                self.showError(message: "Error occurred while identifying location. Please try again later. ")
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showLocationDisabledPopUp()
    }
    
    func lookUpLocation(location:CLLocation? ,completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        if let location = location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    func showError(message: String, title: String = "Error")
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension LocationViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark)
    {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = parseAddress(selectedItem: placemark)
        annotation.subtitle = placemark.title
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        self.enableDisableButtons()
    }
}
