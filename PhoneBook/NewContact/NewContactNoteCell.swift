//
//  NewContactNoteCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//

import UIKit

protocol NewContactNoteCellProtocol: AnyObject {
    func noteDidUpdate(_ cell: NewContactNoteCell)
}


final class NewContactNoteCell: UITableViewCell {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var placeholderLabel: UILabel!
    
    weak var delegate: NewContactNoteCellProtocol?
    
    func configure(_ note: String? = nil) {
        if let note = note {
            textView.text = note
            placeholderLabel.isHidden = true
        }
        
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        textView.layer.borderWidth = 0.5
    }
    
    var note: String {
        return textView.text
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
    }
}

extension NewContactNoteCell: UITextViewDelegate {    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.showError("Please add some notes")
            placeholderLabel.isHidden = false
        } else {
            self.showError("")
            placeholderLabel.isHidden = true
        }
        delegate?.noteDidUpdate(self)
    }
    
}
