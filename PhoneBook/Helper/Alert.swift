//
//  Alert.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import UIKit

struct Alerts {
    static func showAlert(viewController: UIViewController, title: String?, message: String?, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            completion()
        }
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showActionSheet(viewController: UIViewController, title: String?, message: String?, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    for (index, (title, style)) in actions.enumerated() {
        let alertAction = UIAlertAction(title: title, style: style) { (_) in
            completion(index)
        }
        alertController.addAction(alertAction)
     }
     
     viewController.present(alertController, animated: true, completion: nil)
    }
}
