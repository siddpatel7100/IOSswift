//
//  SectionTableViewCell.swift
//  ExpenseTracker
//
//  Created by Nam Nhi Nguyen
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//

import UIKit
// Section custom cell
class SectionTableViewCell: UITableViewCell {
    @IBOutlet var categoryLabel : UILabel!
    var index : Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryLabel?.adjustsFontForContentSizeCategory = true
    }
    
    weak var delegate: SectionTableViewCellDelegate?

    //define func to configure while creating section
    func configure(text: String, delegate: SectionTableViewCellDelegate) {
        
        categoryLabel.text = NSLocalizedString(text, comment: "")
        self.delegate = delegate
        
    }

    // when user taps on plus icon, calling SectionTableViewCellDelegate
    @IBAction func didTapButton(_ button: UIButton) {
        delegate?.cell(self, didTap: button)
    }
}

// define protocol for header section and is triggerd when user taps on plus button
protocol SectionTableViewCellDelegate: class {
    func cell(_ cell: SectionTableViewCell, didTap button: UIButton)
}
