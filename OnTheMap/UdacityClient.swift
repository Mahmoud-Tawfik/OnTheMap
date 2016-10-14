//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import Foundation

let Udacity = UdacityClient.sharedInstance()

class UdacityClient: NSObject {
    
    typealias CompletionHandler = ((_ success: Bool, _ error: Error?) -> Void)?

    //MARK: Variables
    
    var userKey: String!
    var user: UdacityUser!

    //MARK: Public methods

    func login(email: String, password: String, completionHandler: CompletionHandler) {
        createUdacitySession(email: email, password: password) {success, error in
            if error == nil {
                self.getPublicUserData { success, error in
                    self.performOnMain(completionHandler, success: success, error: error)
                }
            } else {
                self.performOnMain(completionHandler, success: success, error: error)
            }
        }
    }
    
    func logout(completionHandler: CompletionHandler) {
        self.performOnMain(completionHandler, success: true, error: nil)
        deleteUdacitySession{ success, error in
            if error == nil {
                Udacity.userKey = nil
                Udacity.user = nil
            }
        }
    }

    //MARK: Private methods

    private func createUdacitySession(email: String, password: String, completionHandler: CompletionHandler) {
        var request = URLRequest(url: udacityURL(method: UdacityClient.Constants.methods.session))
        request.httpMethod = "POST"
        request.addValue(Constants.AcceptValue, forHTTPHeaderField: Constants.AcceptKey)
        request.addValue(Constants.ContentTypeValue, forHTTPHeaderField: Constants.ContentTypeKey)
        let data = ["udacity": ["username":email, "password":password]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            func sendError(_ error: Error) {
                print(error.localizedDescription)
                self.performOnMain(completionHandler, success: false, error: error)
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let error = NSError(domain: "createUdacitySession", code: 1, userInfo: [NSLocalizedDescriptionKey : "There was an error with your request"])
                sendError(error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                let error = NSError(domain: "createUdacitySession", code: 2, userInfo: [NSLocalizedDescriptionKey : "Your request returned a status code other than 2xx!"])
                sendError(error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let newData = data?.subdata(in: 5..<(data?.count ?? 0)) else {
                let error = NSError(domain: "createUdacitySession", code: 2, userInfo: [NSLocalizedDescriptionKey : "No data was returned by the request!"])
                sendError(error)
                return
            }
            
            let parsedResult: AnyObject
            do { parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject}
            catch {
                let error = NSError(domain: "createUdacitySession", code: 2, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                sendError(error)
                return
            }
            
            guard let account = parsedResult["account"] as? [String: AnyObject], let userKey = account["key"] as? String else {
                let error = NSError(domain: "createUdacitySession", code: 2, userInfo: [NSLocalizedDescriptionKey : "account key not found!"])
                sendError(error)
                return
            }
            
            Udacity.userKey = userKey
            self.performOnMain(completionHandler, success: true, error: nil)
        }
        task.resume()

    }
    
    private func deleteUdacitySession(completionHandler: CompletionHandler) {

        var request = URLRequest(url: udacityURL(method: UdacityClient.Constants.methods.session))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            func sendError(_ error: Error) {
                print(error.localizedDescription)
                self.performOnMain(completionHandler, success: false, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let error = NSError(domain: "deleteUdacitySession", code: 1, userInfo: [NSLocalizedDescriptionKey : "There was an error with your request"])
                sendError(error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                let error = NSError(domain: "deleteUdacitySession", code: 2, userInfo: [NSLocalizedDescriptionKey : "Your request returned a status code other than 2xx!"])
                sendError(error)
                return
            }
            self.performOnMain(completionHandler, success: true, error: nil)
        }
        task.resume()
    }
    
    private func getPublicUserData(completionHandler: CompletionHandler) {
        let request = URLRequest(url: udacityURL(method: UdacityClient.Constants.methods.user, withPathExtension: "/\(userKey!)"))
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: Error) {
                print(error.localizedDescription)
                self.performOnMain(completionHandler, success: false, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let error = NSError(domain: "getPublicUserData", code: 1, userInfo: [NSLocalizedDescriptionKey : "There was an error with your request"])
                sendError(error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                let error = NSError(domain: "getPublicUserData", code: 2, userInfo: [NSLocalizedDescriptionKey : "Your request returned a status code other than 2xx!"])
                sendError(error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let newData = data?.subdata(in: 5..<(data?.count ?? 0)) else {
                let error = NSError(domain: "getPublicUserData", code: 2, userInfo: [NSLocalizedDescriptionKey : "No data was returned by the request!"])
                sendError(error)
                return
            }
            
            let parsedResult: [String: AnyObject]
            do { parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]}
            catch {
                let error = NSError(domain: "getPublicUserData", code: 2, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                sendError(error)
                return
            }

            self.user = UdacityUser(parameters: parsedResult)
            self.performOnMain(completionHandler, success: true, error: nil)

        }
        task.resume()
    }
    
    private func performOnMain(_ completionHandler: CompletionHandler, success: Bool, error: Error?) {
        DispatchQueue.main.async {
            if let completionHandler = completionHandler {
                completionHandler(success, error)
            }
        }
    }

    private func udacityURL(method: String, withPathExtension: String? = nil) -> URL {
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + method + (withPathExtension ?? "")
        return components.url!
    }

    //MARK: Singleton methods

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

extension String{
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
