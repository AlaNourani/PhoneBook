//
//  ContactListCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit

final class ContactListCell: UITableViewCell {
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    
    override func prepareForReuse() {
        contactImage.image = UIImage(systemName: "person.crop.circle")
        nameLabel.text = ""
        phoneNumberLabel.text = ""
    }
    
    func configure(_ contact: ContactViewModel) {
        contactImage.layer.cornerRadius = contactImage.bounds.width / 2
        contactImage.layer.masksToBounds = true
        if let image = contact.getImage() {
            contactImage.image = image
        }
        nameLabel.text = contact.name
        phoneNumberLabel.text = contact.phoneNumber
    }
}
