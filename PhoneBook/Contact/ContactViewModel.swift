//
//  ContactViewModel.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit
import Combine

struct ContactViewModel: Codable {
    private(set) var name: String
    private(set) var surname: String
    private(set) var phoneNumber: String
    private(set) var emailAddress: String
    private(set) var notes: String?
    private(set) var imageLinks: [String]?
    private(set) var id: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "firstName"
        case surname = "lastName"
        case phoneNumber = "phone"
        case emailAddress = "email"
        case notes = "notes"
        case imageLinks = "images"
    }
}

extension ContactViewModel {
    init(_ contact: ContactEntity) {
        self.name = contact.name
        self.surname = contact.surname
        self.phoneNumber = contact.phoneNumber
        self.emailAddress = contact.emailAddress
        self.notes = contact.notes
        self.imageLinks = contact.imageLinks
        self.id = contact.id
    }
    
    init(name: String, surname: String, phoneNumber: String, emailAddress: String, notes: String, imageLinks: [String]? = nil, id: String?) {
        self.name = name
        self.surname = surname
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.notes = notes
        self.imageLinks = imageLinks
        if let id = id {
            self.id = id
        }
    }
}

extension ContactViewModel {
    func getFullName() -> String {
        return name + " " + surname
    }
    
    func getImage() -> UIImage? {
        if let images = imageLinks, !images.isEmpty {
            if let dataDecoded = Data(base64Encoded: images[0]), let image = UIImage(data: dataDecoded) {
                return image
            }
        }
        return nil
    }
}


final class ContactBuilder {
    private(set) var id: String!
    @Published private(set) var name: String?
    @Published private(set) var surname: String?
    @Published private(set) var phoneNumber: String?
    @Published private(set) var emailAddress: String?
    @Published private(set) var notes: String?
    @Published private(set) var image: [String]?
    @Published private var cancellableSet: Set<AnyCancellable> = []
    
    @Published var isNameValid = false
    @Published var isSurnameValid = false
    @Published var isPhoneNumberValid = false
    @Published var isEmailValid = false
    @Published var isNotesValid = false
    @Published var canSubmit = false
    
    var nameErrorMessage: String {
        return isNameValid ? "" : "Please enter contact's name."
    }
    var surnameErrorMessage: String {
        return isSurnameValid ? "" : "Please enter contact's lastname."
    }
    var phoneNumberErrorMessage: String {
        return isPhoneNumberValid ? "" : "Please enter a valid number."
    }
    var emailErrorMessage: String {
        return isEmailValid ? "" : "Valid email format: email@example.com"
    }
    var notesErrorMessage: String {
        return isNotesValid ? "": "Please add some notes"
    }
    
    
    private let phonePredicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9+]{0,1}+[0-9]{5,16}$")
    private let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")

    init() {
        $name
            .map { name in
                return name != nil && !name!.isEmpty
            }
            .assign(to: \.isNameValid, on: self)
            .store(in: &cancellableSet)
            
        $surname
            .map { surname in
                return surname != nil && !surname!.isEmpty
            }
            .assign(to: \.isSurnameValid, on: self)
            .store(in: &cancellableSet)
    
        $phoneNumber
            .map { phoneNumber in
                return phoneNumber != nil && self.phonePredicate.evaluate(with: phoneNumber)
            }
            .assign(to: \.isPhoneNumberValid, on: self)
            .store(in: &cancellableSet)
        
        $emailAddress
            .map { email in
                return email != nil && self.emailPredicate.evaluate(with: email!)
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellableSet)
        
        $notes
            .map { notes in
                return notes != nil && !notes!.isEmpty
            }
            .assign(to: \.isNotesValid, on: self)
            .store(in: &cancellableSet)
        
        
        Publishers.CombineLatest($isNameValid, $isSurnameValid)
            .map{ isNameValid, isSurnameValid in
                return (isNameValid && isSurnameValid)
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellableSet)
        
        
        Publishers.CombineLatest3($isPhoneNumberValid, $isEmailValid, $isNotesValid)
            .map{ isPhoneNumberValid, isEmailValid, isNotesValid in
                return (isPhoneNumberValid && isEmailValid && isNotesValid)
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellableSet)
    }
    
    func setContact(_ contact: ContactViewModel) {
        self.name = contact.name
        self.surname = contact.surname
        self.phoneNumber = contact.phoneNumber
        self.emailAddress = contact.emailAddress
        self.notes = contact.notes
        self.addImage(contact.imageLinks?.first)
        self.id = contact.id
    }
    
    func setName(_ name: String?) {
        self.name = name
    }
    
    func setSurname(_ surname: String?) {
        self.surname = surname
    }
    
    func setPhoneNumber(_ phoneNumber: String?) {
        self.phoneNumber = phoneNumber
    }
    
    func setEmail(_ email: String?) {
        self.emailAddress = email
    }
    
    func setNotes(_ notes: String?) {
        self.notes = notes
    }
    
    func addImage(_ imageData: String?) {
        guard let imageData = imageData else {
            return
        }

        if self.image == nil {
            self.image = [imageData]
        } else {
            self.image!.append(imageData)
        }
    }
    
    func build() -> ContactViewModel? {
        if canSubmit {
            return ContactViewModel(name: name!, surname: surname!, phoneNumber: phoneNumber!, emailAddress: emailAddress!, notes: notes!, imageLinks: image, id: id)
        } else {
            return nil
        }
    }
    
    func valueForProperty(_ key: ContactProperties) -> String? {
        switch key {
        case .name:
            return self.name
        case .surname:
            return self.surname
        case .phoneNumber:
            return self.phoneNumber
        case .email:
            return self.emailAddress
        case .notes:
            return self.notes
        }
    }
}
