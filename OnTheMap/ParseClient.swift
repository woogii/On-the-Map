//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 17..
//  Copyright © 2015년 wook2. All rights reserved.
//

import Foundation

// MARK : -  UdacityClient : NSObject

class ParseClient : NSObject {

    
    // MARK : - Properties 
    
    var session : NSURLSession
    var studentInfo = [StudentInfo]()
    var objectId :String? = nil
    
    let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let parseApplicationIDHeader =  "X-Parse-Application-Id"
    let restApiKeyHeader = "X-Parse-REST-API-Key"
    
    // MARK : - Init Method 
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK : - GET Methods
    
    func getStudentLocation(completionHandler:(result:[StudentInfo]?, errorString: NSError?)->Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt")!)
        
        request.addValue(parseApplicationID, forHTTPHeaderField: parseApplicationIDHeader)
        request.addValue(restApiKey, forHTTPHeaderField: restApiKeyHeader)
        
        
        parseTaskForGETMethod(request) { (JSONResult, error) in
        
            if let error = error {
                completionHandler(result: nil, errorString: error)
            }
            else {
                if let results = JSONResult["results"] as? [[String:AnyObject]] {
                    //print(results)
                    let studentInfo = StudentInfo.studentInfoFromResults(results)
                   
                    completionHandler(result: studentInfo, errorString: nil)
                }
                else {
                    completionHandler(result: nil, errorString: NSError(domain: "getStudentInfo parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not download studentInfo"]))
                }
            }
        }
    }
    
    func queryStudentLocation(completionHandler:(studentName:String?, errorString: NSError?)->Void )  {
        
        
        let baseSecureURL = "https://api.parse.com/1/classes/StudentLocation"
        let parameters = [
                "where" : "{\"uniqueKey\":\"\(UdacityClient.sharedInstance().userID!)\"}"
        ]
        print(UdacityClient.sharedInstance().userID)
        let urlString = baseSecureURL + escapedParameters(parameters)
        
        print(urlString)
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.addValue(parseApplicationID, forHTTPHeaderField: parseApplicationIDHeader)
        request.addValue(restApiKey, forHTTPHeaderField: restApiKeyHeader)
        

        parseTaskForGETMethod(request) { (JSONResult, error) in
            
            if let error = error {
                print(error)
                completionHandler(studentName: nil, errorString: error)
            }
            else {
                
                if let result = JSONResult["results"] as? [NSDictionary] {
                    self.objectId = result[0].valueForKey("objectId") as? String
                    let firstName = result[0].valueForKey("firstName") as? String
                    let lastName = result[0].valueForKey("lastName") as? String
                    let fullName = "\(firstName!)\(lastName!)"
                    print(self.objectId)
                    print(fullName) 
                    completionHandler(studentName: fullName , errorString: nil)
                }
                else {
                    print("no result")
                    completionHandler(studentName: nil, errorString: NSError(domain: "getStudentInfo parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not download studentInfo"]))
                }
            }
        }
    }
    
    func parseTaskForGETMethod(request:NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    

    // MARK : - POST Methods 
    
    func postStudentLocation (latitude: String?, longitude: String?, mediaURL:String?, mapString:String?, completionHandler : (success:Bool, errorString:String?)-> Void)  {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        
        request.addValue(parseApplicationID, forHTTPHeaderField: parseApplicationIDHeader)
        request.addValue(restApiKey, forHTTPHeaderField: restApiKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().userID!)\", \"firstName\": \"\(UdacityClient.sharedInstance().firstName!)\", \"lastName\": \"\(UdacityClient.sharedInstance().lastName!)\",\"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(latitude!), \"longitude\": \(longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        parseTaskForPOSTMethod(request) { JSONResult , error in
            
            if let err = error {
                print(err)
                completionHandler(success: false, errorString: "Fail to send a link. Please try again.")
            } else {
                print(JSONResult)
                
                if let createdAt = JSONResult["createdAt"] {
                    print(createdAt)
                }
                print("success")
                completionHandler(success: true, errorString: nil)
            }
        }
        
    }
    
    func parseTaskForPOSTMethod (request:NSMutableURLRequest, completionHandler: (result:AnyObject!, error:NSError?)->Void)->NSURLSessionDataTask? {
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
        
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK : - PUT Method
    
    func updateStudentLocation (latitude: String?, longitude: String?, mediaURL:String?, mapString:String?, completionHandler : (success:Bool, errorString:String?)-> Void)  {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation/\(objectId!)")!)
        request.HTTPMethod = "PUT"
        
        request.addValue(parseApplicationID, forHTTPHeaderField: parseApplicationIDHeader)
        request.addValue(restApiKey, forHTTPHeaderField: restApiKeyHeader)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().userID!)\", \"firstName\": \"\(UdacityClient.sharedInstance().firstName!)\", \"lastName\": \"\(UdacityClient.sharedInstance().lastName!)\",\"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(latitude!), \"longitude\": \(longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        parseTaskForPOSTMethod(request) { JSONResult , error in
            
            if let err = error {
                print(err)
                completionHandler(success: false, errorString: "Fail to send a link. Please try again.")
            } else {
                print(JSONResult)
                
                if let updatedAt = JSONResult["updatedAt"] {
                    print(updatedAt)
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        
    }

    
    // MARK: - Parsing JSON
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
     // MARK: - Escaping URL
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    
    // MARK: - Shared Instance
    
    class func sharedInstance()->ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
