//
//  ContactDetailPictureCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//

import UIKit

class ContactDetailPictureCell: UITableViewCell {

    @IBOutlet private weak var pictureView: UIButton!
    @IBOutlet private weak var nameLable: UILabel!
    
    func configure(name: String, image: UIImage?) {
        nameLable.text = name
        if let image = image {
            pictureView.setImage(image, for: .normal)
            pictureView.imageView?.layer.cornerRadius = pictureView.bounds.width / 2
            pictureView.imageView?.layer.masksToBounds = true
        }
    }
}
