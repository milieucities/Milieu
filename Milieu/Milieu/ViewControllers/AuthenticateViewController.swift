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


class AuthenticateViewController: UIViewController {

    
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    let accountMgr = AccountManager.sharedInstance
    var firstTime: Bool = false
    
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
        accountMgr.updateToken(fbToken: FBSDKAccessToken.current().tokenString){
            token, errorMsg in
            guard errorMsg == nil else{
                self.showDefaultAlert(message: "Facebook authentication fail with error: \(errorMsg!)")
                return
            }
            
            guard token != nil else{
                self.showDefaultAlert(message: "Can not get token from Milieu")
                return
            }
            
            // Save token into keychain
            guard self.accountMgr.saveToken(token: token!) else{
                self.showDefaultAlert(message: "Keychain Error")
                return
            }
            
            if self.firstTime {
                self.performSegue(withIdentifier: Segue.authToMapSegue, sender: nil)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Handle Login Result
extension AuthenticateViewController{
    

    func showDefaultAlert(title: String = "Error", message: String){
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
            _ in
            self.performSegue(withIdentifier: Segue.authToMapSegue, sender: nil)
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
