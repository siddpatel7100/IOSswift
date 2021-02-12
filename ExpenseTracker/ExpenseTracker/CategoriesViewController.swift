//
//  CategoriesViewController.swift
//  ExpenseTracker
//
//  Copyright © 2020 Conestoga IOS. All rights reserved.
//

import UIKit

//Controller for viewing all categories images
class CategoriesViewController : UIViewController {
    
    //refernce to category store shared instance
    var categoryStore : CategoryStore! = CategoryStore.sharedManager
    var categories : [Category] = []

    //outlet of collectionview object
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    //IBAction of import button which will fetch data by using JSON service
    @IBAction func importHandler(_ sender: Any) {
        categoryStore.importCategoriesFromJsonService{
            (categoryResult) in
            switch categoryResult {
                case .success:
                    self.reloadData()
                case .failure:
                    self.categories.removeAll()
            }
        }
    }
    //reloaddata when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadData()
    }
    
    private func reloadData() {
        
        //fetch data from category store (coredata)
        self.categoryStore.fetchAllCategories {
            (categoryResult) in
            switch categoryResult {
                case let .success(categories):
                    self.categories = categories
                    
                    //reload data into collection view
                    self.myCollectionView.reloadData()

                case .failure:
                    self.categories.removeAll()
            }
        }
    }
    
    //set attrubutes for showing category with segue identifier
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategory"?:
            
            //get selected item and pass the data values to the destination controller
            if let selectedIndexPath = myCollectionView.indexPathsForSelectedItems?.first {
	                let category = categories[selectedIndexPath.row]
                let detailController = segue.destination as! CategoryDetailViewController
                detailController.category = category
                detailController.categoryStore = categoryStore
            }
            
        default:
            preconditionFailure("Unexpected seque identifier")
        }
    }
    
}

//Inheriting Datasource and Delegate for collectionView
extension CategoriesViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Number of items into collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    //returning the cell with dequereusablecell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        
        return cell
    }
    
    //setting height and width for the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (UIScreen.main.bounds.size.width - 9) / 4
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

//Implement collectionviewdelegate
extension CategoriesViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //fetching URL from category class and send it to the update function
        let category = categories[indexPath.row]
        categoryStore.fetchURLImage(category: category) {(result) -> Void in
            switch result {
                case let .success(image) :
                    if let cell = self.myCollectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                        cell.update(with: image)
                    }
                case .failure :
                    return
                }
        }
    }
}
