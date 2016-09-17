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
    case SubmitVoting = "/rate"
    case Like = "/heart"
    case Dislike = "/break_heart"
}

enum OpenNorthApi: String{
    case FindOttawaWards = "/boundaries/ottawa-wards/?limit=30"
    case FindOttawaWardsSimpleShape = "/boundaries/ottawa-wards/simple_shape"
}

protocol ConnectionManagerDelegate: class{
    func requestDidSucceed(_ data: Data)
    func requestDidFail(_ error: NSError)
}

class ConnectionManager {
    static let sharedManager = ConnectionManager()
    lazy var session = URLSession.shared
    weak var delegate: ConnectionManagerDelegate?
    
    func createRequest(_ type: RequestType) -> URLRequest{
        let serverUrl = "https://milieu.io"
        
        let url = URL(string: "\(serverUrl)\(type.rawValue)")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        return request as URLRequest
    }
    
    func sendRequest(_ request: URLRequest){
        
        let task = session.dataTask(with: request, completionHandler:{
            data, response, error in
            
            // Check the connection establishment error
            if let error = error{
                AR5Logger.debug("Can't get data: \(error.localizedDescription)")
                self.delegate?.requestDidFail(error as NSError)
                return
            }
            
            // Check the HTTP response error
            if let response = response as? HTTPURLResponse{
                if response.statusCode != 200{
                    let message = "HTTP response fails: \(response.statusCode), \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))"
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
