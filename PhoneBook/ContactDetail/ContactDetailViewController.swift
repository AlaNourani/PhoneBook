//
//  ContactDetailViewController.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//

import UIKit
import Combine

final class ContactDetailViewController: UIViewController, ContactListInjector {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var contact: ContactViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editeButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editeContact))
        self.navigationItem.rightBarButtonItem = editeButton
        
        self.activityIndicator.isHidden = true

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
        self.contact = contact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.contact != nil {
            self.contact = contactListViewModel.contact(with: contact!.id)
            self.tableView.reloadData()
        }
    }
}

//MARK: - Actions
extension ContactDetailViewController {
    @objc func editeContact() {
        guard let contact = contact else {
            return
        }

        let viewController = storyboard?.instantiateViewController(withIdentifier: "NewContactViewControllere") as! NewContactViewController
        viewController.setContact(contact)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


//MARK: - UITableViewDataSource
extension ContactDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let contact = contact else { return 0 }
        if contact.notes != nil {
            return ContactProperties.allCases.count
        } else {
            return ContactProperties.allCases.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return pictureCell(indexPath)
        } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            return deleteCell(indexPath)
        } else {
            return infoCell(indexPath)
        }
    }
}

//MARK: - UITableViewDelegate
extension ContactDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 330
        } else if let contact = contact, contact.notes != nil, indexPath.row == ContactProperties.allCases.count - 2 {
            return contact.notes!.height(withConstrainedWidth: self.tableView.bounds.width - 50, font: UIFont.systemFont(ofSize: 17)) + 50
        } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            return 100
        } else {
            return 75
        }
    }
}


//MARK: - TableViewCells
extension ContactDetailViewController {
    private func pictureCell(_ indexPath: IndexPath) -> ContactDetailPictureCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactDetailPictureCellIdetifier, for: indexPath) as! ContactDetailPictureCell
        if let contact = contact {
            cell.configure(name: contact.getFullName(), image: contact.getImage())
        }
        return cell
    }
    
    private func infoCell(_ indexPath: IndexPath) -> ContactDetailInfoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactDetailInfoCellIdentifier, for: indexPath) as! ContactDetailInfoCell
        if let contact = contact {
            var value: String = ""
            if indexPath.row == 1 {
                value = contact.phoneNumber
            } else if indexPath.row == 2 {
                value = contact.emailAddress
            } else if indexPath.row == 3 {
                value = contact.notes ?? ""
            }
            cell.configure(title: ContactProperties.allCases[indexPath.row + 1].title, value: value)
        }
        return cell
    }
    
    private func deleteCell(_ indexPath: IndexPath) -> DeleteContactCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: deleteContactCellIdentifier) as! DeleteContactCell
        cell.delegate = self
        return cell
    }
}


extension ContactDetailViewController: DeleteContactCellProtocol {
    func deleteContact() {
        guard let contact = contact else { return }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false
        contactListViewModel.deleteContact(contact.id)
    }
}
