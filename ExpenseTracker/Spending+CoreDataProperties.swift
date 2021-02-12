//
//  Spending+CoreDataProperties.swift
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-12-02.
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Spending {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Spending> {
        return NSFetchRequest<Spending>(entityName: "Spending")
    }

    @NSManaged public var amount: Double
    @NSManaged public var createdDate: Date?
    @NSManaged public var image: Data?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var longitude: Double
    @NSManaged public var spendingId: UUID?
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}

extension Spending : Identifiable {

}
