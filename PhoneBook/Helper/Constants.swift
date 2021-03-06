//
//  Constants.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//


let contactCellIdentifier = "contactCell"
let contactPictureCellIdentifier = "imageCell"
let contactInformationCellIdentifier = "infoCell"
let addButtonCellIdentifier = "addButtonCell"
let contactDetailPictureCell = "detailImageCell"
let contactDetailInfoCell = "detailInfoCell"
let newContactNoteCell = "noteCell"

struct Constants {
    static let baseURL = "https://stdevtask3-0510.restdb.io/rest"
    
    private static let contactsURL = "/contacts"
    
    static func getContactsURL() -> String {
        return baseURL + contactsURL
    }
}
