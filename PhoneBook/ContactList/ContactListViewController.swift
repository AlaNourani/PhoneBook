//
//  ContactListViewController.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit
import Combine

final class ContactListViewController: UITableViewController, ContactListInjector {

    @IBOutlet private weak var searchBar: UISearchBar!

    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        searchBar.delegate = self
        setupContacts()
    }
    
    private func setupContacts() {
        contactListViewModel.getContacts()
        contactListViewModel.$isDataChanged.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.cancelSearching()
                self?.tableView.reloadData()
            }
        }
        .store(in: &cancellables)
    }
    
    private func cancelSearching() {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        contactListViewModel.filterContacts(with: "")
    }
}

//MARK: - SearchBarDelegate
extension ContactListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        contactListViewModel.filterContacts(with: searchText)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearching()
        tableView.reloadData()
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
