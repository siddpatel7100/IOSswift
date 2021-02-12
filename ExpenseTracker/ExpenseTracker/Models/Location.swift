//
//  Location.swift
//  ExpenseTracker
//
// Copyright © 2020 Conestoga IOS. All rights reserved.
//

import Foundation
//define class for location in map controller
class Location {
    var latitude : Double
    var longitude : Double
    var title : String!
    init(title:String, latitude : Double, longitude : Double) {
        self.title = title;
        self.latitude = latitude;
        self.longitude = longitude
    }
    
    init() {
        self.title = ""
        longitude = 0.0
        latitude = 0.0
    }
}
