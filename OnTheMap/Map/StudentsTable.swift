//
//  StudentsTable.swift
//  OnTheMap
//
//  Retrieve Students from API and load to table
//  Provide add new and refresh button on navigation toolbar at top
//
//  1. Check network availability before doing the retrieval.
//  2. limit to 100 students
//  3. Display students in descending order of updatedAt timestamp
//  4. Customized navigation button ( add new and refresh ) from customized viewcontroller Project3VC
//
//  Created by JeffreyZhang on 4/3/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation
import UIKit

class StudentsTable: Project3VC, UITableViewDataSource, UITableViewDelegate {
 
    var myDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var backgroundGradient: CAGradientLayer? = nil
    @IBOutlet weak var studentsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         Refresh()
    }
    
    /* refresh table...checking network connectivity */
    func Refresh(){
        
        if(!Utilities.isConnectedToNetwork() ){
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }
        
        WebUtilities.sharedInstance().getStudentLocs ({ last100Students, error in
            if let error = error? {
                var errorMsg = error.localizedDescription
                Utilities.showAlert(self, title: "error", message: errorMsg)
            }
            //sort by updatedAt
            if let last100Students = last100Students? {
                //share the data with Map
                WebUtilities.sharedInstance().last100Students = last100Students
                //must put in main thread to work
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentsTableView.reloadData()
                }
            } else {
                println(error)
            }
        } )

    }


    // MARK: Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  WebUtilities.sharedInstance().last100Students.count
    }
    
    // MARK: populate each row/cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let itm :StudentInformation = WebUtilities.sharedInstance().last100Students[indexPath.row]
        
        // use default UITableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("tabCell") as  UITableViewCell
        cell.textLabel?.text = itm.lastName!  + "," + itm.firstName!
        cell.detailTextLabel?.text = itm.mediaURL
        cell.imageView?.image = myDelegate.LocImg //alway the loc image
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cell.textLabel?.font =  UIFont(name: "HelveticaNeue-CondensedBlack", size: 16)!
        Utilities.AutoSizeLabelField(cell.textLabel!, minScaleFactor: 0.3)
        
        return cell
    }
    
    // MARK: When row selected, fire browser to open link.
    /*  ..warning: the url maybe invalid , network maybe not avail*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        if !Utilities.isConnectedToNetwork() {
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }
        
        let itm :StudentInformation =  WebUtilities.sharedInstance().last100Students[indexPath.row]
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
    //cutomized height
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    */
}

