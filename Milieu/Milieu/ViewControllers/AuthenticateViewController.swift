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

    override func viewDidLoad() {
         super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        
        view.addSubview(loginButton)
        
        
        loginButton.frame = CGRect(x: 16, y:50, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}


extension AuthenticateViewController: FBSDKLoginButtonDelegate{
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        
        showEmailAddress()
    }
    
    func showEmailAddress(){
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start{
            (connection, result, err) in
            if err != nil{
                print("Failed to start graph request:", err)
                return
            }
            
            
            print(result)
            
            print(FBSDKAccessToken.current().tokenString)
        }
    }
}
