//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import Foundation

extension UdacityClient{
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        struct methods {
            static let session = "/session"
            static let user = "/users"
        }
        
        // MARK: App ID & API
        static let AcceptKey = "Accept"
        static let ContentTypeKey = "Content-Type"
        
        static let AcceptValue = "application/json"
        static let ContentTypeValue = "application/json"

    }
}
