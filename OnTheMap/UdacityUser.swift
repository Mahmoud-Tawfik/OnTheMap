//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/12/16.
//
//

import Foundation

struct UdacityUser {
    let firstName: String!
    let lastName: String!
    
    var fullName : String { return "\(firstName!) \(lastName!)" }
    
    init(parameters: [String: AnyObject]) {
        firstName = parameters["user"]?["first_name"] as? String
        lastName = parameters["user"]?["last_name"] as? String
    }
}
