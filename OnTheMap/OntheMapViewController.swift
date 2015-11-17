//
//  OntheMapViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 17..
//  Copyright © 2015년 wook2. All rights reserved.
//

import Foundation
import MapKit


class OntheMapViewController : UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    
}