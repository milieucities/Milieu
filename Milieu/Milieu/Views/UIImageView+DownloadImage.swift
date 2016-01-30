//
//  UIImageView+DownloadImage.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-30.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension UIImageView{
    func loadImageWithURL(url: String){
        
        Alamofire.request(Method.GET, url).response{
            request, response, data, error in
            
            if let data = data{
                dispatch_async(dispatch_get_main_queue(),{
                        self.image = UIImage(data: data)
                })
            }
            
        }
    }
}