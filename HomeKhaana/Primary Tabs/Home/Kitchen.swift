//
//  Kitchen.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 11/13/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//


import Foundation
import FirebaseDatabase
import Firebase
import MapKit

class Kitchen
{
    var id: String
    var name: String
    var rating: Float
    var address: String
    var type: String
    var ratingCount: Int
    var hasImage: Bool
    var offersVegetarian: Bool
    var longitude: Double
    var latitude: Double
    var kitchenLocation: CLLocation
    var distanceFromLoggedInUser: String?
    var distanceInMiles: Double?
    var acceptsDebit: Bool?
    var acceptsCredit: Bool?
    
    var image: UIImage? {
        didSet {
            self.writeImagetoDB()
        }
    }
    var imageChanged: Bool
    weak var containingTableViewDelegate:RefreshTableViewWhenImgLoadsDelegate?
    
    var dictionary: [String: Any] {
        return [
            "address": self.address,
            "name": self.name,
            "offersVegetarian": self.offersVegetarian,
            "rating": self.rating,
            "hasImage": self.hasImage,
            "ratingCount": self.ratingCount,
            "type": self.type,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "acceptsCredit": self.acceptsCredit ?? false,
            "acceptsDebit": self.acceptsDebit ?? false
        ]
    }
    
    init(id:String, name:String, rating:Float, address: String, type: String, ratingCount: Int, hasImage: Bool, offersVegetarian: Bool, latitude: Double, longitude: Double, image: UIImage? = nil, acceptsDebit: Bool = false, acceptsCredit: Bool = false) {
        self.id = id
        self.name = name
        self.rating = rating
        self.address = address
        self.type = type
        self.ratingCount = ratingCount
        self.offersVegetarian = offersVegetarian
        self.hasImage = hasImage
        self.imageChanged = false
        self.latitude = latitude
        self.longitude = longitude
        self.kitchenLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        if(image != nil)
        {
            self.image = image
        }
        if(self.hasImage && self.image == nil)
        {
            self.loadImageFromDB()
        }
        self.acceptsDebit = acceptsDebit
        self.acceptsCredit = acceptsCredit
    }
    
    
    //convenience constructors
    public convenience init?(dictionary: NSDictionary, id: String)
    {
        guard let name = dictionary["name"] as? String,
            let rating = dictionary["rating"] as? Float,
            let address = dictionary["address"] as? String,
            let type = dictionary["type"] as? String,
            let ratingCount = dictionary["ratingCount"] as? Int,
            let offersVegetarian = dictionary["offersVegetarian"] as? Bool,
            let hasImage =  dictionary["hasImage"] as? Bool,
            let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double
            else { return nil }
        
        let acceptsDebit = dictionary["acceptsDebit"] as? Bool
        let acceptsCredit = dictionary["acceptsCredit"] as? Bool
        
        self.init(id: id, name:name, rating: rating, address: address, type: type, ratingCount: ratingCount, hasImage: hasImage, offersVegetarian: offersVegetarian, latitude: latitude, longitude: longitude, acceptsDebit: acceptsDebit ?? false, acceptsCredit: acceptsCredit ?? false)
    }
    
    public convenience init?(snapshot: DataSnapshot)
    {
        let id = snapshot.key as String
        let snapshot = snapshot.value as AnyObject
        
        let name = snapshot["name"] as! String
        let rating = snapshot["rating"] as! Float
        let address = snapshot["address"] as! String
        let type = snapshot["type"] as! String
        let ratingCount = snapshot["ratingCount"] as! Int
        let offersVegetarian = snapshot["offersVegetarian"] as! Bool
        let hasImage = snapshot["hasImage"] as! Bool
        let latitude = snapshot["latitude"] as! Double
        let longitude = snapshot["longitude"] as! Double
        let acceptsDebit = snapshot["acceptsDebit"] as? Bool
        let acceptsCredit = snapshot["acceptsCredit"] as? Bool
        
        self.init(id: id, name:name, rating: rating,address: address, type: type, ratingCount: ratingCount, hasImage: hasImage, offersVegetarian: offersVegetarian, latitude: latitude, longitude: longitude, acceptsDebit: acceptsDebit ?? false, acceptsCredit: acceptsCredit ?? false)
    }
    
    func loadImageFromDB()
    {
        let filePath = "\(id)/\("kitchenPhoto")"
        // Assuming a < 10MB file, though you can change that
        let storageRef = Storage.storage().reference()
        storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            self.image = UIImage(data: data!)
            self.containingTableViewDelegate?.reloadTableView()
        })
    }
    
    func writeImagetoDB()
    {
        if (self.image != nil && self.imageChanged == true)
        {
            let data = UIImageJPEGRepresentation(self.image!, 0.8)!
            
            // set upload path
            let filePath = "\(id)/\("kitchenPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            // Create a root reference
            let storageRef = Storage.storage().reference()
            storageRef.child(filePath).putData(data, metadata: metaData)
            {
                (metaData,error) in
                if let error = error
                {
                    print(error.localizedDescription)
                    return
                }
                else
                {
                    self.hasImage = true
                    //do not have to store the download url as it can be calculated
                    
                    //store downloadURL
                    //let downloadURL = metaData!.path
                    //store downloadURL at database
                    //db.child("Kitchens/\(id)").updateChildValues(["kitchenPhoto": downloadURL!])
                }
            }
        }
    }
    
    public func addRating(rating: Float)
    {
        if(self.rating == -1)
        {
            self.rating = rating
        }
        else
        {
            self.rating = limitToTwoDecimal(input: ((self.rating * Float(self.ratingCount) + rating)/Float(self.ratingCount + 1)))
        }
        
        self.ratingCount = self.ratingCount + 1
        
        //write it to the server
        writeRatingToServer()
    }
    
    private func writeRatingToServer()
    {
        let kitchenRef = db.child("Kitchens/\(id)")
        kitchenRef.child("rating").setValue(self.rating)
        kitchenRef.child("ratingCount").setValue(self.ratingCount)
    }
    
    public func updateRating(oldRating: Float, newRating:Float)
    {
        if(oldRating == newRating)  //do nothing if they are both the same
        {
            return
        }
        
        if(self.ratingCount == 1)   //if the oldRating was the first time the kitchen was rated ever, simply update to the new rating
        {
            self.rating = newRating
        }
        else
        {
            self.rating = limitToTwoDecimal(input: (((self.rating * Float(self.ratingCount)) - oldRating + newRating)/Float(self.ratingCount)))
        }
        
        writeRatingToServer()
    }
}
