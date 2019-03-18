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

class Kitchen
{
    var id: String
    var name: String
    var rating:NSNumber
    var timeForFood:String
    var address: String
    var type: String
    var ratingCount: NSNumber
    var hasImage: Bool
    var offersVegetarian: Bool
    var longitude: Double
    var latitude: Double
    
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
            "timeForFood": self.timeForFood,
            "type": self.type,
            "latitude": self.latitude,
            "longitude": self.longitude
        ]
    }
    
    init(id:String, name:String, rating:NSNumber, timeForFood:String, address: String, type: String, ratingCount: NSNumber, hasImage: Bool, offersVegetarian: Bool, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.rating = rating
        self.timeForFood = timeForFood
        self.address = address
        self.type = type
        self.ratingCount = ratingCount
        self.offersVegetarian = offersVegetarian
        self.hasImage = hasImage
        self.imageChanged = false
        self.latitude = latitude
        self.longitude = longitude
        
        if(self.hasImage)
        {
            self.loadImageFromDB()
        }
    }
    
    
    //convenience constructors
    public convenience init?(dictionary: NSDictionary, id: String)
    {
        guard let name = dictionary["name"] as? String,
            let rating = dictionary["rating"] as? NSNumber,
            let timeForFood = dictionary["timeForFood"] as? String,
            let address = dictionary["address"] as? String,
            let type = dictionary["type"] as? String,
            let ratingCount = dictionary["ratingCount"] as? NSNumber,
            let offersVegetarian = dictionary["offersVegetarian"] as? Bool,
            let hasImage =  dictionary["hasImage"] as? Bool,
            let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double
            else { return nil }
        
        self.init(id: id, name:name, rating: rating, timeForFood: timeForFood,address: address, type: type, ratingCount: ratingCount, hasImage: hasImage, offersVegetarian: offersVegetarian, latitude: latitude, longitude: longitude)
    }
    
    public convenience init?(snapshot: DataSnapshot)
    {
        let id = snapshot.key as String
        let snapshot = snapshot.value as AnyObject
        
        let name = snapshot["name"] as! String
        let rating = snapshot["rating"] as! NSNumber
        let timeForFood = snapshot["timeForFood"] as! String
        let address = snapshot["address"] as! String
        let type = snapshot["type"] as! String
        let ratingCount = snapshot["ratingCount"] as! NSNumber
        let offersVegetarian = snapshot["offersVegetarian"] as! Bool
        let hasImage = snapshot["hasImage"] as! Bool
        let latitude = snapshot["latitude"] as! Double
        let longitude = snapshot["longitude"] as! Double
        
        self.init(id: id, name:name, rating: rating, timeForFood: timeForFood,address: address, type: type, ratingCount: ratingCount, hasImage: hasImage, offersVegetarian: offersVegetarian, latitude: latitude, longitude: longitude)
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
}
