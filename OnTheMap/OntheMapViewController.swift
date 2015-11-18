//
//  OntheMapViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 17..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit
import MapKit


class OntheMapViewController : UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000.0 
   
    var annotations = [MKAnnotation]()

    
    func loadInitialData()
    {
        ParseClient.sharedInstance().getStudentInfo() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {
                
                for student in studentInfo {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = student.coordinate
                    annotation.title = "\(student.firstName)\(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    self.annotations.append(annotation)
                }
                
                self.mapView.addAnnotations(self.annotations)
            }
            else {
                print(errorString)
            }
            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude:  37.773972, longitude: -122.431297)
        
        _ = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius*2.0, regionRadius*2.0)
        
        loadInitialData()
        // if studentInfo is declared as studentInfo, it results in error
        //mapView.addAnnotations(studentInfo)
        mapView.delegate = self
    }
    
}

extension OntheMapViewController : MKMapViewDelegate {
    

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let identifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView?
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView!.calloutOffset = CGPoint(x: -5, y :-5)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser 
    // to the URL URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control:UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string:toOpen)!)
            }
        }
    }
    
}