//
//  PostStudentonMap.swift
//  OnTheMap
//
//  Add student on Map  ( update if already there to avoid duplicates)
//  All UI componenets are created dynmaically for easy handling
//
//  1. set up keyboard events handler, so we can set text when editing
//  2. create all UI components in code ( none in storyboard)
//  3. hanle textview in a special way to show different style
//  4. Once address is key-in, pin on map...check invaid address
//  5. Once valid URL are done, validate URL by checking request header. enable "POST" only if it is valid
//
//  Created by JeffreyZhang on 4/5/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import AddressBook

class PostStudentonMap  : UIViewController, CLLocationManagerDelegate, UITextViewDelegate {
  
        var coords: CLLocationCoordinate2D!
        var MyMap: MKMapView!
        var hello: UITextView!
        var Promptaddress: UITextView!
        var mediaURL: UITextView!
        var findmeBtn: UIButton!
        var tapRecognizer: UITapGestureRecognizer? = nil
        var activityIndicator: UIActivityIndicatorView!
    
    
    
       let Addressprompt: String = "Your address here and hit Return when done"
       let mediaUrlPrompt : String = "Your URL here and hit Return when done"
    
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            
            /* Add tap recognizer to dismiss keyboard */
            self.addKeyboardDismissRecognizer()
            
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            
            configNav()
            
            configViewColor()

            tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
            tapRecognizer?.numberOfTapsRequired = 1
            
