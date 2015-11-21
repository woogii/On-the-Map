//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 15..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit


class LoginViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginBackgroundImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var session: NSURLSession!
    var tapRecognizer:UITapGestureRecognizer? = nil
    var activityIndicator: UIActivityIndicatorView? = nil
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = NSURLSession.sharedSession()
        
        tapRecognizer = UITapGestureRecognizer(target:self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50)) as UIActivityIndicatorView
        activityIndicator!.center = view.center
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle = .White
        view.addSubview(activityIndicator!)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
    }

    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        activityIndicator!.startAnimating()
        
        if  userNameTextField.text != ""  && passwordTextField.text != ""  {
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
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.stopAnimating()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })

    }

    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertView = UIAlertController(title:"Login Error", message:errorString, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title:"Dismiss", style:.Default, handler:nil))
            self.presentViewController(alertView, animated: true, completion: nil)
            self.activityIndicator!.stopAnimating()
        })
    }
    
    @IBAction func signUpButtonTouch(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }

    
    func handleSingleTap(recognizer : UITapGestureRecognizer ) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
