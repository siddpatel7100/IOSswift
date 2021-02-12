//
//  SpendingViewController.swift
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-11-28.
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//

import UIKit
// Controller for application spending items
class SpendingItemsViewController: UIViewController {
    //reference to category store shared instance
    var categoryStore : CategoryStore! = CategoryStore.sharedManager
    //list of sections are used to display on table view
    var sections : [CategorySpendingList] = []
    //category list
    var categories : [Category] = []
    // store selected category
    var selectedCaterory : Category?
    //used to convert and format date
    let dateFormatter : DateFormatter = {
        let nf = DateFormatter()
        nf.locale = NSLocale.current
        return nf
    }()
    //used to convert and format number
    let numberFormatter : NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = NSLocale.current
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        return nf
    }()

    //referrence to table view
    @IBOutlet weak var mySpendingTable: UITableView!
    
    //when app loaded, the app update tableview
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
    }
    
    //if there is new data saved when back to this view, it will call to updateTableView
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if categoryStore.hasChanges {
            updateTableView()
        }
    }
    
    // set attributes for upcoming controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        // used for edit
        case "showDetail"?:
            // get selected section
            if let section = mySpendingTable.indexPathForSelectedRow?.section {
                selectedCaterory = self.categories[section]
                
                let selectedSection = self.sections[section]
                // get selected row in the section
                if let row = mySpendingTable.indexPathForSelectedRow?.row {
                    let selectedSpending = selectedSection.spendingItems[row]
                    
                    //get spending detail and assign necessary attributes for it
                    let detailViewController = segue.destination as! SpendingDetailViewController
                    let location = (selectedSpending.location != nil) ? Location(title: selectedSpending.location!, latitude: selectedSpending.latitude, longitude: selectedSpending.longitude) : nil
                    detailViewController.spendingItem = SpendingDto(id: selectedSpending.spendingId!, title: selectedSpending.title!, location: location, amount: selectedSpending.amount, createdDate: selectedSpending.createdDate, imageData: selectedSpending.image)
                    //set the store is not saved and assign to detail controller
                    categoryStore.hasChanges = false
                    detailViewController.store = categoryStore
                    detailViewController.selectedCaterory = selectedCaterory
                }
            }

        // used for add new spending item
        case "addItem"?:
            //get spending detail and assign necessary attributes for it
            let detailViewController = segue.destination as! SpendingDetailViewController
            detailViewController.spendingItem = SpendingDto()
            //set the store is not saved and assign to detail controller
            categoryStore.hasChanges = false
            detailViewController.store = categoryStore
            detailViewController.selectedCaterory = selectedCaterory
        default:
            preconditionFailure("Unexpected seque identifier")
        }
    }
    // update data source for table view
    private func updateTableView() {
        //remove current list
        self.sections.removeAll()
        //fetch data
        self.categoryStore.fetchAllCategories {
            (categoryResult) in
            switch categoryResult {
                case let .success(categories):
                    // assign to categories and sections
                    self.categories = categories
                    for category in categories {
                        if (category.spendings != nil) {
                            self.sections.append(CategorySpendingList(category: category.name!, spendingItems:Array(category.spendings!)))
                        } else {
                            self.sections.append(CategorySpendingList(category: category.name!, spendingItems:[]))
                        }
                    }
                    
                    // reload table
                    self.mySpendingTable.reloadData()

                //if failed, make sections empty
                case .failure:
                    self.sections.removeAll()
            }
        }
    }
}

extension SpendingItemsViewController : UITableViewDelegate, UITableViewDataSource {
    //the number of section of table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    // set cell for header in section tableview
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableViewCell") as! SectionTableViewCell
        let sectionRecord = self.sections[section]

        cell.configure(text: sectionRecord.category, delegate: self)
        cell.index = section
        
        return cell
    }
    
    //set height for header section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    ///the number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionRecord = self.sections[section]
        return sectionRecord.spendingItems.count
    }
    
    // set cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mySpendingTable.dequeueReusableCell(withIdentifier: "SpendingTableViewCell", for: indexPath) as! SpendingTableViewCell
        cell.selectionStyle = .none
        let sectionRecord = self.sections[indexPath.section]
        let spendingItem = sectionRecord.spendingItems[indexPath.row]
        
        cell.titleLabel.text = spendingItem.title
        
        cell.speendingLabel.text = numberFormatter.string(from: NSNumber(value: spendingItem.amount))

        
        return cell
    }
}

//implement SectionTableViewCellDelegate when user tab on Plus icon in header section
extension SpendingItemsViewController: SectionTableViewCellDelegate {
    func cell(_ cell: SectionTableViewCell, didTap button: UIButton) {
        selectedCaterory = self.categories[cell.index]
    }
}
