//
//  Restaurant.swift
//  LocationApp
//
//  Created by expsk on 5/5/16.
//  Copyright © 2016 pavlovsky. All rights reserved.
//

import Foundation

class Restaurant {
    var name:String
    var rating:String?
    var phone:String?
//    var city:String
//    var zipCode:String
//    var street:String
//    var number:String
//    var website:String
//    var logoImage:String
//    var openTime:String
//    var closeTime:String
//    var offerStart:String
//    var offerEnd:Stringva
    var price_level: String?
    var address: String
    var rating_image_url: String?
    var distance: Double
    var percentRecommended: Int?
    var latitude:String
    var longitude:String
    
    init(restDictionary: NSDictionary) {
        self.name = restDictionary["name"] as! String
        self.latitude = restDictionary["latitude"] as! String
        self.longitude = restDictionary["longitude"] as! String
        self.rating = restDictionary["rating"] as? String
        self.distance = restDictionary["distance"]!.doubleValue
        self.rating_image_url = restDictionary["rating_image_url"] as? String
        self.address = restDictionary.valueForKeyPath("address_obj.address_string") as! String
        self.phone = restDictionary["phone"] as? String
        self.percentRecommended = restDictionary["percent_recommended"] as? Int
        self.price_level = restDictionary["price_level"] as? String
        print("Created: \(name)")
    }
}