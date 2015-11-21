//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 17..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit
import MapKit


class StudentMapViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000.0
    var activityIndicator: UIActivityIndicatorView? = nil
   
    var annotations = [MKAnnotation]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.startAnimating()
        })

        ParseClient.sharedInstance().getStudentInfo() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {
    
                for student in studentInfo {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = student.coordinate
                    annotation.title = "\(student.firstName)\(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    self.annotations.append(annotation)
                }
                
                // Adding map annotation in the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator!.stopAnimating()
                    self.mapView.addAnnotations(self.annotations)
                })
            }
            else {
                print(errorString)
                
                dispatch_async(dispatch_get_main_queue(), {
                    let alertView = UIAlertController(title:"", message: errorString?.localizedDescription, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .White)        
        activityIndicator!.frame = CGRectMake(0,0,50,50)
        activityIndicator!.layer.cornerRadius = 5
        activityIndicator!.center = view.center
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.addSubview(activityIndicator!)
    }
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        
        UdacityClient.sharedInstance().deleteSession() {  success , errorString in
            
            if success {
                // If implementing 'dismissViewControllerAnimated' function without dispatch_async block, an error occurs with the following message
                // 'This application is modifying the autolayout engine from a background thread, which can lead to engine corruption and weird crashes.  This will cause an exception in a future release.'
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                print(errorString)
            }
            
        }
    }
    
    @IBAction func refreshButtonClicked(sender: UIBarButtonItem) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.startAnimating()
        })
        
        ParseClient.sharedInstance().getStudentInfo() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {
            
                for student in studentInfo {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = student.coordinate
                    annotation.title = "\(student.firstName)\(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    self.annotations.append(annotation)
                }
                
                // Adding map annotation in the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator!.stopAnimating()
                    self.mapView.addAnnotations(self.annotations)
                })
            }
            else {
                print(errorString)
            }
        }
        
    }
    
    
    @IBAction func pinButtonClicked(sender: AnyObject) {
        
        let currentUserName = UdacityClient.sharedInstance().fullName
        
        if currentUserName != nil {
            
            let alertView = UIAlertController(title: nil, message: "User \"\(currentUserName!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: .Alert)
            
            let OverWriteAction = UIAlertAction(title: "Overwrite", style: .Default , handler:overWriteStudentInfo)
            let CancelAction    = UIAlertAction(title: "Cancel", style: .Default, handler:nil)
            
            alertView.addAction(OverWriteAction)
            alertView.addAction(CancelAction)
                
            presentViewController(alertView, animated: true, completion: nil)
            
        } else {
            self.performSegueWithIdentifier("moveFromMapView", sender: nil)
        }
    }
    
    func overWriteStudentInfo(alertAction: UIAlertAction!) -> Void {
        self.performSegueWithIdentifier("moveFromMapView", sender: nil)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.calloutOffset = CGPoint(x: -5, y :-5)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
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