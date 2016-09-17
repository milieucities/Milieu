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
    func loadImageWithURL(url: String, completion:@escaping ()->Void){
        
        Alamofire.request(url, method: .get).responseData{
            response in
            if let data = response.result.value{
                DispatchQueue.main.async(execute: {
                    self.image = UIImage(data: data)
                    self.contentMode = .scaleAspectFill
                    completion()
                })
            }
        }
    }
}
