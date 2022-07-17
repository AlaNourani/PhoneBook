//
//  NewContactViewController.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit
import Combine

enum ContactProperties: String, CaseIterable {
    case name, surname, phoneNumber, email, notes
    
    var title: String {
        switch self {
        case .name:
            return "Name"
        case .surname:
            return "Last Name"
        case .phoneNumber:
            return "Phone Number"
        case .email:
            return "Email Address"
        case .notes:
            return "Notes"
        }
    }
}

protocol NewContactViewControllerProtocol: AnyObject {
    func addNewContact(_ contact: ContactViewModel)
}


final class NewContactViewController: UIViewController, ContactListInjector {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var contactBuilder = ContactBuilder()
    fileprivate var imagePicker = UIImagePickerController()
    private var cancellables: Set<AnyCancellable> = []
    private var contact: ContactViewModel?
    
    weak var delegate: NewContactViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = contact != nil ? "Edit" : "Add Contact"
        
        self.activityIndicator.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        
        contactListViewModel.$isDataReceived.sink { [weak self] isDataReceived in
            self?.tableView.isUserInteractionEnabled = true
            if isDataReceived == true {
                self?.activityIndicator.stopAnimating()
                self?.contactListViewModel.isDataReceived = false
                self?.navigationController?.popViewController(animated: true)
            }
        }.store(in: &cancellables)
    }
    
    func setContact(_ contact: ContactViewModel) {
        self.contactBuilder.setContact(contact)
        self.contact = contact
    }
    
    
    private func pictureCell() -> NewContactPictureCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactPictureCellIdentifier) as! NewContactPictureCell
        cell.delegate = self
        if let contact = contact {
            cell.setImage(contact.getImage())
        }
        return cell
    }
    
    
    private func propertyCell(for index: Int) -> NewContactInfoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactInformationCellIdentifier) as! NewContactInfoCell
        cell.delegate = self
        if index <= ContactProperties.allCases.count {
            let property = ContactProperties.allCases[index - 1]
            
            var value: String?
            if let contact = contact {
                value = contact.valueForProperty(property)
            }
            cell.configure(property: property, value: value)
        }
        return cell
    }
    
    private func doneButtonCell(for index: Int) -> NewContactDoneCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: addButtonCellIdentifier) as! NewContactDoneCell
        cell.delegate = self
        return cell
    }
    
    private func noteCell() -> NewContactNoteCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newContactNoteCellIdentifier) as! NewContactNoteCell
        cell.configure(contact != nil ? contact!.notes : nil)
        cell.delegate = self
        return cell
    }
}


extension NewContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactProperties.allCases.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return pictureCell()
        } else if indexPath.row == ContactProperties.allCases.count {
            return noteCell()
        } else if indexPath.row > ContactProperties.allCases.count {
            return doneButtonCell(for: indexPath.row)
        } else {
            return propertyCell(for: indexPath.row)
        }
    }
}

extension NewContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        if indexPath.row == ContactProperties.allCases.count {
            return 130
        }
        if indexPath.row == ContactProperties.allCases.count + 1 {
            return 70
        }
        return 90
    }
}


extension NewContactViewController: NewContactInfoCellProtocol {
    func textFieldDidEndEditing(_ cell: NewContactInfoCell) {
        let value = cell.dataString
        var errorMessage: String = ""
        
        switch cell.getProperty() {
        case .name:
            contactBuilder.setName(value)
            errorMessage = contactBuilder.nameErrorMessage
            
        case .surname:
            contactBuilder.setSurname(value)
            errorMessage = contactBuilder.surnameErrorMessage
            
        case .phoneNumber:
            contactBuilder.setPhoneNumber(value)
            errorMessage = contactBuilder.phoneNumberErrorMessage
            
        case .email:
            contactBuilder.setEmail(value)
            errorMessage = contactBuilder.emailErrorMessage
            
        default:
            break
        }
        
        cell.showErrorMessage(errorMessage)
    }
}

extension NewContactViewController: NewContactPictureCellProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imageButtonDidTap() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! NewContactPictureCell
        cell.setImage(image)
        if let data = image.pngData() {
            let dataString = data.base64EncodedString()
            contactBuilder.addImage(dataString)
        }
    }
}

extension NewContactViewController: NewContactNoteCellProtocol {
    func noteDidUpdate(_ cell: NewContactNoteCell) {
        contactBuilder.setNotes(cell.note)
    }
}


extension NewContactViewController: NewContactDoneCellProtocol {
    func addContact() {
        if let newContact = contactBuilder.build() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            self.tableView.isUserInteractionEnabled = false
            if let _ = contact {
                contactListViewModel.updateContact(newContact)
            } else {
                contactListViewModel.addNewContact(newContact)
            }
        } else if !contactBuilder.notesErrorMessage.isEmpty {
            let indexPath = IndexPath(row: ContactProperties.allCases.count, section: 0)
            if let cell = self.tableView.cellForRow(at: indexPath) as? NewContactNoteCell {
                cell.showError(contactBuilder.notesErrorMessage)
            }
        }
    }
}
