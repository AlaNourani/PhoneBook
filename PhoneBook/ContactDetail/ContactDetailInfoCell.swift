//
//  ContactDetailInfoCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//

import UIKit

class ContactDetailInfoCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    
    func configure(title: String, value: String) {
        self.titleLabel.text = title
        self.valueLabel.text = value
    }
}
