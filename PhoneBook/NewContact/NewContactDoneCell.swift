//
//  NewContactDoneCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit

protocol NewContactDoneCellProtocol: AnyObject {
    func addContact()
}

final class NewContactDoneCell: UITableViewCell {

    @IBOutlet private weak var doneButton: UIButton!
    weak var delegate: NewContactDoneCellProtocol?
    
    
    @IBAction private func addButtonDidTap(_ sender: UIButton) {
        delegate?.addContact()
    }
}
