//
//  API.swift
//  BrightOwl
//
//  Created by Khalid Usman on 4/19/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol APIResponseDelegates {
    func apiSuccessResponseWithURL(json: JSON, urlString: String)
    func apiFailureResponseWithURL(errorDesc: String, urlString: String)
}

class API: NSObject {
    
    static let baseUrl = "http://brightowl.xorlogics.com/dev/api/"
    
    class func postRequest(urlStr : String, jsonData : NSData?, isLogin : Bool, delegate: APIResponseDelegates) {
        let urlString = baseUrl + urlStr
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.setValue("app_key=ios-app,app_secret=ios-app-key", forHTTPHeaderField: "App")
        let auth_token : String = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as! String
        if auth_token.isEmpty == false {
            request.setValue(auth_token, forHTTPHeaderField: "AuthToken")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if isLogin {
            request.HTTPBody = jsonData
        }
        Alamofire.request(request)
            .responseJSON {
                response in
                let urlStr = response.request?.URLRequest.URL?.absoluteString
                switch response.result {
                case .Failure( _):
                    delegate.apiFailureResponseWithURL((response.result.error?.description)!,urlString: urlStr!)
                case .Success(let data):
                    let json = JSON(data)
                    delegate.apiSuccessResponseWithURL(json,urlString: urlStr!)
                }
            }
    }
    
    class func getRequest(urlStr : String, jsonData : NSData?, isLogin : Bool, delegate: APIResponseDelegates) {
        let urlString = baseUrl + urlStr
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "GET"
        request.setValue("app_key=ios-app,app_secret=ios-app-key", forHTTPHeaderField: "App")
        let auth_token : String = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as! String
        if auth_token.isEmpty == false {
            request.setValue(auth_token, forHTTPHeaderField: "AuthToken")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if isLogin {
            request.HTTPBody = jsonData
        }
        Alamofire.request(request)
            .responseJSON {
                response in
                let urlStr = response.request?.URLRequest.URL?.absoluteString
                switch response.result {
                case .Failure( _):
                    delegate.apiFailureResponseWithURL((response.result.error?.description)!,urlString: urlStr!)
                case .Success(let data):
                    let json = JSON(data)
                    delegate.apiSuccessResponseWithURL(json, urlString: urlStr!)
                }
        }
    }
}
