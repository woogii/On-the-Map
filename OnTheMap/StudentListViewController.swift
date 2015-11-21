//
//  StudentListViewController.swift
//  OnTheMap
//
//  Created by Hyun on 2015. 11. 18..
//  Copyright © 2015년 wook2. All rights reserved.
//

import UIKit

class StudentListViewController : UIViewController {
    
    @IBOutlet weak var studentsTableView: UITableView!
    var activityIndicator:UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .White)
        activityIndicator.frame = CGRectMake(0,0,50,50)
        activityIndicator.layer.cornerRadius = 5
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.addSubview(activityIndicator!)

    }
    
    override func viewWillAppear(animated:Bool)
    {
        super.viewWillAppear(animated)
        
        ParseClient.sharedInstance().getStudentInfo() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {
                ParseClient.sharedInstance().studentInfo = studentInfo
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                }
            }
            else {
                print(errorString)
            }
        }
    }

    @IBAction func refreshButtonClicked(sender: AnyObject) {
        activityIndicator.startAnimating()
        
        ParseClient.sharedInstance().getStudentInfo() { (studentInfo, errorString) in
            
            if let studentInfo = studentInfo {
                ParseClient.sharedInstance().studentInfo = studentInfo
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.studentsTableView.reloadData()
                }
            }
            else {
                print(errorString)
            }
        }
        
    }
    
    @IBAction func logoutButtonClicked(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
        
        UdacityClient.sharedInstance().deleteSession() {  success , errorString in
            
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                print(errorString)
            }
        }
    }
    
    @IBAction func pinButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("moveFromListView", sender: nil)
    }
        
}

extension StudentListViewController : UITableViewDelegate, UITableViewDataSource{
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        /* Get cell type */
        let cellReuseIdentifier = "StudentListViewCell"
        let student = ParseClient.sharedInstance().studentInfo[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(student.firstName)\(student.lastName)"
        cell.detailTextLabel!.text = student.mediaURL
        cell.imageView!.image = UIImage(named: "pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
           
        return cell
     }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentInfo.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = ParseClient.sharedInstance().studentInfo[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string:student.mediaURL)!)
        
    }


}