//
//  NewContactPictureCell.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit

protocol NewContactPictureCellProtocol: AnyObject {
    func imageButtonDidTap()
}


final class NewContactPictureCell: UITableViewCell {
    
    @IBOutlet private weak var contactImageView: UIButton!
    weak var delegate: NewContactPictureCellProtocol?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    
    func setImage(_ image: UIImage?) {
        if let image = image {
            contactImageView.setImage(image, for: .normal)
            contactImageView.setBackgroundImage(nil, for: .normal)
        }
    }
    
    
    @IBAction func imageViewDidTap(_ sender: UIButton) {
        delegate?.imageButtonDidTap()
    }
}
