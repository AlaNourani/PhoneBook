//
//  NewContactInfoCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit

protocol NewContactInfoCellProtocol: AnyObject {
    func textFieldValueSetted(_ cell: NewContactInfoCell)
}


final class NewContactInfoCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var errorLable: UILabel!
    
    private var property: ContactProperties!
    weak var delegate: NewContactInfoCellProtocol?
    
    var dataString: String? {
        return textField.text
    }
    
    //TODO: Consider a limitation for every string that user adds!
    func configure(property: ContactProperties, value: String? = nil) {
        self.titleLabel.text = property.title
        self.property = property
        
        if property == .phoneNumber {
            textField.keyboardType = .phonePad
        } else if property == .email {
            textField.keyboardType = .emailAddress
        }
        
        if let value = value {
            textField.text = value
            delegate?.textFieldValueSetted(self)
        }

        textField.placeholder = property.title
    }
    
    func showErrorMessage(_ message: String) {
        errorLable.text = message
    }
    
    func getProperty() -> ContactProperties {
        return self.property
    }
}

extension NewContactInfoCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldValueSetted(self)
    }
}
