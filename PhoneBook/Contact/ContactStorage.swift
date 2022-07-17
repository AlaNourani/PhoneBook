//
//  ContactStorage.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import Foundation
import CoreData
import UIKit

final class ContactStorage: ObservableObject {
    
    private var container: NSPersistentContainer
    @Published var savedContacts: [ContactEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "PhoneBook")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading core data. \(error)")
            }
        }
        fetchContacts()
    }
    
    
    func fetchContacts() {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            savedContacts = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func fetchContact(_ id: String) -> ContactEntity? {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let contact = try container.viewContext.fetch(request)
            return contact.first
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    
    func syncContacts(_ contacts: [ContactViewModel]) {
        self.deleteAllData()
        self.batchInsertContacts(contacts)
    }
    
    private func deleteAllData() {
        let storeContainer = container.persistentStoreCoordinator

        for store in storeContainer.persistentStores {
            do {
                try storeContainer.destroyPersistentStore(
                    at: store.url!,
                    ofType: store.type,
                    options: nil
                )
            } catch let error {
                print("Error deleting database. \(error)")
            }
        }

        container = NSPersistentContainer(
            name: "PhoneBook"
        )

        container.loadPersistentStores {
            (store, error) in
            // Handle errors
        }
    }
    private func batchInsertContacts(_ contacts: [ContactViewModel]) {
      guard !contacts.isEmpty else { return }
      container.performBackgroundTask { context in
        let batchInsert = self.newBatchInsertRequest(with: contacts)
        do {
            try context.execute(batchInsert)
            self.fetchContacts()
        } catch let error {
            print("Error inserting batch data. \(error)")
        }
      }
    }
    
    private func newBatchInsertRequest(with contacts: [ContactViewModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = contacts.count
        let batchInsert = NSBatchInsertRequest(
            entity: ContactEntity.entity()) { (managedObject: NSManagedObject) -> Bool in
                guard index < total else { return true }
                
                if let contact = managedObject as? ContactEntity {
                    let data = contacts[index]
                    contact.name = data.name
                    contact.surname = data.surname
                    contact.phoneNumber = data.phoneNumber
                    contact.emailAddress = data.emailAddress
                    contact.notes = data.notes
                    contact.imageLinks = data.imageLinks
                    if let id = data.id {
                        contact.id = id
                    }
                }
                
                index += 1
                return false
            }
        return batchInsert
    }
    
    func addContact(_ contact: ContactViewModel) {
        let newContact = ContactEntity(context: container.viewContext)
        newContact.name = contact.name
        newContact.surname = contact.surname
        newContact.phoneNumber = contact.phoneNumber
        newContact.emailAddress = contact.emailAddress
        newContact.notes = contact.notes
        newContact.imageLinks = contact.imageLinks
        newContact.id = contact.id

        saveData()
    }
    
    func updateContact(_ updatedContact: ContactViewModel) {
        if let id = updatedContact.id, let contact = fetchContact(id) {
            contact.name = updatedContact.name
            contact.surname = updatedContact.surname
            contact.phoneNumber = updatedContact.phoneNumber
            contact.emailAddress = updatedContact.emailAddress
            contact.notes = updatedContact.notes
            contact.imageLinks = updatedContact.imageLinks
            
            saveData()
        }
    }
    
    func deleteContact(_ id: String) {
        if let contact = fetchContact(id) {
            container.viewContext.delete(contact)
            saveData()
        }
    }
    
    private func saveData() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                fetchContacts()
            } catch let error {
                print("Error saving. \(error)")
            }
        }
    }
    
}
