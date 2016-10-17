//
//  DevSiteCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-10-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class DevSiteCell: UICollectionViewCell {
    
    var devSite: DevSite?{
        didSet{
            fillData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup the cell views
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        fatalError("setupViews() has not been implemented")
    }
    
    func fillData(){
        fatalError("fillData() has not been implemented")
    }
    
    static func buildStandardLabel(text: String = "", font: UIFont = UIFont.systemFont(ofSize: 12), alignment: NSTextAlignment = .left) -> UILabel{
        let label = UILabel()
        label.text = text
        label.font = font
        label.textAlignment = alignment
        return label
    }
}
