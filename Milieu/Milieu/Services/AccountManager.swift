//
//  AccountManageService.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2017-01-17.
//  Copyright © 2017 Atelier Ruderal. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class AccountManager{
    let secretKey: String = "MilieuApiToken"


    //MARK: Shared Instance
        
    static let sharedInstance : AccountManager = {
        return AccountManager()
    }()
    
    func saveToken(token: ApiToken) -> Bool{
        let data = NSKeyedArchiver.archivedData(withRootObject: token)
        return KeychainWrapper.standard.set(data, forKey: secretKey)
    }
    
    
    func fetchToken() -> ApiToken?{
        let savedData: Data? = KeychainWrapper.standard.data(forKey: secretKey)
        guard let data =  savedData else{
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? ApiToken ?? nil
    }
    
    func updateToken(fbToken: String, completionHandler: @escaping (ApiToken?, String?) -> Void){
        let parameters: Parameters = [
            "token":fbToken,
            "provider":"facebook"
        ]
        
        Alamofire.request("http://localhost:3000/api/v1/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON{
            response in
            
            let result = response.result
            print(response.debugDescription)
            print(JSON.init(data: response.data!).debugDescription)
            switch result{
            case .success:
                completionHandler(ApiToken(dictionary: result.value as? JSONDictionary), nil)
            case .failure:
                let message = JSON.init(data: response.data!)["message"].stringValue
                completionHandler(nil, message)
            }
        }
    }
}
