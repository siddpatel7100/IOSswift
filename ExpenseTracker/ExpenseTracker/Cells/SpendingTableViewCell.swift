//
//  SpendingTableViewCell.swift
//  ExpenseTracker
//
//  Created by Nam Nhi Nguyen
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//

import UIKit
//Define custom cell for row 
class SpendingTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var speendingLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.adjustsFontForContentSizeCategory = true
        speendingLabel?.adjustsFontForContentSizeCategory = true
    }
    
}
