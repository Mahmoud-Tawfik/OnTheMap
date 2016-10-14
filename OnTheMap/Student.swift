//
//  Student.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import Foundation

struct Student {
    var firstName: String!
    var lastName: String!
    var latitude: Double!
    var longitude: Double!
    var mapString: String!
    var mediaURL: String!
    var objectId: String!
    var uniqueKey: String!
    var createdAt: Date!
    var updatedAt: Date!
    
    var fullName : String { return "\(firstName ?? "") \(lastName ?? "")" }
    
    init(firstName: String!, lastName: String!, latitude: Double!, longitude: Double!, mapString: String!, mediaURL: String!, uniqueKey: String!){
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.uniqueKey = uniqueKey
    }
    
    init(parameters: [String: AnyObject]) {
        firstName = parameters["firstName"] as? String
        lastName = parameters["lastName"] as? String
        latitude = parameters["latitude"] as? Double
        longitude = parameters["longitude"] as? Double
        mapString = parameters["mapString"] as? String
        mediaURL = parameters["mediaURL"] as? String
        if !mediaURL.contains("http") && !mediaURL.isEmpty{ mediaURL = "http://" + mediaURL }
        objectId = parameters["objectId"] as? String
        uniqueKey = parameters["uniqueKey"] as? String
        createdAt = dateFrom(string: parameters["createdAt"] as? String)
        updatedAt = dateFrom(string: parameters["updatedAt"] as? String)
    }
    
    var data: [String : Any] {
        get{
            return ["uniqueKey": uniqueKey,
                    "firstName": firstName,
                    "lastName": lastName,
                    "mapString": mapString,
                    "mediaURL": mediaURL,
                    "latitude": latitude,
                    "longitude": longitude]
        }
    }
    
    private func dateFrom(string: String!) -> Date! {
        if let dateString = string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale.current
            return formatter.date(from: dateString)
        } else {
            return nil
        }
    }
}
