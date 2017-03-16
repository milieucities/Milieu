//
//  DescriptionCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-30.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class DescriptionCell: DevSiteCell{
    static let cellId = "descriptionInfoCell"
    static let staticHeight: CGFloat = 8 + 24 + 8
    
    let titleLabel: UILabel = {
        return DevSiteCell.buildStandardLabel(text:"Description", font: UIFont.boldSystemFont(ofSize: 12))
    }()
    
    let detailView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.isScrollEnabled = false
        return textView
    }()
    
    
    override func setupViews(){
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addSubview(detailView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: titleLabel)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: detailView)
        
        addConstraintsWithFormat(format: "V:|-8-[v0(24)]-8-[v1]", views: titleLabel, detailView)
    }
    
    override func fillData() {
        detailView.text = devSite?.description
    }
}
