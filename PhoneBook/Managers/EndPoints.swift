//
//  EndPoints.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import Foundation

struct EndPoint {
    var urlString: String
//    var path: String
//    var queryItems: [URLQueryItem] = []
}

extension EndPoint {
//    var url: URL {
////        var components = URLComponents()
////        components.scheme = "https"
////        components.host = "https://stdevtask3-0510.restdb.io"
////        components.path = "/rest" + path
////        components.queryItems = queryItems
////
////        guard let url = components.url else {
////            preconditionFailure("Invalid URL components: \(components)")
////        }
////
////        return url
//    }
    
    var headers: [String: Any] {
        return [
            "accept": "application/json",
            "x-apikey": "a5b39dedacbffd95e1421020dae7c8b5ac3cc"
        ]
    }
}


//extension EndPoint {
//    static var contacts: Self {
//        var endPoint = EndPoint(urlString: Constants.getContactsURL())
//        endPoint.headers = []
//        return endPoint
////        return EndPoint(path: "/contacts")
//    }
//}
