//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import Foundation

let Parse = ParseClient.sharedInstance()

class ParseClient: NSObject {

    typealias CompletionHandler = ((_ result: AnyObject?, _ error: Error?) -> Void)?

    //MARK: Variables
    var students = [Student]()
    
    //MARK: private Variables
    private var allStudents:[[String: AnyObject]]{
        get{return []}
        set{
            students = [Student]()
            for studentParameters in newValue {students.append(Student(parameters: studentParameters))}
        }}
    
    //MARK: Public methods
    func loadStudents(completionHandler: CompletionHandler) {
        let parameters: [String:Any] = [ParseClient.Constants.LimitParameterKey: ParseClient.Constants.LimitParameterValue,
                                        ParseClient.Constants.OrderParameterKey: ParseClient.Constants.OrderParameterValue]
        parseTask(httpMethod: "GET", parameters: parameters, completionHandler: { result, error in
            
            guard let studentArray = result?["results"] as? [[String: AnyObject]], error == nil else {
                self.performOnMain(completionHandler, result: nil, error: NSError(domain: "loadStudents", code: 2, userInfo: [NSLocalizedDescriptionKey: "No results was returned by the request!"]))
                return
            }
            self.allStudents = studentArray
            self.performOnMain(completionHandler, result: result, error: error)
        })
    }
    
    func loadStudentWith(uniqueKey: String, completionHandler: CompletionHandler) {
        let whereParameterValue = ParseClient.Constants.WhereParameterValue.replacingOccurrences(of: ParseClient.Constants.UniqueKeyReplacment, with: uniqueKey)
        let parameters: [String:Any] = [ParseClient.Constants.WhereParameterKey: whereParameterValue]

        parseTask(httpMethod: "GET", parameters: parameters){ result, error in
            self.performOnMain(completionHandler, result: result, error: error)
        }
    }

    func updateStudent(_ student: Student, isNew: Bool, completionHandler: CompletionHandler) {
        parseTask(httpMethod: (isNew ? "POST" : "PUT"), data: student.data, pathExtension: (isNew ? nil : "/\(student.objectId!)")){ result, error in
            self.performOnMain(completionHandler, result: result, error: error)
        }
    }

    //MARK: Private methods
    
    private func parseTask(httpMethod: String, data: [String: Any]? = nil, pathExtension: String? = "", parameters: [String:Any]? = nil, withPathExtension: String? = nil, completionHandler: CompletionHandler) {
        var request = URLRequest(url: parseURLFromParameters(parameters: parameters, withPathExtension: pathExtension))
        request.addValue(ParseClient.Constants.AppIdValue, forHTTPHeaderField: ParseClient.Constants.AppIdKey)
        request.addValue(ParseClient.Constants.ApiValue, forHTTPHeaderField: ParseClient.Constants.ApiKey)
        
        if httpMethod == "POST" || httpMethod == "PUT" {
            request.addValue(ParseClient.Constants.ContentTypeValue, forHTTPHeaderField: ParseClient.Constants.ContentTypeKey)
            request.httpMethod = httpMethod
            if let data = data {
                request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            func sendError(_ error: Error) {
                print(error.localizedDescription)
                self.performOnMain(completionHandler, result: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error!)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                let error = NSError(domain: "parseTask", code: 2, userInfo: [NSLocalizedDescriptionKey : "Your request returned a status code other than 2xx!"])
                sendError(error)
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let error = NSError(domain: "parseTask", code: 3, userInfo: [NSLocalizedDescriptionKey : "No data was returned by the request!"])
                sendError(error)
                return
            }
            
            let parsedResult: AnyObject
            do { parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject}
            catch {
                sendError(error)
                return
            }

            self.performOnMain(completionHandler, result: parsedResult, error: nil)
        }
        
        task.resume()
    }

    private func performOnMain(_ completionHandler: CompletionHandler, result: AnyObject?, error: Error?) {
        DispatchQueue.main.async {
            if let completionHandler = completionHandler {
                completionHandler(result, error)
            }
        }
    }

    private func parseURLFromParameters(parameters: [String:Any]?, withPathExtension: String? = nil) -> URL {
        let components = NSURLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }

    //MARK: Singleton methods
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

}
