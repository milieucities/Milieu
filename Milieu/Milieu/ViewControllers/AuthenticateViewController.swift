//
//  AuthenticatControllerViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-11-15.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import FBSDKLoginKit

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
            print(error)
            return
        }
        
        // TODO: Send the token to the Milieu backend
        // TODO: Get the JWT and save it in the Keychain
        
        self.dismiss(animated: true, completion: nil)
    }
}
