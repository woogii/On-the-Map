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
    var tapRecognizer:UITapGestureRecognizer? = nil
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        if  userNameTextField.text != ""  && passwordTextField.text != ""  {
            
            userNameTextField.text = "siwookhyun@gmail.com"

            UdacityClient.sharedInstance().processAuthentication(userNameTextField.text!, password: passwordTextField.text!)  {  (result, error) in
            
                if error == nil {
                    self.completeLogin()
                }
                else {
                    self.displayError(error)
                }
            }
        } else {
            let alertView = UIAlertController(title:"", message:"Empty Email or Password", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        
        }
        
    }
    
    func completeLogin()  {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }

    }

    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertView = UIAlertController(title:"Login Error", message:errorString, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpButtonTouch(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        session = NSURLSession.sharedSession()
        
        tapRecognizer = UITapGestureRecognizer(target:self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func handleSingleTap(recognizer : UITapGestureRecognizer ) {
        self.view.endEditing(true)
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
