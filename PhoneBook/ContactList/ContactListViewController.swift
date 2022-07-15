//
//  ContactListViewController.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit
import Combine

final class ContactListViewController: UITableViewController, ContactListInjector {

    private var cancellables: Set<AnyCancellable> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupContacts()
    }
    
    private func setupContacts() {
        contactListViewModel.getContacts()
        contactListViewModel.$isDataChanged.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        .store(in: &cancellables)

    }
}

//MARK: - DataSource
extension ContactListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactListViewModel.numberOfContacts()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier, for: indexPath) as! ContactListCell
        if let contact = contactListViewModel.contact(at: indexPath.row) {
            cell.configure(contact)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = contactListViewModel.contact(at: indexPath.row) else { return }
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
        viewController.setContact(contact)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ContactListViewController: NewContactViewControllerProtocol {
    func addNewContact(_ contact: ContactViewModel) {
        contactListViewModel.addNewContact(contact)
    }
}
