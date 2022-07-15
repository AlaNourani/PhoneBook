//
//  ErrorHandlerViewModel.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/15/22.
//

import Combine

class ErrorHandlerViewModel: ObservableObject {
    static let shared = ErrorHandlerViewModel()
    
    var serverErrorMessage = PassthroughSubject<String, Never>()

    var errorMessage = ""
    
    
    private var cancellables = Set<AnyCancellable>()
    
    
    private init() {
        serverErrorMessage.sink { message in
            self.errorMessage = message
        }
        .store(in: &cancellables)
    }
}
