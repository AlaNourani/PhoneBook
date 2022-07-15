//
//  ContactEntity+CoreDataProperties.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//
//

import Foundation
import CoreData


extension ContactEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var name: String
    @NSManaged public var surname: String
    @NSManaged public var phoneNumber: String
    @NSManaged public var emailAddress: String
    @NSManaged public var notes: String?
    @NSManaged public var imageLinks: [String]?
    @NSManaged public var id: String

}

extension ContactEntity : Identifiable {

}
