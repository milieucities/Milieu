//
//  LocationSelectionViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-12.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit

class LocationSelectionViewController: UIViewController {
    
    @IBOutlet var backgroundColoredViews: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear background colors from labels and buttons
        for view in backgroundColoredViews{
            view.backgroundColor = UIColor.clearColor()
        }
    }
}
