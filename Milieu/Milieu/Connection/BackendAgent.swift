//
//  BackendAgent.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-03-29.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import Alamofire

enum RequestTypeV1{
    case Register
    case FetchAllDevApps
}

class BackendAgent{
    
    func sendRequest(type: RequestTypeV1, params: [String: AnyObject]?){
        
    }
}