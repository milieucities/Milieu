//
//  UIView+Constraints.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-10-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

extension UIView{
    func addConstraintsWithFormat(format: String, options: NSLayoutFormatOptions = NSLayoutFormatOptions(), views: UIView...){
        var viewDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            viewDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: nil, views: viewDictionary))
    }
}
