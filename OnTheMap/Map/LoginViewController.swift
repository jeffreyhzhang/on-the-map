//
//  LoginViewController.swift
//  OnTheMap
//
//  This allow uses to login to Udacity
//
//  1. Validating email via simple regex before submitting to server
//  2. Validate network connectivity before submitting
//  3. Display error message on UI if any
//  4. Alert user if failed to login
//  5. Keyboard event handler...shift view  up a bit  when login in case small screen like iphone4S
//  6. Add Facebook login integration
//
//  Credit: Class sample project MovieManager from Jarrod Parkes from Udacity
//          FB  reference   http://www.brianjcoleman.com/tutorial-how-to-use-login-in-facebook-sdk-4-0-for-swift/
//  Created by JeffreyZhang on 4/2/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate,UITextFieldDelegate, UIGestureRecognizerDelegate {

  
    @IBOutlet weak var lblSingUp: UILabel!
    @IBOutlet weak var UdacityIcon: UIImageView!
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!


    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
   
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        /* Configure tap recognizer */
        //diable keyboard if it is up
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    
        
         usernameTextField.delegate = self
         passwordTextField.delegate = self
         passwordTextField.secureTextEntry = true  // hide plain text
         debugTextLabel.text = ""                  // clear debug msg
        
         Utilities.AutoSizeLabelField(debugTextLabel, minScaleFactor: 0.3)

       // self.navigationController?.navigationBar.hidden = true
          

        
     
    
        if(!Utilities.isConnectedToNetwork() ){
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }
        
        
        // MARK: Facebook login
        // mobe this code to model after testing successfully
        //
        if (FBSDKAccessToken.currentAccessToken() != nil)  {
                loginUdacityfromFB()
            
            // Show Logout Button
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = CGPoint (x: self.view.center.x, y: self.view.bounds.size.height * 0.95)
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            
            
        } else  {
            // Show Login Button near bottom
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center =  CGPoint (x: self.view.center.x, y: self.view.bounds.size.height * 0.95)
            
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    
    func loginUdacityfromFB(){
        // User is already logged in
        
        //we pass accesstoken  to UdacityAPI to authenticate
        
        let myFBToken = FBSDKAccessToken.currentAccessToken().tokenString!
        WebUtilities.sharedInstance().loginWithFBAccessToken( myFBToken,  completionHandler: {
            success , error in
            if(success) {
                dispatch_async(dispatch_get_main_queue()) {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    var navController  = mainStoryboard.instantiateViewControllerWithIdentifier("tabController") as  UITabBarController
                    navController.hidesBottomBarWhenPushed = false
                    self.presentViewController(navController, animated: true, completion: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugTextLabel.text = "Facebook login Error:" +  error!
                    self.view.setNeedsDisplay()
                    Utilities.showAlert(self, title: "Facebook Login Error", message: error!)
                }
            }
        })

    }
    
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
 println("logged in  FB")
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.containsObject("email")
            {
                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    
                    if ((error) != nil)
                    {
                        // Process error
                        println("Error: \(error)")
                    }
                    else
                    {
                        //println("fetched user: \(result)")
                       // let userName : NSString = result.valueForKey("name") as NSString
                        let userEmail : String = result.valueForKey("email") as String
                        self.usernameTextField.text  = userEmail
                        self.loginUdacityfromFB()
                    }
                })
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    //sign up wiht Udacity
    func handleSignup(recognizer: UITapGestureRecognizer){
    //if clicked  on signup label
    let targetURL = WebUtilities.UrlPaths.Signup
    UIApplication.sharedApplication().openURL( NSURL(string: targetURL)!)
    }
    

    
    //allow multiple gestures
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Add tap recognizer to dismiss keyboard */
        self.addKeyboardDismissRecognizer()
        
        // add link to  sign lable
        let filteredSubviews = self.view.subviews.filter({
            $0.isKindOfClass(UILabel) })
        for view in filteredSubviews  {
            view.removeGestureRecognizer(tapRecognizer!)
            //find Sign Up UILabel and open link
            var signuplbl = view as UILabel
            if signuplbl.text!.rangeOfString("Sign Up") != nil{
                let recognizer = UITapGestureRecognizer(target: self, action: "handleSignup:")
                recognizer.numberOfTapsRequired = 1
                recognizer.delegate = self
                signuplbl.addGestureRecognizer(recognizer)
                signuplbl.userInteractionEnabled = true
            }
        }
     }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        /* Remove tap recognizer */
        self.removeKeyboardDismissRecognizer()
    }
    
    
    //clear text
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        debugTextLabel.text = ""
        
    }
    func keyboardWillHide(notification: NSNotification){
            self.view.frame.origin.y  =  0 //0.25 * Utilities.getkeyboardHeight(notification)
    }
    
    func keyboardWillShow(notification: NSNotification){
 
            self.view.frame.origin.y  =  -0.25 * Utilities.getkeyboardHeight(notification)
    
    }
    
    func textFieldShouldReturn( textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //I want the keyboard dismissed when user touches anything outside the keyboard like "Cancel"
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
 
   
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        //UIKeyboardWillHideNotification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func removeKeyboardDismissRecognizer() {
       self.view.removeGestureRecognizer(tapRecognizer!)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
 

    //valid email regular expression?
    @IBAction func LoginHere(sender: UIButton) {
        
        if usernameTextField.text.isEmpty {
            debugTextLabel.text = "Username Empty."
        } else if passwordTextField.text.isEmpty {
            debugTextLabel.text = "Password Empty."
        } else {
             //valid email regular expression?

            let emailreg = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$"
            
            let regexp = NSRegularExpression(pattern: emailreg, options: .CaseInsensitive, error: nil)
  
            let text = usernameTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let range = NSMakeRange(0, countElements(text))
            
            let matchRange = regexp?.matchesInString(text, options: .ReportProgress, range: range)
            
            let valid = matchRange?.last != nil
            if (valid) {
                
                // check  network availability
                if(!Utilities.isConnectedToNetwork() ){
                    Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
                    return
                }
                
                var username = usernameTextField.text
                var password = passwordTextField.text
                WebUtilities.sharedInstance().loginLocal(username, password: password ,  completionHandler: {
                    success , error in
                    if(success) {
                        dispatch_async(dispatch_get_main_queue()) {
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            var navController  = mainStoryboard.instantiateViewControllerWithIdentifier("tabController") as  UITabBarController
                            navController.hidesBottomBarWhenPushed = false
                            self.presentViewController(navController, animated: true, completion: nil)
                        }
                    } else {
                         dispatch_async(dispatch_get_main_queue()) {
                            self.debugTextLabel.text = "Error:" +  error!
                            self.view.setNeedsDisplay()
                            Utilities.showAlert(self, title: "Login Error", message: error!)
                        }
                    }

                })
            } else {
                debugTextLabel.text = "Invalid email address for Username!"
            }
        }
    }
}


// MARK: - Helper

extension LoginViewController {
    
    func configureUI() {
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1.00, green: 0.502, blue: 0.00, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.80, green: 0.4, blue: 0.00, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        headerTextLabel.textColor = UIColor.whiteColor()

        
    }
}
