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
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    @IBAction private func addButtonDidTap(_ sender: UIButton) {
        delegate?.addContact()
    }
}
