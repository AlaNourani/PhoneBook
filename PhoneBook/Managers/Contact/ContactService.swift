//
//  ContactService.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/16/22.
//

import UIKit
import Combine

final class ContactService: NetworkManager {
    
    func getContactsFromServer() -> AnyPublisher<[ContactViewModel], APIError> {
        let url = URL(string: Constants.getContactsURL())!
        return get(type: [ContactViewModel].self, url: url)
    }
    
    func addContactToServer(_ contact: ContactViewModel) -> AnyPublisher<ContactViewModel, APIError> {
        let url = URL(string: Constants.getContactsURL())!
       return post(type: ContactViewModel.self, url: url, payload: contact)
    }
    
    func updateContactToServer(_ contact: ContactViewModel) -> AnyPublisher<ContactViewModel, APIError> {
        let urlString = Constants.getContactsURL()
        let id = contact.id ?? ""
        let url = URL(string: urlString + "/" + id)!
        return put(type: ContactViewModel.self, url: url, payload: contact)
    }
    
    func deleteContact(_ contactId: String) -> AnyPublisher<Bool, APIError> {
        let urlString = Constants.getContactsURL()
        let url = URL(string: urlString + "/" + contactId)!
        return delete(url: url)
    }
}
