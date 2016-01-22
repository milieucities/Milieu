//
//  ConnectionManager.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-16.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

let errorDomain = "ConnectionError"

enum RequestType: String{
    case FetchAllApplications = "/dev_sites"
    case FetchCommentsForDevSite = "/all_devsite_comments"
}

protocol ConnectionManagerDelegate: class{
    func requestDidSucceed(data: NSData)
    func requestDidFail(error: NSError)
}

class ConnectionManager {
    static let sharedManager = ConnectionManager()
    lazy var session = NSURLSession.sharedSession()
    weak var delegate: ConnectionManagerDelegate?
    
    func createRequest(type: RequestType) -> NSURLRequest{
        let serverUrl = "http://159.203.32.15"
        
        let url = NSURL(string: "\(serverUrl)\(type.rawValue)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        return request
    }
    
    func sendRequest(request: NSURLRequest){
        
        let task = session.dataTaskWithRequest(request, completionHandler:{
            data, response, error in
            
            // Check the connection establishment error
            if let error = error{
                AR5Logger.debug("Can't get data: \(error.userInfo)")
                self.delegate?.requestDidFail(error)
                return
            }
            
            // Check the HTTP response error
            if let response = response as? NSHTTPURLResponse{
                if response.statusCode != 200{
                    let message = "HTTP response fails: \(response.statusCode), \(NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode))"
                    let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                    self.delegate?.requestDidFail(NSError(domain: errorDomain, code: 0, userInfo: userInfo))
                    return
                }
            }
            
            // Return response
            if let data = data{
                self.delegate?.requestDidSucceed(data)
            }
        })
        task.resume()
    }
}