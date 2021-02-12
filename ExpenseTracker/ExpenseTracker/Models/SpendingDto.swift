//
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-11-21.
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//

import Foundation
// define class for spending item in detail spending controller
class SpendingDto {
    internal init(id: UUID, title: String = "", location: Location? = nil, amount: Double? = nil, createdDate: Date? = nil, imageData: Data? = nil) {
        self.id = id
        self.title = title
        self.location = location
        self.amount = amount
        self.createdDate = createdDate
        self.imageData = imageData
    }
    
    var id : UUID
    var title : String = ""
    var location : Location?
    var amount : Double?
    var createdDate : Date?
    var imageData : Data?
    init() {
        id = UUID.init()
    }
}
