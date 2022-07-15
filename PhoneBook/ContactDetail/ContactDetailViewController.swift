//
//  ContactDetailViewController.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//

import UIKit

class ContactDetailViewController: UITableViewController, ContactListInjector {

    private var contact: ContactViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editeButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editeContact))
        self.navigationItem.rightBarButtonItem = editeButton
    }
    
    func setContact(_ contact: ContactViewModel) {
        self.contact = contact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.contact != nil {
            self.contact = contactListViewModel.contact(with: contact!.id)
            self.tableView.reloadData()
        }
    }
    @objc func editeContact() {
        guard let contact = contact else {
            return
        }

        let viewController = storyboard?.instantiateViewController(withIdentifier: "NewContactViewControllere") as! NewContactViewController
        viewController.setContact(contact)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    private func pictureCell(_ indexPath: IndexPath) -> ContactDetailPictureCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactDetailPictureCell, for: indexPath) as! ContactDetailPictureCell
        if let contact = contact {
            cell.configure(name: contact.getFullName(), image: contact.getImage())
        }
        return cell
    }
    
    private func infoCell(_ indexPath: IndexPath) -> ContactDetailInfoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactDetailInfoCell, for: indexPath) as! ContactDetailInfoCell
        if let contact = contact {
            var value: String = ""
            var title: String = ""
            if indexPath.row == 1 {
                value = contact.phoneNumber
                title = ContactProperties.phoneNumber.title
            } else if indexPath.row == 2 {
                value = contact.emailAddress
                title = ContactProperties.email.title
            } else if indexPath.row == 3 {
                value = contact.notes ?? ""
                title = ContactProperties.notes.rawValue
            }
            cell.configure(title: ContactProperties.allCases[indexPath.row + 1].rawValue, value: value)
        }
        return cell
    }
}

extension ContactDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let contact = contact else { return 0 }
        if contact.notes != nil {
            return ContactProperties.allCases.count - 1
        } else {
            return ContactProperties.allCases.count - 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return pictureCell(indexPath)
        } else {
            return infoCell(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 330
        } else if let contact = contact, contact.notes != nil, indexPath.row == ContactProperties.allCases.count - 1 {
            return contact.notes!.height(withConstrainedWidth: self.tableView.bounds.width - 50, font: UIFont.systemFont(ofSize: 17))
        } else {
            return 80
        }
    }
}
