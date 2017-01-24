//
//  UserTableViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-11-15.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON

class UserTableViewController: UITableViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarView: FBSDKProfilePictureView!
    
    let accountMgr = AccountManager.sharedInstance

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if accountMgr.hasLogIn() {
            
            syncToken()
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, name"]).start(completionHandler: {
                connection, result, error in
                guard error == nil else {
                    return
                }
                
                if (result != nil) {
                    let json = JSON.init(result as Any)
                    self.userNameLabel.text = json["name"].stringValue
                }
            })
        }else{
            performSegue(withIdentifier: Segue.userToAuthSegue, sender: nil)
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    

    
    /**
     Check if need to update JWT token.
     Silently update token if needed.
    */
    func syncToken(){
        if accountMgr.token!.isExpire(){
            
            accountMgr.updateToken(fbToken: FBSDKAccessToken.current().tokenString){
                token, error in
                guard error == nil else{
                    return
                }
                
                guard token != nil else{
                    return
                }
                
                // Save token into keychain
                guard self.accountMgr.saveToken(token: token!) else{
                    return
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            FBSDKLoginManager().logOut()
            accountMgr.deleteToken()
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }

}
