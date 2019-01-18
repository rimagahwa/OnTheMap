//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by admin on 31/12/2018.
//  Copyright © 2018 Rima. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient : NSObject {
    
 
    var session = URLSession.shared
    
    //MARK: Store the information once the app gets it from API
    //Udacity API
     var sessionID : String? = nil
     var userID : String? = nil
    
    //Set by Parse API
   static var studentsLocations: [[String:Any]] = [[:]] //Make it a static class property
    
    //Calling UIViewController
    static var callinViewController : UIViewController? = nil
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
  
    //MARK: Network functions
    func postStudenttLocation(_ studentInformation: StudentInformation, completionHandlerForpostStudenttLocation: @escaping (_ success: Bool,_ errorString: String?) -> Void) {
        

        let mapString = studentInformation.mapString
        let mediaURL = studentInformation.mediaURL
        // 6 decimal points, since this is how many decimals geocodaing has
        let lat = studentInformation.latitude
        let long = studentInformation.longitude
        
        postLocation(mapString: mapString!, mediaURL: mediaURL!, latitude: lat, longitude: long){ (success, errorString) in
            
            if success {
                //Inform the calling UIViewController of the result
                completionHandlerForpostStudenttLocation(success,nil)
            }
            else {
                //Inform the calling UIViewController of the result
                completionHandlerForpostStudenttLocation(success, errorString)
            }
            
    }
    }

    // MARK: Authentication via POST methods, get a SessionID
    func loginUser(_ userEmail:String,_ userPassword:String, completionHandlerForLoginUser: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        getSessionID(userEmail,userPassword){ (success,sessionID,userID,errorString) in
            
            if success {
                // store the sessionID
                self.sessionID =  sessionID
                //store
                self.userID = userID
                //Inform the calling UIViewController of the result
                completionHandlerForLoginUser(true,nil)
        }
            else {
                //Inform the calling UIViewController of the result
                completionHandlerForLoginUser(success, errorString)
            }
     }
    }
    
    
    //When we get a session ID (by Login), we  delete the session ID to Logout
    func logoutUser(completionHandlerForLogoutUser: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        deleteSessionID(){
            (success,errorString) in
            
            if success {
                // remove the sessionID
                self.sessionID =  ""
                //Inform the calling UIViewController of the result
                completionHandlerForLogoutUser(success,nil)
            }
            else {
                //Inform the calling UIViewController of the result
                completionHandlerForLogoutUser(success, errorString)
            }
        }
    }
    
    
    private func postLocation(mapString: String?,mediaURL: String?,latitude:Double?,longitude:Double?, completionHandlerForpostLocation: @escaping(_ success: Bool,_ errorString: String?) -> Void) {
        
        let method = Methods.StudentLocation
        
        let httpBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().userID!)\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"\(mapString!)\", \"mediaURL\": \"\(mediaURL!)\",\"latitude\": \(latitude!), \"longitude\": \(longitude!)}"
        
        taskForPOSTLocationMethod(method, jsonBody: httpBody)  {
            (results,error) in
            
            if error != nil {
                self.showAlertToUser(error!, "Error", error.debugDescription, "Ok")
                completionHandlerForpostLocation(false,error.debugDescription)
            } else {
                //if we got a response with "objectId" then location was posted
                if let result = results?["objectId"] as? String {
                    completionHandlerForpostLocation(true, nil)
                } else {
                    self.showAlertToUser(error!, "Error", "Something went wrong", "Ok")
                    completionHandlerForpostLocation(false,error.debugDescription)
                }
            }
        }
        
    }
    
    
    //No method Paramter is sent
    private func deleteSessionID( completionHandlerForDELETESessionID: @escaping(_ success: Bool,_ errorString: String?) -> Void){
        let method = Methods.Session
        
        taskForDELETEMethod(method){ (results,error) in
            
            if error != nil {
                completionHandlerForDELETESessionID(false, error?.localizedDescription)
            } else {
                //Check if API responded JSON with "session" if true, logout is succesful
                if let result = results?["session"] as? [String:AnyObject] {
                    completionHandlerForDELETESessionID(true,nil)
                } else {
                    completionHandlerForDELETESessionID(false, error?.localizedDescription)
                }
            }
        }
    }
    
    
    //Send the enterd user info as method parameter
    private func getSessionID(_ userEmail:String,_ userPassword:String,_ completionHandlerForSessionID: @escaping (_ success: Bool, _ sessionID: String?,_ userID: String?, _ errorString: String?) -> Void) {
        
        let methodParameter = [UdacityClient.JSONBodyKeys.Username : userEmail,
        UdacityClient.JSONBodyKeys.Password : userPassword]
        
        let method = Methods.Session

        
        let httpBody = "{\"udacity\": {\"username\": \"\(userEmail)\",\"password\": \"\(userPassword)\"}}"
        
        taskForPOSTMethod(method,parameters: methodParameter as [String : AnyObject],jsonBody: httpBody) {(results,error) in
   
            if error != nil {
            completionHandlerForSessionID(false,nil,nil, error?.localizedDescription)
        } else {
                
                if let result = results?["session"] as? [String:AnyObject] {
                
                    let sessionID = result[UdacityClient.JSONResponseKeys.SessionID] as? String!
                    
                    let userAccount = results?[UdacityClient.JSONResponseKeys.Account] as?  [String:AnyObject]
                        
                        let userID = userAccount![UdacityClient.JSONResponseKeys.AccountKey] as? String!
    
                    completionHandlerForSessionID(true, sessionID!,userID!,nil)
                }
 
                    
                    
             else {
                    self.showAlertToUser(error!, "Error", "Something went wrong", "Ok")
                completionHandlerForSessionID(false, nil,nil, error?.localizedDescription)
            }
        }
        }

    }
    
    
    
    //MARK: GETting multiple Student Locations
    func getStudentLocations(completionHandlerGetStudentLocations: @escaping(_ success: Bool, _ locations: LocationsData, _ errorString: String?) -> Void){
        let method = Methods.StudentLocation
        
        //Optional* limit the maximum number of StudentLocation objects to return in the JSON response
        //We want the most recent 100
        let methodParameter = [UdacityClient.ParameterKeys.Limit : "100",
                               UdacityClient.ParameterKeys.Order: "-updatedAt"]
        
        taskForGETMethodParse(method, parameters: methodParameter as [String : AnyObject]) {
            (results,error) in
            
            var studentInfo: [StudentInformation] = []

            if error != nil {
                self.showAlertToUser(error!,"Error","No internet connection", "Ok")
                //Pass an empty dictionary if nil
                completionHandlerGetStudentLocations(false,LocationsData(studentLocations: studentInfo), error?.localizedDescription)

            } else {

                if let result = results?["results"] as? [[String:Any]]{
                    
                   // UdacityClient.studentsLocations = result //Store it, or Reassign the value with new data
                    for location in result {
                        let data = try! JSONSerialization.data(withJSONObject: location)
                        let studentLocation = try! JSONDecoder().decode(StudentInformation.self, from: data)
                        studentInfo.append(studentLocation)
                    }
                    
                    guard studentInfo.count  > 0 else { //Make sure the array has objects
                        self.showAlertToUser(error!, "Error", "No pins found", "Ok")
                        completionHandlerGetStudentLocations(false,LocationsData(studentLocations: studentInfo),"No pins found")
                        return
                    }
                    
                    print("DOWNLOADED StudentLocation Array")
                    completionHandlerGetStudentLocations(true,LocationsData(studentLocations: studentInfo),nil)
                } else {
                    self.showAlertToUser(error!, "Error", "Something went wrong", "Ok")
                    //Pass an empty dictionary
                    completionHandlerGetStudentLocations(false, LocationsData(studentLocations: studentInfo), error?.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: GET process method
    func taskForGETMethodParse(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {

        //No API Key, send the parameter as is
        //Note using Parse URL here
        let request = NSMutableURLRequest(url: UdacityClient.parseURLFromParameters(parameters, withPathExtension: method))
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest){
            (data,response,error) in
            
            
            // Check for error
            guard (error == nil) else {
                self.showAlertToUser(error!, "Error", "Something went wrong", "Ok")
                completionHandlerForGET(nil, error )
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                // Udacity Account Info Incorrect  Error
                if statusCode == 403 {
                    let error = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: "Account not found or invalid credentials."])
                    self.showAlertToUser(error,"Login Error", "Account not found or incoorect login information. Please make sure the username and password are correct.","Ok")
                    
                    completionHandlerForGET(nil, error )

                    return
                }
                
                //Request returned successfully
                if statusCode >= 200 && statusCode < 300 {
                    
                    // No need to Skip the first 5 characters of the response
                    //Parse data to JSON
                    self.convertDataToJSON(data!, completionHandlerForConvertData: completionHandlerForGET)
                }
            }
            
        }
        task.resume()
        
        return task
        
    }
    
    
    //MARK: POST Process Method, for posting location
    func taskForPOSTLocationMethod(_ method: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        //No API Key, send the parameter as is
        let request = NSMutableURLRequest(url: UdacityClient.parseURLFromParameters(method))
        
        // Specifiy method as POST, set headers and pass JSON body
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonBody.data(using: .utf8)

        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            // Check for error
            guard (error == nil) else {
                self.showAlertToUser(error!, "Post Location Error", "Something went wrong", "Ok")
                completionHandlerForPOST(nil, error )
                return
            }
            
            //Differentiate statusCode meaning
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                // 5xx Server Error
                if (statusCode >= 500) && (statusCode <= 599) {
                    let error = NSError() //Empty error object
                    self.showAlertToUser(error,"Server Error", "It is our fault, please try again later","Ok")
                    completionHandlerForPOST(nil, error )
                    
                    return
                }
                
                //Request returned successfully
                if statusCode >= 200 && statusCode < 300 {
                    
                    //No need to skip the first 5 characters of the response
                    
                    //Parse data to JSON
                    self.convertDataToJSON(data!, completionHandlerForConvertData: completionHandlerForPOST)
                }
            }
            
        }
        
        task.resume()
        
        return task
        
    }
    
    
    
    //MARK: POST Process Method, for Login
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        //No API Key, send the parameter as is
        let request = NSMutableURLRequest(url: UdacityClient.udacityURLFromParameters(parameters, withPathExtension: method))
        
        // Specifiy method as POST, set headers and pass JSON body
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            // Check for error
            guard (error == nil) else {
             self.showAlertToUser(error!, "Login Error", "Something went wrong", "Ok")
                completionHandlerForPOST(nil, error )
                return
            }
            
            //Differentiate statusCode meaning
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                // Udacity Account Info Incorrect Error
                if statusCode == 403 {
                    let error = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: "Account not found or invalid credentials."])
                    
                    self.showAlertToUser(error,"Login Error", "Account not found or incoorect login information. Please make sure the username and password are correct.","Ok")
                    completionHandlerForPOST(nil, error )
                    return
                }
                
                // 5xx Server Error
                if (statusCode >= 500) && (statusCode <= 599) {
                    let error = NSError() //Empty error object
                    self.showAlertToUser(error,"Login Error", "Account not found or incoorect login information. Please make sure the username and password are correct.","Ok")
                    completionHandlerForPOST(nil, error )

                    return
                }
                
                //Request returned successfully
                if statusCode >= 200 && statusCode < 300 {
                    
                    //Skip the first 5 characters of the response
                    let range = 5..<data!.count
                    let dateSkipFive = data?.subdata(in: range)
                    
                    //Parse data to JSON
                    self.convertDataToJSON(dateSkipFive!, completionHandlerForConvertData: completionHandlerForPOST)
                }
            }
           
        }
        
        task.resume()
        
        return task
        
    }
    
    
    //MARK: DELETE Process Method
    private func taskForDELETEMethod(_ method:String, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        //No API Key, send the parameter as is

           let request = NSMutableURLRequest(url:
            UdacityClient.udacityURLFromParameters(method))
        
        // Specifiy method as DELETE
        request.httpMethod = HTTPMethod.Delete
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest){
            (data,response,error) in
            
            
            // Check for error
            guard (error == nil) else {
                self.showAlertToUser(error!, "Logout Error", "Something went wrong", "Ok")
                completionHandlerForDELETE(nil, error )

                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                //Request returned successfully
                if statusCode >= 200 && statusCode < 300 {
                    
                    //Skip the first 5 characters of the response
                    let range = 5..<data!.count
                    let dateSkipFive = data?.subdata(in: range)
                    
                    //Parse data to JSON
                    self.convertDataToJSON(dateSkipFive!, completionHandlerForConvertData: completionHandlerForDELETE)
                }
            }
            
        }
        
        
        task.resume()
        return task
    }
    
    
    
    //MARK: Convert the data received to JSON
    private func convertDataToJSON(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse data to JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataToJSON", code: 1, userInfo: userInfo))
        }
        
        print("Parsed JSON '\(parsedResult)'")

        //Send the result to the first caller
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    //MARK: Parse API - Create a URL from passed parameters and URL path
    class func parseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ParseApiHost
        components.path = UdacityClient.Constants.ParseApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    //MARK: Parse API - Create a URL from passed URL path Only
    class func parseURLFromParameters(_ pathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ParseApiHost
        components.path = UdacityClient.Constants.ParseApiPath + (pathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        return components.url!
    }
    
    
    //MARK: Udacity API - Create a URL from passed parameters and URL path
    class func udacityURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    //MARK: Udacity API - Create a URL from passed URL path Only
    class func udacityURLFromParameters(_ pathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (pathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        return components.url!
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
    //MARK: Show Alertview to user in case theres an error
    func showAlertToUser(_ error:Error,_ alertTitle:String,_ alertBodyText:String,_ firstButtonTitle:String){
        if UdacityClient.callinViewController != nil{
            print(error)
            //Show AlertView informing user of error
            let alertView = UIAlertController(title: alertTitle, message: alertBodyText, preferredStyle: UIAlertController.Style.alert)
            // Add "Ok" button
            alertView.addAction(UIAlertAction(title:firstButtonTitle, style: UIAlertAction.Style.default, handler: nil))
            
            //Finally show the alert in main thread
            DispatchQueue.main.async {
                //Find the current visable ViewController,then present the alert in it
                UdacityClient.callinViewController!.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    
    //Mark: Create and return an activityIndicator to show that something is loading
    func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        UdacityClient.callinViewController!.view.addSubview(activityIndicator)
        UdacityClient.callinViewController!.view.bringSubviewToFront(activityIndicator)
        activityIndicator.center = UdacityClient.callinViewController!.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
        
    }
    
}
