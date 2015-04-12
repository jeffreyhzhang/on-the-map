//
//  SearchStudent.swift
//  OnTheMap
//
//  Search by LastName (Exact macth)
//  As soon as a match is found during the lastname input, the results will show.
//  
//  Credit:  Jarrod Parkes's work in Udacity moviemanager project
//
//  Created by JeffreyZhang on 4/8/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation
import UIKit


class SearchStudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var studentSearchBar: UISearchBar!
    @IBOutlet weak var ReminderMsg: UILabel!
    
    let myDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let formatter = NSDateFormatter()
    // The data for the table
    var students = [StudentInformation]()
    
    // The most recent data download task. We keep a reference to it so that it can
    // be canceled every time the search text changes
    var searchTask: NSURLSessionDataTask?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        /* Configure tap recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        // let user know what to do
        studentSearchBar.text = "Search by LastName"
        studentSearchBar.delegate = self
        
        ReminderMsg.alpha = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
 
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = false

    }
    
    
    // MARK: - Dismiss Keyboard
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.studentSearchBar.isFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
 

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        studentSearchBar.text = ""
        return true
    }
    
    /* Each time the search text changes we want to cancel any current download and start a new one */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        /* Cancel the last task */
        if let task = searchTask? {
            task.cancel()
        }
        
        /* If the text is empty we are done */
        if searchText == "" {
            students = [StudentInformation]()
            studentTableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        /* New search by last Name ...case sensitive*/

        /* FIX: Replace spaces with '+' */
        var escapedString = searchText.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        
        searchTask = WebUtilities.sharedInstance().getStudentsForLastName(escapedString!, completionHandler: { (students, error) -> Void in
            self.searchTask = nil
            if let students = students? {
                self.students = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.self.ReminderMsg.alpha = 0
                    self.self.studentTableView!.reloadData()
                }
            }
        })

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellReuseId = "TableCell"
        let student = students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell
        
        let updatedString = formatter.stringFromDate(student.updatedAt)
        
        cell.textLabel!.text =  student.lastName! + " , " + student.firstName! + " ( updatedat: " +  updatedString + ")"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = myDelegate.LocImg //alway the loc image
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.textLabel?.font =  UIFont(name: "HelveticaNeue-CondensedBlack", size: 16)!
        Utilities.AutoSizeLabelField(cell.textLabel!, minScaleFactor: 0.3)

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !Utilities.isConnectedToNetwork() {
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }
        
        let itm :StudentInformation =  students[indexPath.row]
        if let targetURL = itm.mediaURL?   {
            if Utilities.isNetworkAvialable(targetURL) {
                UIApplication.sharedApplication().openURL( NSURL(string: targetURL)!)
            } else {
                Utilities.showAlert(self, title: "Error", message: targetURL + " is invalid")
            }
        } else {
            Utilities.showAlert(self, title: "Error", message: "No URL")
        }
    }
    
    
    func cancel() {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
