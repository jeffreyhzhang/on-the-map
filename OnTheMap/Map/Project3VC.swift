//
//  Project3VC.swift
//  OnTheMap
//
//  This base VC will be used by both Table and Map tab
//  to save some duplication like create two button on navigation bar
//  and the action when add a new student
//
//  Created by JeffreyLee on 4/9/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import UIKit

class Project3VC : UIViewController {
    
    // MARK: two buttons on navigation bar
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnAdd =  UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Add, target: self, action: "AddNew")
        self.navigationItem.leftBarButtonItem = btnAdd
        
        let btnRefresh =  UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Refresh, target: self, action: "Refresh")
        self.navigationItem.rightBarButtonItem = btnRefresh
        
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    
    
    // MARK: navigate to post myself  on Map
    
    func AddNew(){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var newVC = mainStoryboard.instantiateViewControllerWithIdentifier("AddStudentOnMap") as  UINavigationController
        
        //grod off extra tab bar at bottom when go to post
        self.hidesBottomBarWhenPushed = true;
        self.presentViewController(newVC, animated: true, completion: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
}
