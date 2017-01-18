//
//  AuthenticatControllerViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-11-15.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Alamofire
import SwiftKeychainWrapper

class AuthenticateViewController: UIViewController {

    
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        facebookSignInButton.delegate = self
        facebookSignInButton.readPermissions = ["email", "public_profile"]
    }

}


extension AuthenticateViewController: FBSDKLoginButtonDelegate{
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            self.showDefaultAlert(message: "\(error.localizedDescription)")
            return
        }
        
        guard FBSDKAccessToken.current() != nil else{
            self.showDefaultAlert(message: "Can not sign up with facebook account")
            return
        }
        
        // Send the token to the Milieu backend
        registerAccountInMilieu(fbToken: FBSDKAccessToken.current().tokenString){
            token, error in
            guard error == nil else{
                self.showDefaultAlert(message: "\(error.debugDescription)")
                return
            }
            
            guard token != nil else{
                self.showDefaultAlert(message: "Can not get token from Milieu")
                return
            }
            
            // Save token into keychain
            guard self.saveToken(token: token!) else{
                self.showDefaultAlert(message: "Keychain Error")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Handle Login Result
extension AuthenticateViewController{
    
    func registerAccountInMilieu(fbToken: String, completionHandler: @escaping (ApiToken?, Error?) -> Void){
        let parameters: Parameters = [
            "token":fbToken,
            "provider":"facebook"
        ]
        
        Alamofire.request("http://localhost:3000/api/v1/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON{
            response in
            
            let result = response.result
            switch response.result{
            case .success:
                completionHandler(ApiToken(dictionary: result.value as? JSONDictionary), nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func saveToken(token: ApiToken) -> Bool{
        let data = NSKeyedArchiver.archivedData(withRootObject: token)
        return KeychainWrapper.standard.set(data, forKey: "MilieuApiToken")
    }
    
    func showDefaultAlert(title: String = "Error", message: String){
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
            _ in
            self.performSegue(withIdentifier: "skipSignInSegue", sender: nil)
        }
        
        showAlert(title: title, message: message, cancelAction: cancelAction, okAction: okAction)
    }
    
    func showAlert(title: String, message: String, preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert, cancelAction: UIAlertAction?, okAction: UIAlertAction?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if let cancelAction = cancelAction {alertController.addAction(cancelAction)}
        if let okAction = okAction {alertController.addAction(okAction)}
        present(alertController, animated: true, completion: nil)
    }
}
