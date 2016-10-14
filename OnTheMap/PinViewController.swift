//
//  PinViewController.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import UIKit
import MapKit

class PinViewController: UIViewController {

    //MARK: Variables
    
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var student: Student?
    var newStudent = true

    //MARK: IBOutlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    //MARK: IBActions
    
    @IBAction func findOnTheMap() {
        loadingIndicator.startAnimating()
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            self.loadingIndicator.stopAnimating()
            
            guard let localSearchResponse = localSearchResponse else {
                self.showAlert(parameters: ["message": "Couldn't find your place! Please enter correct place.", "action": "Dismiss"])
                return
            }
            
            self.student?.latitude = localSearchResponse.boundingRegion.center.latitude
            self.student?.longitude = localSearchResponse.boundingRegion.center.longitude
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = self.locationTextField.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse.boundingRegion.center.latitude,
                                                                longitude: localSearchResponse.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.region = MKCoordinateRegion(center: pointAnnotation.coordinate, span: MKCoordinateSpanMake(0.1, 0.1))
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(pinAnnotationView.annotation!)
            
            self.animateView()
        }
        
    }
    
    @IBAction func submit() {
        if let student = student {
            loadingIndicator.startAnimating()
            Parse.updateStudent(student, isNew: newStudent) { (result, error) in
                self.loadingIndicator.stopAnimating()
                if let _ = result?["createdAt"] {
                    self.performSegue(withIdentifier: "unwind", sender: self)
                } else {
                    self.showAlert(parameters: ["message": "There was a problem while posting your request. Try again!", "action": "Dismiss"])
                }
            }
        }
    }

    //MARK: View Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        
        // Create new student object if no old one were found
        if student == nil {
            student = Student(firstName: Udacity.user.firstName,
                              lastName: Udacity.user.lastName,
                              latitude: 0,
                              longitude: 0,
                              mapString: "",
                              mediaURL: "",
                              uniqueKey: Udacity.userKey)
        } else {
            newStudent = false
            locationTextField.text = student!.mapString
            linkTextField.text = student!.mediaURL
        }
    }

    //MARK: animate View methods
    
    func animateView() {
        self.mapConstraint.constant = self.view.frame.height - self.locationTextField.frame.origin.y
        self.linkConstraint.constant = self.locationTextField.frame.origin.y
        self.cancelButton.tintColor = UIColor.white
        self.submitButton.isHidden = false
        
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
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
}

// MARK: PinViewController extension - TextField - Keyboard

extension PinViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case locationTextField:
            student?.mapString = locationTextField.text
            findOnTheMap()
        case linkTextField:
            student?.mediaURL = linkTextField.text
            submit()
        default:
            break
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
