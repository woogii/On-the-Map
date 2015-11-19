//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 19..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit
import MapKit


class InformationPostingViewController : UIViewController {
    

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var inputLinkTextView: UITextView!
    
    @IBOutlet weak var inputLocationTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputLinkTextView.hidden = true
        mapView.hidden = true
        submitButton.hidden = true
    }
    
    
}
