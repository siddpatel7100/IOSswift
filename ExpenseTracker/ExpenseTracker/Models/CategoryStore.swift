//
//  CategoryStore.swift
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-12-02.
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//

import UIKit
import CoreData
//Json error
enum JSONError : Error {
    case invalidJSONData
}
// Common store class used to connect to CoreData and Service
class CategoryStore {
    // allow to share store instance and use only one PersistentContainer
    static let sharedManager = CategoryStore()
    private init() {}
    // flag to check whether this store is saved or not
    var hasChanges : Bool = false
    
    // persistentContainer with ExpenseTracker CoreData
    let persistentContainer: NSPersistentContainer = {
        let ename = NSLocalizedString("ExpenseTracker", comment: "")
        let container = NSPersistentContainer(name: ename)
        container.loadPersistentStores { (description, error) in
            if let error = error {
                let emsg = NSLocalizedString("Error setting up Core Data", comment: "")
                print("\(emsg)  (\(error)).")
            }
        }
        return container
    }()
    
    // session for fetching Jsonservice and images
    let session : URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // Fetch categories from CoreData
    func fetchAllCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        // create request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        // create SortDescriptor to sort by name
        let sortByName = NSSortDescriptor(key: #keyPath(Category.name),
                                          ascending: true)
        fetchRequest.sortDescriptors = [sortByName]

        // get context and fetch data
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            // handler for error
            do {
                let allCategories = try viewContext.fetch(fetchRequest)
                completion(.success(allCategories))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // func for saving spending item,
    func saveSpending(selectedCategory: Category?, savedItem : SpendingDto, completion: @escaping (Result<UUID, Error>) -> Void) {
        var spending: Spending!
        let context = self.persistentContainer.viewContext
        
        // Check whether saved spending is exist in selected category or not
        let existSpending = selectedCategory!.spendings?.filter{$0.spendingId == savedItem.id
        }.first
        
        // if exist, update values
        if existSpending != nil {
            existSpending!.title = savedItem.title
            existSpending!.amount = savedItem.amount!
            existSpending!.createdDate = savedItem.createdDate!
            if let location = savedItem.location, !location.title.isEmpty {
                existSpending!.location = location.title
                existSpending!.longitude = location.longitude
                existSpending!.latitude = location.latitude
            }
            existSpending!.image = savedItem.imageData
        } else {
            // not exist, create new and add to selectedCategory
            spending = Spending(context: context)
            spending.spendingId = savedItem.id
            spending.title = savedItem.title
            spending.amount = savedItem.amount!
            spending.createdDate = savedItem.createdDate!
            if let location = savedItem.location, !location.title.isEmpty {
                spending.location = location.title
                spending.longitude = location.longitude
                spending.latitude = location.latitude
            }
            spending.image = savedItem.imageData
            spending.category = selectedCategory
            
            selectedCategory?.addToSpendings(spending)
        }
        
        // save viewContext
        do {
            try self.persistentContainer.viewContext.save()
            hasChanges = true
            completion(.success(savedItem.id))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Call when app get started to add default categories if not exist
    func createIfNotExistDefaultCategories() -> Void {
        
        let name1 = NSLocalizedString("Travelling", comment: "")
        let description1 = NSLocalizedString("All things related to travelling expenses", comment: "")
        _=createIfNotExist(name: name1, id: 1, url: "https://live.staticflickr.com/7396/26986402670_e6d3b03795_b.jpg", detail: description1)
        
        let name2 = NSLocalizedString("Health", comment: "")
        let description2 = NSLocalizedString("All things related to health expenses", comment: "")
        _=createIfNotExist(name: name2, id: 2, url: "https://live.staticflickr.com/65535/17124132409_855d5fa9b5_b.jpg", detail: description2)
        
        let name3 = NSLocalizedString("Food", comment: "")
        let description3 = NSLocalizedString("All things related to food expenses", comment: "")
        _=createIfNotExist(name: name3, id: 3, url: "https://live.staticflickr.com/5096/5570908019_fe9b0745c8_o.jpg", detail: description3)
        
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
            let error = NSLocalizedString("error", comment: "")
            print(error)
        }
    }
    
    //createIfNotExist func to reuse
    private func createIfNotExist(name : String, id : Int32, url: String, detail : String) -> Category {
        let context = self.persistentContainer.viewContext
        var category: Category!
        // get categories by id
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(
            format: "\(#keyPath(Category.categoryId)) == \(id)"
        )
        fetchRequest.predicate = predicate
        var fetchedResult: [Category]?
        context.performAndWait {
            fetchedResult = try? fetchRequest.execute()
        }
        
        // if exist return it
        if let existingCategory = fetchedResult?.first {
            return existingCategory
        }
        
        // if not exist, add to context
        context.performAndWait {
            category = Category(context: context)
            category.name = name
            category.categoryId = id
            category.url = url
            category.detail = detail
        }
        
        return category;
    }
    
    func importCategoriesFromJsonService(completion: @escaping (Result<[Category], Error>) -> Void) {
        // create request to fetch categories from json service to import
        let components = URLComponents(string : "http://localhost:3000/master")
        let url = components!.url
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { [self]
            (data, response, error) -> Void in
            // process response
            var result = self.processCategoriessRequest(data: data, error: error)
            
            // save view context for add spending items
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                    self.hasChanges = true
                } catch {
                    result = .failure(error)
                }
            }
            
            //return result to caller
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func fetchURLImage(category : Category, completion: @escaping(Result<UIImage, Error>) -> Void) {
        let photoURL = category.url!
        let request = URLRequest(url: URL(string: photoURL)!)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processImageResponse(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    // create UIImage from response
    private func processImageResponse(data: Data?,
                                      error: Error?) -> Result<UIImage, Error> {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            return .failure(error!)
        }
        
        return .success(image)
    }
    
    private func processCategoriessRequest(data: Data?,
                                           error: Error?) -> Result<[Category], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        // parse json data to json category objects and create and add to view context if not exist
        switch parseDataToObjects(fromJSON: jsonData) {
        case let .success(jsonServiceCategories):
            let categories = jsonServiceCategories.map { jsonCategory -> Category in
                return createIfNotExist(name: jsonCategory.name!, id: jsonCategory.categoryId, url: jsonCategory.urlImage!, detail: jsonCategory.detail!)
            }
            
            return .success(categories)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    func parseDataToObjects(fromJSON data : Data) -> Result<[JsonServiceCategory], Error> {
        
        do {
            // parse json to json object
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonDictionary = jsonObject as? [AnyHashable:Any], let categoriesJSON = jsonDictionary["categories"] as? [[String:Any]] {
                // parse dictionary to JsonServiceCategory list
                var categories  = [JsonServiceCategory]()
                for categoryJSON in categoriesJSON {
                    if let category = dictionariesToCategogy(fromJson: categoryJSON) {
                        categories.append(category)
                    }
                }
                
                return .success(categories)
            }
            
            return .failure(JSONError.invalidJSONData)
        } catch let error {
            return .failure(error)
        }
    }
    
    // create JsonServiceCategory object from dictionary
    func dictionariesToCategogy(fromJson json : [String:Any]) -> JsonServiceCategory? {
        if let id = json["id"] as! Int?, let name = json["name"] as! String?, let url = json["url"] as! String?, let detail = json["detail"] as! String? {
            return JsonServiceCategory(categoryId : Int32(id), detail: NSLocalizedString(detail, comment: ""), name: NSLocalizedString(name, comment: ""), urlImage: url)
            
        }
        
        return nil
    }
}
