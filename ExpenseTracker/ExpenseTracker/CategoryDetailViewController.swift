//
//  CategoryDetailViewController.swift
//  ExpenseTracker
//
//Copyright © 2020 Conestoga IOS. All rights reserved.
//

import UIKit

//Controller for viewing details of category
class CategoryDetailViewController: UIViewController {
    
    //Outlets for objects
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    //Declare variables of type Sategory and CategoryStore
    var category : Category!
    var categoryStore : CategoryStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetching details like category name, image from the URL and description and assign it to their respective holder
        
        categoryName.text = category.name
        
        categoryStore.fetchURLImage(category: category) {
            (result) -> Void in
            switch(result) {
            case let .success(image):
                self.myImageView.image = image
            case let .failure(error):
                let msg = "Error fetching image for category"
                print("\(msg) \(error.localizedDescription)")
            }
        }
        
        detailLabel.text = category.detail
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        longPressGR.minimumPressDuration = 0.5 // how long before menu pops up
        
        myImageView.addGestureRecognizer(longPressGR)
    }
    
    @objc func longPressHandler(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let senderView = sender.view,
              let superView = sender.view?.superview
        else { return }
        
        // Make image view as the window's first responder
        senderView.becomeFirstResponder()
        
        // Set up the shared UIMenuController
        let msg = NSLocalizedString("CopyImageURL", comment: "")
        let copyMenuItem = UIMenuItem(title: msg, action: #selector(copyImageUrl))
        UIMenuController.shared.menuItems = [copyMenuItem]
        
        // Show menu
        UIMenuController.shared.showMenu(from: superView, rect: senderView.frame)
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    // copy func when user select copy action
    @objc func copyImageUrl() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = category.url
        myImageView.resignFirstResponder()
    }
}
