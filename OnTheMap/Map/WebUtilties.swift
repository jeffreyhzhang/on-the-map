//
//  WebUtilties.swift
//  OnTheMap
//
//  1. Basic http GET/POST/PUT to get/post/modify data via http
//    This will be used by Udacity api as well as parse api
//  2. Validate URL  (use header only)...this is used to make sure User put valid mediaURL
//
// for udacity.com domain where no apikey or applicationID needed in request header.
// for parse.com domain where apikey and applicationID are needed in request header.
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//
//
import Foundation

class WebUtilities : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    
    /* this is current user who logined*/
    var CurrentStudent : StudentInformation?
    
    /* sephmore */
    var SearchSlotFull : Bool? 
    
    
    /* shared between map and table once populated */
    var last100Students: [StudentInformation] = [StudentInformation]()
    
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
  
    func taskForGETMethod(addHttpHeaderFields : Bool, urlpath: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
       
         var urlString = urlpath
         if (parameters != nil ) {
             var mutableParameters = parameters
            /* 2/3. Build the URL and configure the request */
            urlString = urlpath + WebUtilities.escapedParameters(mutableParameters!)
         }

       //this can cause exposion??? when you have space etc in search
        
         let url = NSURL(string: urlString)!
 
         let request = NSMutableURLRequest(URL: url)
        
            request.HTTPMethod = "GET"

            if(addHttpHeaderFields){
                request.addValue(Constants.ApplicationId, forHTTPHeaderField: ParameterKeys.ApplicationId)
                request.addValue(Constants.APIKey, forHTTPHeaderField: ParameterKeys.ApiKey)
            }
            /* 4. Make the request */
            let task = session.dataTaskWithRequest(request) {data, response, downloadError in

                /* 5/6. Parse the data and use the data (happens in completion handler) */
                if let error = downloadError? {
                    let newError = WebUtilities.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: downloadError)
                } else {
                    WebUtilities.parseJSONWithCompletionHandler(data, completionHandler)
                }
            }
            
            /* 7. Start the request */
            task.resume()
            
            return task
    }
    
    // MARK: all for Parse related web requests
    //
    // httpmethod: POST(create), PUT (update), DELETE (remove)
    // urlpath:   StudentInformation?where.... or StudentInformation?limit=100, StudentInformation/objectID
    //
    func taskForParseMethod(addHttpHeaderFields: Bool, httpmethod: String, urlpath: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let urlString =  urlpath + WebUtilities.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = httpmethod
        
        // for parse api we need keys, not needed for udacity api
        if(addHttpHeaderFields) {
            request.addValue(Constants.ApplicationId, forHTTPHeaderField: ParameterKeys.ApplicationId)
            request.addValue(Constants.APIKey, forHTTPHeaderField: ParameterKeys.ApiKey)
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // the order is not kept in JSON data from JSONBody...random...since it uses dictinary
        if(httpmethod != "GET") {
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        }
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError? {
                    let newError = WebUtilities.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: downloadError)
                } else {
                    var newdata = data
                // special for Udacity api
                    if(!addHttpHeaderFields) {
                        newdata = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                    }
                    WebUtilities.parseJSONWithCompletionHandler(newdata, completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /*  VaildateURL */
    
    func ValidateURL( urlpath: String,  completionHandler: (success: Bool, error: NSError?) -> Void)  {
        
        let url = NSURL(string: urlpath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "Head"
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError? {
                let newError = WebUtilities.errorForData(data, response: response, error: error)
                
                completionHandler(success:  false, error: newError)
            } else {
                var parsingError: NSError? = nil
                
                // URL Responded - Check Status Code
                if let urlResponse = response as? NSHTTPURLResponse
                {
                    if ((urlResponse.statusCode >= 200 && urlResponse.statusCode < 400) || urlResponse.statusCode == 405)
                        // 200-399 = Valid Responses, 405 = Valid Response (Weird Response on some valid URLs)
                    {
                        println(urlResponse.statusCode)
                        completionHandler(success: true, error: nil)
                        // if valid, we caontinue
                        dispatch_async(dispatch_get_main_queue()) {

                        }
                    }
                    else // Error
                    {
                        completionHandler(success: false, error: nil)
                    }
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
 
    // MARK: - Helpers
    // These functions are class level function or type method that are not tied to specifuc instances
    // like sticit method in struct...you can you it without an instacnes of the class as object!
    //
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[WebUtilities.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Udacity API Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError? {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
           // let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* FIX: Replace spaces with '+' */
            let replaceSpaceValue = stringValue.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            /* Append it */
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    //
    // why not just return WebUtilities() directly?
    //
    class func sharedInstance() -> WebUtilities {
        
        struct Singleton {
            static var sharedInstance = WebUtilities()
        }
        
        return Singleton.sharedInstance
    }
}