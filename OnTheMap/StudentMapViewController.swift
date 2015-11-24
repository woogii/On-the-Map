//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 17..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

// MARK: - StudentMapViewController: UIViewController, MKMapViewDelegate

class StudentMapViewController : UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000.0
    var activityIndicator: UIActivityIndicatorView? = nil
   
    // MARK: - Life Cycle 
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.startAnimating()
        })
        
        if (mapView.annotations.count != 0) {
            print(mapView.annotations.count)
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
        }
        
        ParseClient.sharedInstance().getStudentLocation() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {
                var annotations = [MKPointAnnotation]()

                for student in studentInfo {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = student.coordinate
                    annotation.title = "\(student.firstName)\(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    annotations.append(annotation)
                }
                
                // Adding map annotation in the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator!.stopAnimating()
                    self.mapView.addAnnotations(annotations)
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
    
    // MARK: - UIView Action Methods
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        
        if ( FBSDKAccessToken.currentAccessToken() != nil ) {
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            UdacityClient.sharedInstance().deleteSession() {  success , errorString in
            
                if success {
                    // Changing UI should occur in the main thread, otherwise it cause an error
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else {
                    print(errorString)
                }
            
            }
        }
    }
    
    @IBAction func refreshButtonClicked(sender: UIBarButtonItem) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.startAnimating()
        })
        
        ParseClient.sharedInstance().getStudentLocation() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {

                var annotations = [MKPointAnnotation]()
                
                for student in studentInfo {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = student.coordinate
                    annotation.title = "\(student.firstName)\(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    annotations.append(annotation)
                }
                
                // Adding map annotation in the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator!.stopAnimating()
                    self.mapView.addAnnotations(annotations)
                })
            }
            else {
                print(errorString)
            }
        }
        
    }
    
    
    @IBAction func pinButtonClicked(sender: AnyObject) {
        
        // Send a query to check whether there is only one annotation associated with the current user 
        ParseClient.sharedInstance().queryStudentLocation() { (studentName, errorString) in
            
            if let _ = studentName {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                let alertView = UIAlertController(title: nil, message: "User \"\(studentName!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: .Alert)
                
                let OverWriteAction = UIAlertAction(title: "Overwrite", style: .Default , handler:self.overWriteStudentInfo)
                let CancelAction    = UIAlertAction(title: "Cancel", style: .Default, handler:nil)
                
                alertView.addAction(OverWriteAction)
                alertView.addAction(CancelAction)
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                    
                
            }
            else {
                 dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("moveFromMapView", sender: nil)
                })
            }
        }

    }
    
    // MARK: - Custom Function
    func overWriteStudentInfo(alertAction: UIAlertAction!) -> Void {
        self.performSegueWithIdentifier("moveFromMapView", sender: nil)
    }
    
    // MARK: - MKMapView Delegate Method
    
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