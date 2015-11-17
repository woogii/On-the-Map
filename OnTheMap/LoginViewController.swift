//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 15..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit


class LoginViewController : UIViewController {
    
    @IBOutlet weak var loginBackgroundImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var session: NSURLSession!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        userNameTextField.text = "siwookhyun@gmail.com"

        UdacityClient.sharedInstance().processAuthentication(userNameTextField.text!, password: passwordTextField.text!)  {  (result, error) in
            
            if let err = error {
                print(err)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                    
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func signUpButtonTouch(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        session = NSURLSession.sharedSession()
    }
        
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

    
    
}
