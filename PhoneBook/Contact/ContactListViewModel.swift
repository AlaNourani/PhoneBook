//
//  ContactListViewModel.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import Combine
import Foundation

protocol ContactListInjector {
    var contactListViewModel: ContactListViewModel { get }
}

fileprivate let sharedContactList: ContactListViewModel = ContactListViewModel()

extension ContactListInjector {
    var contactListViewModel: ContactListViewModel {
        return sharedContactList
    }
}


final class ContactListViewModel {
    
    @Published private(set) var contactViewModels: [ContactViewModel] = []
    @Published private(set) var filteredContacViewModels: [ContactViewModel] = []
    @Published var addContactErrorMessage: String?
    @Published var updateContactErrorMessage: String?
    @Published var deleteContactErrorMessage: String?
    @Published var isDataChanged = false
    @Published var isDataReceived = false
    private let contactService = ContactService()
    private let contactStorage = ContactStorage()
    private var isSearching = false
    private var searchText: String = ""
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        contactStorage.fetchContacts()
        contactStorage.$savedContacts.sink { [weak self] contactsArray in
            guard let self = self else { return }
            self.contactViewModels = contactsArray.map{ ContactViewModel($0) }
            self.filterContacts(with: self.searchText)
            self.isDataChanged.toggle()
        }.store(in: &cancellables)
        
    }
    
    func filterContacts(with searchText: String) {
        isSearching = !searchText.isEmpty
        if isSearching == true {
            filteredContacViewModels = contactViewModels.filter {
                return $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.surname.lowercased().contains(searchText.lowercased()) ||
                $0.phoneNumber.contains(searchText)
            }
        }
    }
    
    func numberOfContacts() -> Int {
        return isSearching ? filteredContacViewModels.count : contactViewModels.count
    }
    
    func contact(at index: Int) -> ContactViewModel? {
        let contactsArray = isSearching ? filteredContacViewModels : contactViewModels
        guard (0..<numberOfContacts()).contains(index) else { return nil }
        return contactsArray[index]
    }
    
    func contact(with id: String) -> ContactViewModel? {
        guard let contact = contactStorage.fetchContact(id) else { return nil }
        return ContactViewModel(contact)
    }
}

extension ContactListViewModel {
    func getContacts() {
        contactService.getContactsFromServer().sink { result in
            switch result {
            case .finished:
                print("Finished")
            case .failure(let error):
                print("Error. \(error)")
            }
        } receiveValue: { [weak self] contacts in
            self?.contactStorage.syncContacts(contacts)
            self?.isDataChanged.toggle()
        }.store(in: &cancellables)
        
    }
    
    func addNewContact(_ contact: ContactViewModel) {
        self.isDataReceived = false
        contactService.addContactToServer(contact)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    print("Adding contact finished.")
                case .failure(let error):
                    self?.addContactErrorMessage = error.localizedDescription
                }
                self?.isDataReceived = true
            } receiveValue: {[weak self] newContact in
                self?.contactStorage.addContact(newContact)
            }.store(in: &cancellables)
    }
    
    func updateContact(_ contact: ContactViewModel) {
        self.isDataReceived = false
        contactService.updateContactToServer(contact)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    print("Contact is updated.")
                case .failure(_):
                    self?.updateContactErrorMessage = "You can only update contacts that you created."
                }
                self?.isDataReceived = true
            } receiveValue: {[weak self] updatedContact in
                self?.contactStorage.updateContact(updatedContact)
                self?.isDataChanged.toggle()
            }.store(in: &cancellables)
    }
    
    func deleteContact(_ id: String) {
        self.isDataReceived = false
        contactService.deleteContact(id)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    print("Contact is deleted.")
                case .failure(_):
                    self?.deleteContactErrorMessage = "You can only delete contacts that you created."
                }
                self?.isDataReceived = true
            } receiveValue: { [weak self] value in
                self?.contactStorage.deleteContact(id)
            }
            .store(in: &cancellables)
    }
}
