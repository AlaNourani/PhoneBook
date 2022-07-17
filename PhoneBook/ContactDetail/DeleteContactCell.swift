//
//  DeleteContactCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/16/22.
//

import UIKit

protocol DeleteContactCellProtocol: AnyObject {
    func deleteContact()
}


final class DeleteContactCell: UITableViewCell {
        
    weak var delegate: DeleteContactCellProtocol?

    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        delegate?.deleteContact()
    }
}
