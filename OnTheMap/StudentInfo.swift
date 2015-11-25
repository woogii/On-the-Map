//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 18..
//  Copyright © 2015년 wook2. All rights reserved.
//

import Foundation
import MapKit
import Contacts

// MARK: - StudentInfo : NSObject, MKAnnotation 

struct StudentInfo {

    // MARK : - Properties 
    
    let title : String?
    let mediaURL: String
    let coordinate : CLLocationCoordinate2D
    let lastName : String
    let firstName : String
    
    // MARK : - Init Method
    
    init(dictionary: [String:AnyObject]){
        lastName = dictionary["lastName"] as! String
        firstName  = dictionary["firstName"] as! String
        let latitude = dictionary["latitude"] as! Double
        let longitude = dictionary["longitude"] as! Double
        mediaURL  = dictionary["mediaURL"] as! String
        title = lastName + firstName
        coordinate = CLLocationCoordinate2D(latitude : latitude, longitude: longitude )
        
    }
    
    // MARK : - Custom Static Function
    
    static func studentInfoFromResults(results:[[String: AnyObject]])->[StudentInfo] {
        var studentInfo = [StudentInfo]()
    
        for result in results {
            studentInfo.append(StudentInfo(dictionary:result))
        }
        return studentInfo
    }
}
