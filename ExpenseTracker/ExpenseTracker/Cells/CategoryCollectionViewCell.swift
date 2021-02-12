//
//  PhotoCollectionViewCell.swift
//  ExpenseTracker
//
//  Created by Nguyen Nam Nhi on 2020-11-24.
//

import UIKit
//Define custom cell for cells in category list
class CategoryCollectionViewCell : UICollectionViewCell {
    // reference to image
    @IBOutlet var imageView : UIImageView!
    // spinner for loading image
    @IBOutlet var spinner : UIActivityIndicatorView!

    // update image when it's available
    func update(with image : UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            spinner.hidesWhenStopped = true
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update(with:nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        update(with: nil)
    }
}
