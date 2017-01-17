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

class UserTableViewController: UITableViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasLogIn() {
            AR5Logger.debug( "FB UserID: \(FBSDKAccessToken.current().userID), FB TOKEN String: \(FBSDKAccessToken.current().tokenString), FB Token Refresh Date: \(FBSDKAccessToken.current().expirationDate))")
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, name"]).start(completionHandler: {
                connection, result, error in
                guard error == nil else {
                    AR5Logger.debug(error as! String)
                    return
                }
                
                if (result != nil) {
                    AR5Logger.debug(result.debugDescription)
                    self.userNameLabel.text = (result as! [String:Any])["name"] as? String
                }
            })
        }else{
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func hasLogIn() -> Bool{
        return (FBSDKAccessToken.current() != nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == 0 {
            FBSDKLoginManager().logOut()
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }

}
