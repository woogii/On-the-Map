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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func logoutInListView(sender: AnyObject) {
        
        UdacityClient.sharedInstance().deleteSession() {  success , errorString in
            
            if success {
                
                let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("loginViewController")
                self.presentViewController(loginViewController!, animated: true, completion: nil)
                
                
            } else {
                print(errorString)
            }
        }
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
        cell.imageView!.image = UIImage(named: "pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
            
        return cell
     }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentInfo.count
    }

    

}