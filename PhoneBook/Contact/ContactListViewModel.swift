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


class ContactListViewModel {
    
    @Published private(set) var contactViewModels: [ContactViewModel] = []
    @Published var isDataChanged = false
    @Published var isDataReceived = false
    private let contactService = ContactService()
    private let contactStorage = ContactStorage()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        contactStorage.fetchContacts()
        contactStorage.$savedContacts.sink { [weak self] contactsArray in
            self?.contactViewModels = contactsArray.map{ ContactViewModel($0) }
            self?.isDataChanged.toggle()
        }.store(in: &cancellables)
    }
    
    func numberOfContacts() -> Int {
        return contactViewModels.count
    }
    
    func contact(at index: Int) -> ContactViewModel? {
        guard (0..<numberOfContacts()).contains(index) else { return nil }
        return contactViewModels[index]
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
        contactService.addContactToServer(contact)
            .sink { [weak self] result in
                self?.isDataReceived = true
        } receiveValue: {[weak self] newContact in
            self?.contactStorage.addContact(contact)
            self?.contactViewModels.append(newContact)
            self?.isDataChanged.toggle()
        }.store(in: &cancellables)
    }
    
    func updateContact(_ contact: ContactViewModel) {
        contactService.updateContactToServer(contact)
            .sink { [weak self] result in
                self?.isDataReceived = true
        } receiveValue: {[weak self] updatedContact in
            self?.contactStorage.updateContact(updatedContact)
            self?.isDataChanged.toggle()
        }.store(in: &cancellables)
    }
    
    func deleteContact(_ id: String) {
        contactService.deleteContact(id)
            .sink { [weak self] result in
                self?.isDataReceived = true
            } receiveValue: { [weak self] value in
                self?.contactStorage.deleteContact(id)
            }
            .store(in: &cancellables)

    }
}
