//
//  MapTypeViewController.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/13/16.
//
//

import UIKit

class MapTypeViewController: UIViewController {

    //MARK: Variables
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var student: Student?
    var reloadBlock: (() -> Void)?

    //MARK: IBActions
    
    @IBAction func PostMyPin() {
        loadingIndicator.startAnimating()
        Parse.loadStudentWith(uniqueKey: Udacity.userKey) { (result, error) in
            self.loadingIndicator.stopAnimating()
            if let userData = result?["results"] as? [[String: AnyObject]], userData.count > 0 {
                
                self.student = Student(parameters: userData[0])
                let alert = UIAlertController(title: "", message: "You have already posted a student location. Whould you like to overwrite it?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: {_ in
                    self.performSegue(withIdentifier: "Post My Pin", sender: self)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "Post My Pin", sender: self)
            }
        }
    }

    @IBAction func reloadData() {
        loadingIndicator.startAnimating()
        Parse.loadStudents{(result, error) in
            guard error == nil else {
                self.showAlert(parameters: ["message":Constants.Alert.NoNetwork])
                return
            }
            if let reloadBlock = self.reloadBlock{
                reloadBlock()
            }
            self.loadingIndicator.stopAnimating()
        }
    }

    @IBAction func logout(_ sender: AnyObject) {
        Udacity.logout { (success, errorr) in
            self.dismiss(animated: true, completion: nil)
        }
    }

    //MARK: View Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        if ParseStudents.students.isEmpty{
            reloadData()
        }
    }
    
    //MARK: Show Alert method
    func showAlert(parameters: [String: String]) {
        let alert = UIAlertController(title: parameters["title"],
                                      message: parameters["message"],
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: parameters["action"] ?? "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Post My Pin" {
            if let destination = segue.destination as? PinViewController{
                destination.student = student
            }
        }
     }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        reloadData()
    }

}
