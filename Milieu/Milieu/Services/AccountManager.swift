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
import FBSDKLoginKit

class AccountManager{
    let secretKey: String = "MilieuApiToken"
    var token: ApiToken?

    //MARK: Shared Instance
        
    static let sharedInstance : AccountManager = {
        return AccountManager()
    }()
    
    func hasLogIn() -> Bool{
        // Check if fbToken exists
        guard FBSDKAccessToken.current() != nil else{
            return false
        }
        // Check JWT token in keychain
        token = fetchToken()
        return token != nil
    }
    
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
        
        Alamofire.request(Connection.LoginUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON{
            response in
            
            let result = response.result

            switch result{
            case .success:
                completionHandler(ApiToken(dictionary: result.value as? JSONDictionary), nil)
            case .failure:
                let message = JSON.init(data: response.data!)["message"].stringValue
                completionHandler(nil, message)
            }
        }
    }
    
    func deleteToken(){
        KeychainWrapper.standard.removeObject(forKey: secretKey)
    }
}
