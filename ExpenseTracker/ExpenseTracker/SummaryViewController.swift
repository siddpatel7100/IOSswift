//
//  ExpenseSummaryViewController.swift
//  ExpenseTracker
//
// Copyright © 2020 Conestoga IOS. All rights reserved.
//

import UIKit

//Controller for viewing summary details
class SummaryViewController: UIViewController {

    //Outlets for all the objects
    @IBOutlet private weak var pickerView       : UIPickerView!
    @IBOutlet private weak var fromDatePicker   : UIDatePicker!
    @IBOutlet private weak var toDatePicker     : UIDatePicker!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    //Reference to categoryspendinglist struct
    private var categorySpendingArray   : [CategorySpendingList] = []
            
    //used to convert number into proper format
    let numberFormatter : NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = NSLocale.current
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    //set the default value for datepicker objects
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromDatePicker.maximumDate = Date()
        toDatePicker.maximumDate = Date()
        
        fromDatePicker.addTarget(self, action: #selector(didChangeFromDate(_:)), for: .valueChanged)
        toDatePicker.addTarget(self, action: #selector(didChangeToDate(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //remove current array data
        self.categorySpendingArray.removeAll()
        
        //fetch categories
        CategoryStore.sharedManager.fetchAllCategories {
            (categoryResult) in
            switch categoryResult {
                case let .success(categories):
                    
                    for category in categories {
                        if (category.spendings != nil) {
                            self.categorySpendingArray.append(CategorySpendingList(category: category.name!, spendingItems:Array(category.spendings!)))
                        } else {
                            self.categorySpendingArray.append(CategorySpendingList(category: category.name!, spendingItems:[]))
                        }
                    }
                    
                    //reload all the components into picker view
                    self.pickerView.reloadAllComponents()
                
                //if failed, make category spending array empty
                case .failure:
                    self.categorySpendingArray.removeAll()
            }
        }
    }
    
    
    //private function for checking and validating that from date is not bigger than to date
    @objc private func didChangeFromDate(_ sender: UIDatePicker) {
        toDatePicker.minimumDate = sender.date
        if sender.date > toDatePicker.date {
            toDatePicker.setDate(sender.date, animated: true)
        }
    }
    
    @objc private func didChangeToDate(_ sender: UIDatePicker) {
    }

    //MARK: - Action Methods -
    @IBAction private func didTapOnbuttonFinalResult(_ sender: Any) {
        var spendingArray : [Spending] = []
        let selectedCategory = categorySpendingArray[pickerView.selectedRow(inComponent: 0)]
        for spending in selectedCategory.spendingItems {
            let orderFrom = Calendar.current.compare(spending.createdDate!, to: fromDatePicker.date, toGranularity: .day)

            let orderTo = Calendar.current.compare(spending.createdDate!, to: toDatePicker.date, toGranularity: .day)
            
            if ((orderFrom == .orderedSame || orderFrom == .orderedDescending) && (orderTo == .orderedSame || orderTo == .orderedAscending)) {
                spendingArray.append(spending)

            }
        }
        
        //fetch and store all the spending amount to amount variable
        var amount = 0.0
        for object in spendingArray {
            amount += object.amount
        }
        
        //Showing appropriate result based upon search
        let cname = NSLocalizedString("CategoryName", comment: "")
        let spendingAmount = NSLocalizedString("TotalSpendingAmount", comment: "")
        if spendingArray.count > 0 {
            resultLabel.text = "\(cname) \(spendingArray[0].category?.name ?? "") \n \(spendingAmount) \(numberFormatter.string(from: NSNumber(value: amount)) ?? "")"
        } else {
            let errMsg = NSLocalizedString("NoRecordFound", comment: "")
            resultLabel.text = "\(errMsg)"
        }
    }
    
}

//inherit delegates to work with picker view
extension SummaryViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    //showing total number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    //showing total number of rows for component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorySpendingArray.count
    }

    //showing title for the row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       // let categoryName = NSLocalizedString(categoryArray[row].name, comment: "")
        return categorySpendingArray[row].category
    }
}
