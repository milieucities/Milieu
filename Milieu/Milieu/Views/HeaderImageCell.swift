//
//  HeaderImageCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-30.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class HeaderImageCell: DevSiteCell {
    
    static let cellId = "headerCell"
    
    let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setupViews(){
        backgroundColor = UIColor.white
        addSubview(headerImageView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: headerImageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: headerImageView)
        
    }
    
    override func fillData() {
        fetchImage()
    }
    
    func fetchImage(){
        
        guard let url = devSite?.imageUrl else{
            return
        }
        
        let escapeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let resizeUrl = (escapeUrl as NSString).replacingOccurrences(of: "size=600x600", with: "size=600x300")
        
        self.headerImageView.loadImageWithURL(url: resizeUrl){}
    }
    
}
