//
//  SpendingDetailViewController.swift
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-11-28.
//  Copyright © 2020 Nam Nhi Nguyen. All rights reserved.
//

import UIKit
// controller for spending detail view
class SpendingDetailViewController: UIViewController, UINavigationControllerDelegate {
    
    var store : CategoryStore?
    
    let numberFormatter : NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = NSLocale.current
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    var selectedCaterory : Category?
    var spendingItem : SpendingDto!
    var category : Category!
    
    @IBOutlet weak var titleLabelText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var createDateControl: UIDatePicker!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        locationLabel.text = spendingItem.location?.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set values to control input
        self.createDateControl.maximumDate = Date()
        
        titleLabelText.text = spendingItem.title
        
        if let amountValue = spendingItem.amount {
            amountText.text = numberFormatter.string(from: NSNumber(value: amountValue))
        } else {
            amountText.text = ""
        }
        if let imageData = spendingItem.imageData {
            itemImage.image = UIImage(data: imageData)
        }
        if let date = spendingItem.createdDate {
            createDateControl.date = date
        }
        // set menu context to image view
        let interaction = UIContextMenuInteraction(delegate: self)
        itemImage.addInteraction(interaction)
        itemImage.isUserInteractionEnabled = true
    }
    
    @IBAction func saveSpending(_ sender: Any) {
        let errors : String = validate()
        if (!errors.isEmpty) {
            errorLabel.text = errors
        } else {
            errorLabel.text = ""
            // get input data
            spendingItem.title = titleLabelText.text!
            spendingItem.amount = numberFormatter.number(from: amountText.text!)?.doubleValue
            spendingItem.createdDate = createDateControl.date
            spendingItem.imageData = itemImage.image?.pngData()
            
            //call save function in store
            store!.saveSpending(selectedCategory: selectedCaterory, savedItem: spendingItem) {
                (spendingItemsResult) in
                
                switch spendingItemsResult {
                case .success:
                    self.errorLabel.text = ""
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    self.errorLabel.text = error.localizedDescription
                }
            }
        }
    }
    
    // validate inputs
    func validate() -> String {
        self.view.endEditing(true)
        
        if (titleLabelText.text!.isEmpty) {
            let msg = NSLocalizedString("TitleIsEmpty", comment: "")
            return msg
        }
        
        if (amountText.text!.isEmpty) {
            let msg = NSLocalizedString("AmountIsEmpty", comment: "")
            return msg
        }
        
        if let amount = numberFormatter.number(from: amountText.text!)?.doubleValue, amount <= 0 {
            let msg = NSLocalizedString("AmountIsLessThanOrEqualZero", comment: "")
            return msg
        }

        
        if itemImage.image == nil {
            let msg = NSLocalizedString("ImageIsEmpty", comment: "")
            return msg
        }
        
        if locationLabel.text?.count ?? 0 == 0 {
            let msg = NSLocalizedString("LocationIsEmpty", comment: "")
            return msg
        }
        
        return ""
    }
    // tap gesture handler to dismiss keyboard
    @IBAction func dismissKeyboard(_ sender: Any) {
        if (titleLabelText.isFirstResponder) {
            titleLabelText.resignFirstResponder()
        } else if (amountText.isFirstResponder) {
            amountText.resignFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        // assign location for map controller
        case "showMap"?:
            let mapViewController = segue.destination as! AppMapViewController
            if spendingItem.location == nil {
                spendingItem.location = Location()
            }
            
            mapViewController.currentLocation = spendingItem.location
            
            
        default:
            preconditionFailure("Unexpected seque identifier")
        }
    }
}

// implement image picker
extension SpendingDetailViewController : UIImagePickerControllerDelegate {
    func imagePicker(for sourceType: UIImagePickerController.SourceType)
    -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self

        return imagePicker
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        // Get picked image from dictionary
        let image = info[.originalImage] as! UIImage
        
        // Set that image to the image view
        itemImage.image = image
        
        // Take image picker off the screen
        dismiss(animated: true, completion: nil)
    }
}

// implement UIContextMenuInteractionDelegate to create menu context to change picture of spending item
extension SpendingDetailViewController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenuForPicture()
        }
    }
    
    func createContextMenuForPicture() -> UIMenu {
        var actions : [UIAction] = []
        // if spending item has image, adding delete action
        if (self.spendingItem.imageData != nil) {
            let delete = NSLocalizedString("Delete", comment: "")
            let deleteAction = UIAction(title: delete, image: UIImage(systemName: "trash")) { _ in
                let deleteMessage = NSLocalizedString("Delete", comment: "Delete picture")
                let confirmMessage = NSLocalizedString("AreYouSure", comment: "Are you sure?")
                
                let ac = UIAlertController(title : deleteMessage, message: confirmMessage, preferredStyle: .actionSheet)
                
                let cancelStr = NSLocalizedString("Cancel", comment: "Cancel")
                let cancelAction = UIAlertAction(title: cancelStr, style: .cancel, handler: nil)
                ac.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(title: deleteMessage, style: .destructive, handler: {(action)->Void in
                    self.itemImage.image = nil
                })
                
                ac.addAction(deleteAction)
                
                self.present(ac, animated: true, completion: nil)
            }
            actions.append(deleteAction)
        }
        
        // select image from library action
       // let username = NSLocalizedString("spending", comment: "")
        let title = NSLocalizedString("ChooseFromLibrary", comment: "")
        let folder = NSLocalizedString("Folder", comment: "")
        let libraryAction = UIAction(title: title, image: UIImage(systemName: folder)) { _ in
            let imagePicker = self.imagePicker(for: .photoLibrary)
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        
        actions.append(libraryAction)
        
        // Check if current devide supports camera and add camera action
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let title = NSLocalizedString("TakeAPhoto", comment: "")
            let photo = NSLocalizedString("Photo", comment: "")
            let takePhotoAction = UIAction(title: title, image: UIImage(systemName: photo)) { _ in
                let imagePicker = self.imagePicker(for: .camera)
                imagePicker.modalPresentationStyle = .popover
                imagePicker.popoverPresentationController?.barButtonItem = self.navigationItem.backBarButtonItem
                
                self.present(imagePicker, animated: true, completion: nil)
            }
            actions.append(takePhotoAction)
        }
        
        return UIMenu(title: "", children: actions)
    }
}

// implement delegate to support 'Return' button on keyboard and fix dot issue with number pad and limit the length of input
extension SpendingDetailViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var result : Bool = true
            let currentLocale = NSLocale.current
            let decimalSeparator = currentLocale.decimalSeparator!
            if let oldString = textField.text {
                let currentString = oldString as NSString
                let newString : String =
                    currentString.replacingCharacters(in: range, with: string)
                
                if (textField == amountText) {
                    if (newString.count > 10) {
                        return false
                    }
                    
                    if let _ = oldString.range(of : decimalSeparator) {
                        if let _ = string.range(of : decimalSeparator) {
                            result = false
                        }
                    }
                } else {
                    if (newString.count > 25) {
                        result = false
                    }
                }
            } else {
                result = false
            }

        return result
    }
}



