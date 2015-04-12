//
//  StudentInformation.swift
//  OnTheMap
//
//  Stududent Infomation with initialization
//  I got three constructors and one class method
//
//  Created by Jeffrey Zhang on 3/31/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//
//  Based on on Jarrod Parkes's MovieManager project on 2/11/15.

import Foundation
struct StudentInformation    {
    var createdAt : NSDate? 
    var firstName : String?
    var lastName : String?
    var latitude : NSNumber?
    var longitude : NSNumber?
    var mapString : String?
    var mediaURL : String? = "http://udacity.com"
    var objectId : String?
    var uniqueKey : String
    var updatedAt : NSDate = NSDate()
    //ACL ??? how defined
    
     /* Construct a StudentInformation from proprties */
    init(createdAt :NSDate,  firstName :String, lastName :String, latitude :NSNumber, longitude :NSNumber, mapString :String, mediaURL :String,   objectid :String, uniquekey :String, updatedAt :NSDate) {
        self.objectId  = objectid
        self.uniqueKey = uniquekey
        self.firstName = firstName
        self.lastName  = lastName
        self.mapString = mapString
        self.mediaURL  = mediaURL
        self.latitude  = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /*  covenience ...we can have it once we login*/
    init(uniquekey :String) {
        self.uniqueKey = uniquekey
    }
    /* Construct a StudentInformation from a dictionary object*/
        
    init(dictionary: [String : AnyObject]) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        self.objectId  = dictionary[WebUtilities.JSONResponseKeys.StudentObjectId] as? String
        self.uniqueKey = dictionary[WebUtilities.JSONResponseKeys.StudentUniquKey] as String
        self.firstName = dictionary[WebUtilities.JSONResponseKeys.StudentFirstName] as? String
        self.lastName  = dictionary[WebUtilities.JSONResponseKeys.StudentLastName] as? String
        self.mapString = dictionary[WebUtilities.JSONResponseKeys.StudentMapString] as? String
        self.mediaURL  = dictionary[WebUtilities.JSONResponseKeys.StudentMediaURL] as? String  // maybe empty
        self.latitude  = dictionary[WebUtilities.JSONResponseKeys.StudentLatitude] as? NSNumber
        self.longitude = dictionary[WebUtilities.JSONResponseKeys.StudentLongitude] as? NSNumber
        var retstring = dictionary[WebUtilities.JSONResponseKeys.StudentUpdatedDT] as  String
        self.createdAt =  dateFormatter.dateFromString(retstring)!
        // we not have updatedAt
        if let  retstring = dictionary[WebUtilities.JSONResponseKeys.StudentUpdatedDT] as? String {
            if retstring.isEmpty == false {
                self.updatedAt =  dateFormatter.dateFromString(retstring)!
            }
        }
    }

    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    //  use student uniquekey to remove duplicates
    //
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        var lookup = [String: String]() //empty dictionary key-value pair
        
        for result in results {
            // if not already there with the key
            var student = StudentInformation(dictionary: result)
            
            var uniqueKey = student.uniqueKey
            var fullname = student.lastName! + "," + student.firstName!
            if let val = lookup[uniqueKey] {
                //println("duplicates!..." + fullname  + "..." + uniqueKey)
            } else {
               students.append(student)
               lookup[uniqueKey]  = fullname
            }
        }
        
        return students
    }

}