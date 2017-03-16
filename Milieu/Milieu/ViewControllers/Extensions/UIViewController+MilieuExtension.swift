//
//  UIViewController+MilieuExtension.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2017-02-18.
//  Copyright © 2017 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
