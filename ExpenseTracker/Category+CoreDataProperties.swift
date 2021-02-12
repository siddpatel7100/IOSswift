//
//  Category+CoreDataProperties.swift
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-12-02.
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryId: Int32
    @NSManaged public var detail: String?
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var spendings: Set<Spending>?

}

// MARK: Generated accessors for spendings
extension Category {

    @objc(addSpendingsObject:)
    @NSManaged public func addToSpendings(_ value: Spending)

    @objc(removeSpendingsObject:)
    @NSManaged public func removeFromSpendings(_ value: Spending)

    @objc(addSpendings:)
    @NSManaged public func addToSpendings(_ values: NSSet)

    @objc(removeSpendings:)
    @NSManaged public func removeFromSpendings(_ values: NSSet)

}

extension Category : Identifiable {

}
