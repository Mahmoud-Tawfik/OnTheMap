//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import UIKit
import MapKit

class MapViewController: MapTypeViewController, MKMapViewDelegate {

    //MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: View Lifecycle methods
    
    override func viewDidLoad() {
        reloadBlock = {self.updateMapAnnotations()}
        super.viewDidLoad()
    }

    //MARK: Update Map methods
    
    func updateMapAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        for student in Parse.students {
            let location = CLLocationCoordinate2DMake(student.latitude, student.longitude)
            let pin = MKPointAnnotation()
            pin.coordinate = location
            pin.title = student.fullName
            pin.subtitle = student.mediaURL

            mapView.addAnnotation(pin)
        }
    }

    //MARK: MKMapViewDelegate methods

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
        }
        
        let button = UIButton(type: .detailDisclosure)
        pinView?.rightCalloutAccessoryView = button
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let url = URL(string: (view.annotation!.subtitle!)!){
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
            }
        }
    }
}
