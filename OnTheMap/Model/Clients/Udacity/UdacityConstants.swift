//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by admin on 29/12/2018.
//  Copyright © 2018 Rima. All rights reserved.
//

extension UdacityClient{

struct Constants{
    //Udacity API
    static let ApiKey = "YOUR_API_KEY_HERE"
    
    //Udacity API
    static let ApiScheme = "https"
    static let ApiHost = "onthemap-api.udacity.com"
    static let ApiPath = "/v1"
    
    // MARK: Parse API
    static let ParseApiHost = "parse.udacity.com"
    static let ParseApiPath = "/parse/classes" //Used in GET one or more Student Location, POST and PUT
}

// MARK: Methods
struct Methods {
    //Udacity API
    static let Session = "/session" // Used in POST and Delete sessionID
    static let UserData = "/users" // Used in GET user data
    
    //Parse API
    static let StudentLocation = "/StudentLocation"

}

// MARK: Parameter Keys
struct ParameterKeys {
    //Udacity API
    static let ApiKey = "api_key"
    static let SessionID = "session_id"
    static let RequestToken = "request_token"
    static let Query = "query"
    
    //Parse API
    static let Limit = "limit" // Maximum number of StudentLocation objects to return
    static let Skip = "skip" // Limit to paginate through results
    static let Order = "order" //sorted order of the results (default order is ascending)

}


// MARK: JSON Body Keys
struct JSONBodyKeys {
    static let Udacity = "udacity"
    static let Username = "username"
    static let Password = "password"
    
    //Parse API
    static let ObjectId = "objectId"

}

// MARK: JSON Response Keys
struct JSONResponseKeys {

    // MARK: Account
    static let Account = "account"
    static let Registered = "registered"
    static let AccountKey = "key" //to use it later for posting/putting a location
    
    // MARK: Session
    static let Session = "session"
    static let SessionID = "id"
    static let SessionExpiration = "expiration"

}

struct HTTPMethod {
        static let Post = "POST"
        static let Get = "GET"
        static let Delete = "DELETE"
        static let Put = "PUT"
    }
}
