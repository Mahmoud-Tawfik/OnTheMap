//
//  ParseData.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/14/16.
//
//

import Foundation

let ParseStudents = ParseData.singleton

class ParseData {
    
    static let singleton = ParseData()
    
    //MARK: Variables
    var students = [Student]()
    
    //MARK: private Variables
    func updateStudents(_ data: [[String: AnyObject]]){
            students = [Student]()
            for studentParameters in data {students.append(Student(parameters: studentParameters))}
        }
}
