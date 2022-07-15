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
    fileprivate let networkController: NetworkControllerProtocol
    private let contactStorage = ContactStorage()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.networkController = NetworkController()
        contactStorage.fetchContacts()
        contactStorage.$savedContacts.sink { [weak self] contactsArray in
            self?.contactViewModels = contactsArray.map{ ContactViewModel($0) }
            self?.isDataChanged.toggle()
        }.store(in: &cancellables)
    }
    
    func getContacts() {
        getContactsFromServer().sink { result in
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
        addContactToServer(contact)
            .sink { [weak self] result in
                self?.isDataReceived = true
        } receiveValue: {[weak self] newContact in
            self?.contactStorage.addContact(contact)
            self?.contactViewModels.append(newContact)
            self?.isDataChanged.toggle()
        }.store(in: &cancellables)
    }
    
    func updateContact(_ contact: ContactViewModel) {
        updateContactToServer(contact)
            .sink { [weak self] result in
                self?.isDataReceived = true
        } receiveValue: {[weak self] updatedContact in
            self?.contactStorage.updateContact(updatedContact)
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
    private func getContactsFromServer() -> AnyPublisher<[ContactViewModel], APIError> {
        let url = URL(string: Constants.getContactsURL())!
        return networkController.get(type: [ContactViewModel].self, url: url)
    }
    
    private func addContactToServer(_ contact: ContactViewModel) -> AnyPublisher<ContactViewModel, APIError> {
        let url = URL(string: Constants.getContactsURL())!
       return networkController.post(type: ContactViewModel.self, url: url, payload: contact)
    }
    
    private func updateContactToServer(_ contact: ContactViewModel) -> AnyPublisher<ContactViewModel, APIError> {
        let urlString = Constants.getContactsURL()
        let url = URL(string: urlString + "/" + contact.id)!
        return networkController.put(type: ContactViewModel.self, url: url, payload: contact)
    }
}
