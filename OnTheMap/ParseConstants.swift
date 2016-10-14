//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/12/16.
//
//

import Foundation

extension ParseClient{
    struct Constants {
        
        // MARK: URL
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes/StudentLocation"
        
        // MARK: App ID & API
        static let AppIdKey = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
        static let ContentTypeKey = "Content-Type"
        
        static let AppIdValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ContentTypeValue = "application/json"

        // MARK: Parameter Keys
        static let LimitParameterKey = "limit"
        static let OrderParameterKey = "order"
        static let SkipParameterKey = "skip"

        // MARK: Parameter Values
        static let LimitParameterValue = 100
        static let OrderParameterValue = "-updatedAt"
        static let SkipParameterValue = 0
        
        static let WhereParameterKey = "where"
        static let WhereParameterValue = "{\"uniqueKey\":\"uniqueKeyReplacment\"}"
        static let UniqueKeyReplacment = "uniqueKeyReplacment"
        

        
    }

}
