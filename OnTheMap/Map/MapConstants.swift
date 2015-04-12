import Foundation
//
//  MapConstants.swift
//  OnTheMap
//
//  All constants used in thei project
//
//  Created by Jeffrey Zhang
//  based on Jarrod Parkes's work in Udacity moviemanager project
//  Copyright (c) 2015 Jeffrey Zhang. All rights reserved.
//

extension WebUtilities {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApplicationId : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let FaceBookAccessToken = "???"
        static let UdacityFacebookAppID : String = "365362206864879"
      }
    
    // MARK: - UrlPaths
    struct UrlPaths {
        
        // MARK: Lgoin and Students
        static let User     = "https://www.udacity.com/api/users"
        static let Login    = "https://www.udacity.com/api/session"
        static let Students = "https://api.parse.com/1/classes/StudentLocation"
        static let Signup   = "https://www.udacity.com/account/auth#!/signup"
        // MARK: Search
        static let SearchStudent = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22{uniqueKey}%22%7D"
        static let SearchStudentbyLastName = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22lastName%22%3A%22{lastName}%22%7D"
    }
    
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let ApplicationId = "X-Parse-Application-Id"
        static let ApiKey =  "X-Parse-REST-API-Key"
        
       // static let SessionID = "session_id"
      //  static let RequestToken = "request_token"

    }
    // MARK: - URL Keys
    struct URLKeys {
        static let StudentLastName = "lastName"
        static let StudentID = "uniqueKey"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "error"
        static let StatusCode = "status code"
        
        // MARK: Authorization
        //static let RequestToken = "request_token"
       // static let SessionID = "session_id"
        
        // MARK: Account
        static let Account = "account"
        static let StudentID = "uniqueKey"
        
        // MARK: Student
        static let StudentUniquKey = "uniqueKey"
        static let StudentFirstName = "firstName"
        static let StudentLastName = "lastName"
        static let StudentMapString = "mapString"
        static let StudentMediaURL = "mediaURL"
        static let StudentLatitude = "latitude"
        static let StudentLongitude = "longitude"
        static let StudentObjectId = "objectId"
        static let StudentCreatedDT = "createdAt"
        static let StudentUpdatedDT = "updatedAt"
        
        // this is for holding all results from JSON returned from request
        static let StudentResults = "results"
    }
}