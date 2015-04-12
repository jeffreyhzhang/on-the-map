//
//  StudentsHelper.swift
//  OnTheMap
//
//  Created by Jeffrey Zhangon 4/3/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
// 
//  1. Login local 
//  2  login using Facebook
//  3. Check if seudent already on Map to avoid duplicates
//     Many students simply post many time with different data with the same objectIB ot uniqueKey
//  4. get Student Name afetr login.
//  5. Search Studen by lastName or UniqueKey
//  6. Post/update stduent on Map
//
//
//  Based  on Jarrod Parkes's MovieManager project on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension WebUtilities {
    
    /* Login with Facebook */
    func loginWithFBAccessToken( FBAccessToken: String,  completionHandler: (success: Bool, errorString: String?) -> Void) {

        let mutableUrl :String =  UrlPaths.Login
        var parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            "facebook_mobile":  [
                "access_token" : FBAccessToken
            ]
        ]
        
        let  httpMethod : String = "POST"
        
        let task = taskForParseMethod(false,  httpmethod: httpMethod, urlpath: mutableUrl, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            
            if let error = error? {
                var msg  = "Login Failed!" + error.localizedDescription
                completionHandler(success: false, errorString: msg)
            } else {
                if let acct = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.Account) as? NSDictionary {
                    var studentId = acct["key"] as String
                    // set current student
                    WebUtilities.sharedInstance().CurrentStudent = StudentInformation(uniquekey: studentId)
                    completionHandler(success: true, errorString: nil)
                } else {
                    if let errordesc = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.StatusMessage) as? String {               completionHandler(success: false, errorString: errordesc)
                    }
                }
            }
        }
    }
    

    
    /* Login local autherication...return UniqueKey */
    
    func loginLocal(userName: String, password: String,  completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let mutableUrl :String =  UrlPaths.Login
        var parameters = [String: AnyObject]()
        
        // no way to perserve the order since it uses dictionary
        let jsonBody : [String:AnyObject] = [
            "udacity":  [
                "username" : userName,
                "password" : password
                ]
            ]
          
        let  httpMethod : String = "POST"
        
        let task = taskForParseMethod(false,  httpmethod: httpMethod, urlpath: mutableUrl, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
   
            if let error = error? {
                var msg  = "Login Failed!" + error.localizedDescription
                completionHandler(success: false, errorString: msg)
            } else {
                if let acct = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.Account) as? NSDictionary {
                    var studentId = acct["key"] as String
                    // set current student
                     WebUtilities.sharedInstance().CurrentStudent = StudentInformation(uniquekey: studentId)
                    
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Login Failed!")
                }
            }
        }
    }
    
    /*  Once loged in, you can get user's firstname and lastname */
    func getUserFullName( UniquieKey: String,  completionHandler: (success: Bool, lastname: String?, firstname: String?, errorString: String?) -> Void) {
        
        let mutableUrl :String =  UrlPaths.User + "/" + UniquieKey
        var parameters = [String: AnyObject]()
        
        let  httpMethod : String = "GET"
        
       let jsonBody : [String:AnyObject] = ["Any": "Any"]
        
        let task = taskForParseMethod(false,  httpmethod: httpMethod, urlpath: mutableUrl, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
 
            if let error = error? {
                var msg  = "Error in getting student FullName" + error.localizedDescription
                completionHandler(success: false, lastname: nil, firstname: nil, errorString: msg)
            } else {
                if let user = JSONResult.valueForKey("user") as? NSDictionary {
                    var lastName = user["last_name"] as? String
                    var firstName = user["first_name"] as? String
                   
                    completionHandler(success: true, lastname: lastName, firstname: firstName,errorString: nil)
                } else {
                    completionHandler(success: false, lastname: nil, firstname: nil, errorString: "Error in getting  student FullName")
                }
            }
        }
    }

    
    // MARK: - GET Convenience Methods
    // api.parse.com/1/classes/StudentInformation?limit=100===> you have to be authenticated before
    // There are so many duplicates....how to make it unique by studentID or uniquekey
    // I also sorted by updatedAt timstamp in descending order
    //
    func getStudentLocs(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = ["limit": "100"]
        var mutableurl : String = UrlPaths.Students
 
        /* 2. Make the request */
            taskForGETMethod(true, urlpath: mutableurl, parameters: parameters,  completionHandler:  { JSONResult, error in

            /* 3. Send the desired value(s) to completion handler */
            if let error = error? {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.StudentResults) as? [[String : AnyObject]] {
                    let students = StudentInformation.studentsFromResults(results).sorted { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
                    
                    completionHandler(result: students, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocs parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocs"]))
                }
            }
        })
    }
    
    //this really returns just zero or one student
    func getStudentbyUniqueKey(uniqueKey: String, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
        SearchSlotFull = true
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let searchUrl =  WebUtilities.subtituteKeyInMethod(UrlPaths.SearchStudent, key: WebUtilities.URLKeys.StudentID, value: uniqueKey )!
 
        /* 2. Make the request */
        let task = taskForGETMethod(true, urlpath: searchUrl,  parameters: nil ) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error? {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.StudentResults) as? [[String : AnyObject]] {
                    var students = StudentInformation.studentsFromResults(results)
                     completionHandler(result: students, error: nil)
                    
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentbyUniqueKey parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentbyUniqueKey"]))
                    
                }
            }
        }
        
        return task
    }
  
    // MARK : StudentOnMapAlready - 
    //
    // check to see if the student already post on map
    // Note: students may have posted multiple times on the map....duplicates are allowed?
    //       studentID is uniqueKey
    //
    func StudentOnMapAlready( studentID : String) -> Bool {
        
        var amDone : Int = 0
        WebUtilities.sharedInstance().getStudentbyUniqueKey(studentID, completionHandler: {
            students , error in
            //release the search slot.
            WebUtilities.sharedInstance().SearchSlotFull = false
            if let student = students? {
                for me in student {
                    amDone = 1
                    //set the current user
                    WebUtilities.sharedInstance().CurrentStudent = me
                    break;
                }
            } else {
                amDone = 0
                println(error)
            }
        })
        
        //wait here until completion
        while( WebUtilities.sharedInstance().SearchSlotFull! ) {
            NSThread.sleepForTimeInterval(0.1)
        }
        
        return  amDone > 0 ? true: false
    }
    
    //
    //
    // MARK: - POST/PUT Convenience Methods
    //if the student already on Map, then update (PUT) else Add (POST)
    //
    func upsertStudentToMap(student: StudentInformation, completionHandler: (result: Int?, error: NSError?) -> Void) {
        
        // first find if this student already in
        var exitsOnMap : Bool = StudentOnMapAlready(student.uniqueKey)
     
        var parameters  =  Dictionary<String, String>()
        
        var mutableUrl: String = UrlPaths.Students
        var putOrPost : String = exitsOnMap ?  "PUT" : "POST"
        //update must use objectID from udacity
        if(exitsOnMap) {
            mutableUrl = mutableUrl + "/" + WebUtilities.sharedInstance().CurrentStudent!.objectId!;
        }
        
        var mediaurl = ""
        if(student.mediaURL != nil ) {
           mediaurl = student.mediaURL!
        }
        
        // JSONResponseKeys.StudentObjectId: student.objectId, 
        // never pass from here...if new, it will be created, if update, it is in url
        let jsonBody : [String:AnyObject] = [
            JSONResponseKeys.StudentUniquKey: student.uniqueKey,
            JSONResponseKeys.StudentFirstName: student.firstName!,
            JSONResponseKeys.StudentLastName: student.lastName!,
            JSONResponseKeys.StudentMapString: student.mapString!,
            JSONResponseKeys.StudentMediaURL: mediaurl,            // maybe empty..need escape in case you have : in it
            JSONResponseKeys.StudentLatitude: student.latitude!,
            JSONResponseKeys.StudentLongitude: student.longitude!
          ]
        
        let task = taskForParseMethod(true, httpmethod: putOrPost, urlpath: mutableUrl, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* Send the desired value(s) to completion handler : 3jshkaNJL6*/
            if let error = error? {
                completionHandler(result: nil, error: error)
            } else {
                 if let created = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.StudentCreatedDT) as? NSObject {
                    completionHandler(result: 0, error: nil)
                } else if  let updated = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.StudentUpdatedDT) as? NSObject {
                    completionHandler(result: 0, error: nil)
                } else {
                    completionHandler(result: -1, error: NSError(domain: "upsertStudentToMap parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse upsertStudentToMap"]))
                }
            }
        }
    }
    /* search by last name*/
    func getStudentsForLastName(searchText :String,  completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
  
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let searchUrl =  WebUtilities.subtituteKeyInMethod(UrlPaths.SearchStudentbyLastName, key: WebUtilities.URLKeys.StudentLastName, value: searchText)!
        
        /* 2. Make the request */
        let task = taskForGETMethod(true, urlpath: searchUrl,  parameters: nil ) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error? {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult.valueForKey(WebUtilities.JSONResponseKeys.StudentResults) as? [[String : AnyObject]] {
                    var students = StudentInformation.studentsFromResults(results)
                    completionHandler(result: students, error: nil)
                    
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentsForLastName parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentsForLastName"]))
                    
                }
            }
        }
        
        return task
    }
}
