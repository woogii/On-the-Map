//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 16..
//  Copyright © 2015년 wook2. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
    var session : NSURLSession
    
    let baseURLSecure :String = "https://www.udacity.com/api/"
    var sessionID : String? = nil
    var userID: String? = nil
    
    let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func processAuthentication(username:String, password:String,
        completionHandler:(success:Bool, erroString:String?)->Void) {
        
        self.postLoginSession(username, password: password) { (success, userID, errorString) in
            
            if success {
                self.userID = userID
                
                self.getUserData(userID!) { (success, errorString) in

                    completionHandler(success: success, erroString: errorString)
                }
            } else {
                completionHandler(success: success, erroString: errorString)
            }
        }
    }
    
    func postLoginSession (username:String, password:String, completionHandler : (success:Bool, userID:String?, errorString:String?)-> Void)  {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
              
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskForPOSTMethod(request) { JSONResult , error in
            
            if let err = error {
                print(err)
                completionHandler(success: false, userID: nil, errorString: "Login Failed(Create Session)")
            } else {
                
                if let accountInfo = JSONResult["account"] as? NSDictionary {
                    
                    if let userID = accountInfo["key"] as? String {
                    
                        completionHandler(success: true, userID: userID, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, userID: nil, errorString: "Login Failed(Create Session")
                }
            }
            
        }
    }
    
    func getUserData( userID:String, completionHandler: (success:Bool, errorString:String?)->Void) {
        print(userID)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)
        request.HTTPMethod = "GET"
        
        taskForGETMethod(request) {  (JSONResult, error) in
            
            if let err = error { // Handle error...
                print(err)
                completionHandler(success:false, errorString:"Fetch Failed(Network error)")
            } else {
                
                if let result = JSONResult.valueForKey("user") as? NSDictionary    {
                    print(result)
                    if let last_name = result.valueForKey("last_name") as? String {
                        print(last_name)
                        completionHandler( success: true, errorString:nil)
                    }
                
                } else {
                    completionHandler(success: false, errorString: "Login Error")
                }
            }
            
        }
    }
    

    
    // MARK: GET
    
    func taskForGETMethod(request:NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
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
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    func taskForPOSTMethod (request:NSMutableURLRequest, completionHandler: (result:AnyObject!, error:NSError?)->Void)->NSURLSessionDataTask? {
        
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
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

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

    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
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
    
    class func sharedInstance()->UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}

extension UdacityClient {
    
    
//    
//    func postForSessionId(username: String, password: String, completionHandler: (result: Int?, error: NSError?) -> Void)  {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [
//            "username" : username,
//            "password" : password
//        ]
//        
//        var mutableMethod : String = "api/session"
//        
//        let jsonBody : [String:AnyObject] = [
//            "server": "udacity",
//            "username": username,
//            "password": password,
//        ]
//        
//        /* 2. Make the request */
//        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                if let results = JSONResult["account"] as? Int {
//                    print(results)
//                    completionHandler(result: results, error: nil)
//                } else {
//                    completionHandler(result: nil, error: NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
//                }
//            }
//        }
//    }

}