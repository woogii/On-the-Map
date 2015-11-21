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
    var lastName: String? = nil
    var firstName: String? = nil
    var fullName: String?
    
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
    
    
    func getUserData( userID:String, completionHandler: (success:Bool, errorString:String?)->Void) {
        print(userID)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)
        request.HTTPMethod = "GET"
        
        taskForGETMethod(request) {  (JSONResult, error) in
            
            if let err = error {  
                print(err)
                completionHandler(success:false, errorString:"Fetch Failed(Network error)")
            } else {
                
                if let result = JSONResult.valueForKey("user") as? NSDictionary    {
                
                    if let last_name = result.valueForKey("last_name") as? String {
                        self.lastName = last_name
                        if let first_name = result.valueForKey("first_name") as? String{
                            self.firstName = first_name
                            self.fullName = "\(self.firstName!)\(self.lastName!)"
                            completionHandler( success: true, errorString:nil)
                        }
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
    
    func postLoginSession (username:String, password:String, completionHandler : (success:Bool, userID:String?, errorString:String?)-> Void)  {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskForPOSTMethod(request) { JSONResult , error in
            
            if let err = error {
                print(err)
                completionHandler(success: false, userID: nil, errorString: "The Internet connection appears to be offline")
            } else {
                
                if let accountInfo = JSONResult["account"] as? NSDictionary {
                    
                    if let userID = accountInfo["key"] as? String {
                        
                        completionHandler(success: true, userID: userID, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, userID: nil, errorString: "Invalid Email or Password") 
                }
            }
            
        }
    }
    
    func deleteSession( completionHandler:(success : Bool, errorString:String?)->Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value , forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        
        taskForPOSTMethod(request) {  JSONResult, error in
            
            if let err = error {
                print(err)
            } else {
            
                if let result = JSONResult["session"] as? NSDictionary {
                
                    if let userID = result["id"] as? String {
                        print(userID)
                        completionHandler( success: true, errorString: nil)
                    }
                
                } else {
                    completionHandler(success: false, errorString: "Error occured while logout")
                }
            
            }
        }
    }


    func taskForPOSTMethod (request:NSMutableURLRequest, completionHandler: (result:AnyObject!, error:NSError?)->Void)->NSURLSessionDataTask? {
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            if (error == nil) {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            } else {
                completionHandler( result: nil, error:error)
            }
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

    class func sharedInstance()->UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}

