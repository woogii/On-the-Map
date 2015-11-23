//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 19..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit
import MapKit

// MARK: - InformationPostingViewController: UIViewController
class InformationPostingViewController : UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var inputLinkTextView: UITextView!
    
    @IBOutlet weak var inputLocationTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    var tapRecognizer:UITapGestureRecognizer? = nil
    var coordinates: CLLocationCoordinate2D? = nil
    var activityIndicator: UIActivityIndicatorView!
        
    let regionRadius:CLLocationDistance = 1000.0

    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.addGestureRecognizer(tapRecognizer!)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        inputLinkTextView.hidden = true
        mapView.hidden = true
        submitButton.hidden = true
        
        inputLinkTextView.delegate = self
        inputLocationTextView.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target:self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50)) as UIActivityIndicatorView
        activityIndicator.center = view.center
        activityIndicator.layer.cornerRadius = 5
        activityIndicator.hidesWhenStopped = true
        activityIndicator!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        activityIndicator.activityIndicatorViewStyle = .White
        view.addSubview(activityIndicator!)
        
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer ) {
        view.endEditing(true)
    }
    
    //  This method gets called whenever the user types a new character or deletes an existing character
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false                            //  replacement operation should be aborted
        }
        return true                                 // text should be replaced
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.text = ""
        textView.textAlignment = .Left
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        textView.textAlignment = .Center
        return true
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

extension InformationPostingViewController : MKMapViewDelegate {
    
    @IBAction func findButtonClicked(sender: AnyObject) {
        
        let address = inputLocationTextView.text
        let geocoder = CLGeocoder()
        
        activityIndicator!.startAnimating()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
           
            if( error != nil ){
                
                print("Geocode failed with error: \(error!.localizedDescription)")
                
                self.activityIndicator!.stopAnimating()
                let alertView = UIAlertController(title:"", message:"Couldn't find the location. Please try again.", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
                self.presentViewController(alertView, animated: true, completion: nil)
                return

            } else if placemarks!.count > 0 {
                let placemark = placemarks![0] as CLPlacemark
                let location = placemark.location
                self.coordinates = location?.coordinate
            }
            self.showMap()
        })
        
    }
    
    func showMap() {
      
        inputLinkTextView.hidden = false
        mapView.hidden = false
        submitButton.hidden = false
        
        topLabel.hidden = true
        inputLocationTextView.hidden = true
        findLocationButton.hidden = true
        bottomView.backgroundColor = UIColor(white: 1.0, alpha:0.5)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.coordinates!, regionRadius*2.0, regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinates!
        self.mapView.addAnnotation(annotation)
        
        activityIndicator!.stopAnimating()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }


    
    @IBAction func submitButtonClicked(sender: AnyObject) {
        
        if inputLinkTextView.text == nil {
            let alertView = UIAlertController(title:"", message:"Please enter a link.", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
            self.presentViewController(alertView, animated: true, completion: nil)
            return
        }

        let latitude:String = "\(self.coordinates!.latitude)"
        let longitude:String = "\(self.coordinates!.longitude)"
        
        activityIndicator!.startAnimating()
        
        ParseClient.sharedInstance().postStudentLocation(latitude,longitude: longitude, mediaURL: inputLinkTextView.text, mapString: inputLocationTextView.text) {
                success, errorString in
            
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue(), {
                
                    let alertView = UIAlertController(title:"", message:"Fail to send a link. Please try again.", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
            } else {
                self.activityIndicator!.stopAnimating()
                self.dismissViewControllerAnimated(true, completion: nil)
            }

            
        }
    
    }
    
}
