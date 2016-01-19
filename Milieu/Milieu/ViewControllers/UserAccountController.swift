//
//  UserAccountController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-18.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class UserAccountController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil{
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
