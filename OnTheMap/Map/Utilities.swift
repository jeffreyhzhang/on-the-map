//
//  Utilities.swift
//  OnTheMap
//
//
//  I put some common utility func here so every viewcontroller can use
//
//
//  Basedon my Meme Projetcs
//  and http://stackoverflow.com/questions/24516748/check-network-status-in-swift
//
//  Created by Jeffrey Zhang on 3/28/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation
import UIKit;
import SystemConfiguration


public class Utilities {
    
    
    class var  isLandscapeOrientation : Bool {
        get {
            return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
        }
    }
     
    class func toggleDeviceOrientation(){
        if( isLandscapeOrientation) {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.LandscapeRight.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    }
    
    // MARK
    // get device keyboard height to shift up for bottom text field
    class func getkeyboardHeight(notification:  NSNotification) ->CGFloat{
        
        let userinfo=notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameEndUserInfoKey] as NSValue
        //add padding since text is not really at top or bottom
        return keyboardSize.CGRectValue().height - 15.00
    }
    
    class func AutoSizeTextField(textField: UITextField, minFontsize: CGFloat) {
        //set upper case
        textField.text =  textField.text.uppercaseString
        textField.backgroundColor = UIColor.clearColor()
        //auto shrink to fit textfield
        textField.minimumFontSize = minFontsize
        textField.adjustsFontSizeToFitWidth = true
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }
    
    class func AutoSizeLabelField(lblField: UILabel, minScaleFactor : CGFloat) {
        //auto shrink to fit textfield
        lblField.minimumScaleFactor = minScaleFactor
        lblField.adjustsFontSizeToFitWidth = true
        lblField.setNeedsLayout()
        lblField.layoutIfNeeded()
    }
    
    //generic alert...with callback function when OK'd
    class func showAlert( who : UIViewController, title: String, message : String) {
        let myAlert = UIAlertController()
        myAlert.title = title
        myAlert.message = message
    
        let myaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            //you do some extra here after OK'd
              let filteredSubviews = who.view.subviews.filter({
                $0.isKindOfClass(UITextView) })
            for view in filteredSubviews  {
                var mytxtinput = view as UITextView
                if mytxtinput.text.rangeOfString("Searching address") != nil{
                    mytxtinput.text = ""
                }
            }
        })
            
        myAlert.addAction(myaction)
        who.presentViewController(myAlert, animated:true , completion:nil)
    }
    
    //load LocImg...used for tablecell image
    init(){
     }
 
     
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
    // another way to check...try to get to google.com
    // since google is the most reliable site there is
    // if you cannot get to it...then network issue.
    //
    class func isNetworkAvialable(urlforTest: String?)->Bool{
        
        var Status:Bool = false
        var myurl =  urlforTest!.isEmpty ? "http://google.com/" : urlforTest!
        let url = NSURL(string: myurl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}