            AddUIItemstoView()

        }
    
        // MARK - AddUIItemstoView
        //  instead of Storyboard and constrains for all devices....do it in code
    
        func AddUIItemstoView(){
        
            ////no self.topLayoutGuide.length here yet...it is available until in viewWillLayoutSubviews..
            let viewBounds : CGRect = self.view.bounds
            let topbarOffset  = self.topLayoutGuide.length > 0.0 ? self.topLayoutGuide.length : 64
            
            var vwWD = CGRectGetWidth(viewBounds)
            let vwHT = CGRectGetHeight(viewBounds)  -   self.topLayoutGuide.length
             
            // yGap is space between two neighbouring UI
            let yGap = CGFloat(20.0)
            var yRunningTotal = topbarOffset + yGap
            
            /*adding prompt */
            var mywidth = CGFloat(180.00)
            var xoffset = 0.5 * ( vwWD - mywidth  )
            hello  = UITextView(frame : CGRectMake(xoffset, yGap, mywidth, 120))
            hello.text = "Where Are You Studying Today?"
            handleTextColor(hello)
            self.view.addSubview(hello)
            
            /*adding address/location textview */
            yRunningTotal +=  120
            Promptaddress = createtextView( CGRectMake(0, yRunningTotal, vwWD, 120),text: Addressprompt , tag: 0)
            self.view.addSubview(Promptaddress)
            
            /*adding btn in the middle of view: 100 px below address textview*/
            xoffset = 0.5 * ( vwWD - 180  )
            yRunningTotal +=   220
            findmeBtn  = UIButton(frame : CGRectMake(xoffset, yRunningTotal, 180, 30))
            findmeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            findmeBtn.setTitle("Find on the Map", forState: UIControlState.Normal)
            findmeBtn.addTarget(self, action: "FindMe:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(findmeBtn)
       
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityIndicator.alpha = 0.0
            activityIndicator.center = CGPointMake(vwWD / 2.0, vwHT / 2.0);
            activityIndicator.hidesWhenStopped = false;
            self.view.addSubview(activityIndicator)
            
            
            
            /*adding Mapview...., not visible first */
            yRunningTotal  =  topbarOffset + 120
            var mapHt = vwHT - yRunningTotal //- 20 // minus toolbar if any
            MyMap = MKMapView(frame: CGRectMake(0, yRunningTotal, vwWD, mapHt))
            //hide map first
            MyMap.alpha = 0
            self.view.addSubview(MyMap)
            

            /*add mediaURL, not visible first */
            mediaURL = createtextView( CGRectMake(0, topbarOffset, vwWD, 120), text: mediaUrlPrompt, tag: 99)
            mediaURL.alpha = 0
            self.view.addSubview(mediaURL)
        }
    
        func createtextView(frame: CGRect,text: String , tag: Int) -> UITextView {
            
            var mytextView = UITextView(frame : frame)
            mytextView.text = text
            mytextView.attributedText =  NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 20.0)!])
            mytextView.backgroundColor = UIColor.brownColor()
            mytextView.textAlignment  = NSTextAlignment.Center
            mytextView.tag = tag
            mytextView.delegate = self
            return mytextView
        }
    
        /* initial state for all UI elements in View */
        func init_UIElementState(){
            
              mediaURL.alpha = 0
              MyMap.alpha = 0
              findmeBtn.hidden = false
              Promptaddress.text  = Addressprompt
              Promptaddress.alpha = 1
              hello.alpha = 1
              self.navigationItem.leftBarButtonItem?.enabled = false
        }
        /*  ready for input mediaURL*/
        func ReadyforMediaURL(){
            
            self.findmeBtn.hidden = true
            self.Promptaddress.alpha = 0
            self.hello.alpha = 0
            self.MyMap.alpha = 1
            self.mediaURL.text  = mediaUrlPrompt
            self.mediaURL.alpha = 1
        }
  
    
        /*  Show Where are you studying today? in a fancy way */
        func handleTextColor( prompt: UITextView ){
            
            var  myMutableString = NSMutableAttributedString(string: prompt.text!, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!])
            
            //Studying
            myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "Chalkduster", size: 18.0)!, range: NSRange(location: 15,length: 8))
            myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "AmericanTypewriter-Bold", size: 14.0)!, range: NSRange(location:1,length:4))
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.brownColor(), range: NSRange(location:1,length:4))
            
            //W from Where
            myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "Georgia", size: 24.0)!, range: NSRange(location: 0, length: 1))
            myMutableString.addAttribute(NSStrokeColorAttributeName, value: UIColor.blueColor(), range:  NSRange(location: 0, length: 1))
            myMutableString.addAttribute(NSStrokeWidthAttributeName, value: 2, range: NSRange(location: 0, length: 1))
            
            //Where
            myMutableString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.greenColor(), range: NSRange(location: 0, length: 5))
            
            //Apply to the label
            prompt.attributedText = myMutableString
            prompt.textAlignment  = NSTextAlignment.Center
            prompt.backgroundColor  = UIColor.clearColor()
            
        }
        
    
        /*  clear address, hide error messsage   */
        func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
            Promptaddress.text = ""
            mediaURL.text = "http://"
            return true
        }
    
        func textView(textView: UITextView!, shouldChangeTextInRange: NSRange, replacementText: NSString!) -> Bool {
                if(replacementText == "\n") {
                    textView.resignFirstResponder()
                    if(textView.tag == 99  && !textView.text.isEmpty){
                        WebUtilities.sharedInstance().ValidateURL(textView.text!, completionHandler: {
                            success , error  in
                            if(success){
                                //enable post
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.navigationItem.leftBarButtonItem?.enabled = true
                                    WebUtilities.sharedInstance().CurrentStudent?.mediaURL = textView.text
                                    println("Valid media URL..." + textView.text)
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    Utilities.showAlert(self, title: "Invalid URL", message: "Please try again.")
                                }
                            }
                        })
                    }
                    return false
                }
                return true
        }
    
        /*  add btn to NavogationBar at top */
        func configNav(){
           // let btn1 =  UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Action, target: self, action: "Post:")
            let btn1 = UIBarButtonItem(title: NSLocalizedString("Post", comment: ""),  style: UIBarButtonItemStyle.Plain, target: self, action: "Post:" )
            let btn2 =  UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .Plain, target: self, action: "Cancel:")
            
            self.navigationItem.leftBarButtonItem = btn1
            self.navigationItem.rightBarButtonItem = btn2
            
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    
        /* Post to Map ...visible after mediaURL is entered */
        func Post(sender : AnyObject){
            
            // studentid is uniquekey
            var uniqkey = WebUtilities.sharedInstance().CurrentStudent?.uniqueKey
  
            if let uniqkey = uniqkey {
                WebUtilities.sharedInstance().CurrentStudent?.longitude = coords.longitude
                WebUtilities.sharedInstance().CurrentStudent?.latitude = coords.latitude
           
                //need name when we login...
                WebUtilities.sharedInstance().getUserFullName(uniqkey){
                     (success, lastname, firstname, errorString) -> Void in
                    if(success) {
                        WebUtilities.sharedInstance().CurrentStudent?.firstName = firstname!
                        WebUtilities.sharedInstance().CurrentStudent?.lastName = lastname!
                        
                        let me = WebUtilities.sharedInstance().CurrentStudent!
                        
                         dispatch_async(dispatch_get_main_queue()) {
                            WebUtilities.sharedInstance().upsertStudentToMap(me) {  (result, error) -> Void in
                                if(result == 0) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                       // Go to Table List
                                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        var navController  = mainStoryboard.instantiateViewControllerWithIdentifier("tabController") as  UITabBarController
                                        navController.hidesBottomBarWhenPushed = false
                                        self.presentViewController(navController, animated: true, completion: nil)
                                    }
                                } else {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        Utilities.showAlert(self, title: "Error", message: "Failed to post to Map")
                                        self.navigationItem.leftBarButtonItem?.enabled = false
                                    }
                                }
                            }
                        }
                    } else {
                       println("Error getting your name from udacity from uniquekey")
                       println(errorString)
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    Utilities.showAlert(self, title: "Error", message: "Failed to post to Map due to invalid uniquekey")
                    self.navigationItem.leftBarButtonItem?.enabled = false
                }

            }
        }
        
        func Cancel(sender : AnyObject){
            //reset to initial state.
            init_UIElementState()
        }
        
    
        /* show address on map */
        func FindMe(sender: AnyObject) {
            
            let addressString = Promptaddress.text
            if( addressString.isEmpty) {
                Utilities.showAlert(self, title: "Invalid Address", message: "Empty address")            }
            
            //showing activity to user
            activityIndicator.startAnimating()
            activityIndicator.alpha = 2.0
            
           //save the address?
            WebUtilities.sharedInstance().CurrentStudent?.mapString = addressString
            
            Promptaddress.text = "Searching address: \n" + addressString
            findmeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(addressString, completionHandler:
                {(placemarks: [AnyObject]!, error: NSError!) in
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0.0
                    
                    if error != nil {
                        println("Geocode failed with error: \(error.localizedDescription)")
                        self.findmeBtn.hidden = false
                        Utilities.showAlert(self, title: "Invalid Address", message: "Tray Again")
                        
                    } else if placemarks.count > 0 {
                        
                        let placemark = placemarks[0] as CLPlacemark
                        let location = placemark.location
                        self.coords = location.coordinate
                        self.showAddressonMap(addressString, myLoc: self.coords!)
                        self.ReadyforMediaURL()
                    }
            })
        }
        
        // MARK: - Keyboard Fixes

        func addKeyboardDismissRecognizer() {
            
            self.view.addGestureRecognizer(tapRecognizer!)
            
        }
    
        
        func removeKeyboardDismissRecognizer() {
            
            self.view.removeGestureRecognizer(tapRecognizer!)
            
        }
        
        
        func handleSingleTap(recognizer: UITapGestureRecognizer) {
            self.view.endEditing(true)
        }
        
        
        func showAddressonMap(address: String, myLoc: CLLocationCoordinate2D){
            //zoom level
            var deltaLong :CLLocationDegrees = 1.0
            var deltaLati :CLLocationDegrees = 1.0
            
            var deltaspan : MKCoordinateSpan =  MKCoordinateSpanMake(deltaLati, deltaLong)
            var region : MKCoordinateRegion = MKCoordinateRegionMake(myLoc, deltaspan)
            
            
            MyMap.mapType = MKMapType.Standard
            MyMap.setRegion(region, animated: true)
            
            //add a pin
            var p = MKPointAnnotation()
            p.title = address
            p.coordinate = myLoc
            MyMap.addAnnotation(p)
            
        }
    
    //this doesn ot seem to work
    func configViewColor(){
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1.00, green: 0.502, blue: 0.00, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.80, green: 0.4, blue: 0.00, alpha: 1.0).CGColor
        var backgroundGradient: CAGradientLayer = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = self.view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }
}

 