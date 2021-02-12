//
//  JsonServiceCategory.swift
//  ExpenseTracker
//
//  Copyright © 2020 Conestoga IOS. All rights reserved.
//

import Foundation

// class for categories fetch from Json service
class JsonServiceCategory {
    internal init(categoryId: Int32, detail: String? = nil, name: String? = nil, urlImage: String? = nil) {
        self.categoryId = categoryId
        self.detail = detail
        self.name = name
        self.urlImage = urlImage
    }
    
    public var categoryId: Int32
    public var detail: String?
    public var name: String?
    public var urlImage: String?
}
