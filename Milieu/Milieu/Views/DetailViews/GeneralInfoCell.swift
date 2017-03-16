//
//  GeneralInfoCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-10-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class GeneralInfoCell: DevSiteCell {
    
    static let cellId = "generalInfoCell"
    
    let addressLabel: UILabel = {
        return DevSiteCell.buildStandardLabel(font: UIFont.boldSystemFont(ofSize: 14))
    }()
    
    let devSiteIdTitle: UILabel = {
        return DevSiteCell.buildStandardLabel(text:"Application ID:", font: UIFont.boldSystemFont(ofSize: 12))
    }()
    
    let devSiteTypeTitle: UILabel = {
        return DevSiteCell.buildStandardLabel(text:"Application Type:", font: UIFont.boldSystemFont(ofSize: 12))
    }()
    
    let devSiteIdLabel: UILabel = {
        return DevSiteCell.buildStandardLabel(alignment:.right)
    }()
    
    let devSiteTypeLabel: UILabel = {
        return DevSiteCell.buildStandardLabel(alignment:.right)
    }()

    
    override func setupViews(){
        backgroundColor = UIColor.white
        
        addSubview(addressLabel)
        addSubview(devSiteIdTitle)
        addSubview(devSiteIdLabel)
        addSubview(devSiteTypeTitle)
        addSubview(devSiteTypeLabel)
        
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: addressLabel)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-[v1]-8-|", options: NSLayoutFormatOptions.alignAllCenterY, views: devSiteIdTitle, devSiteIdLabel)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-[v1]-8-|", options: NSLayoutFormatOptions.alignAllCenterY, views: devSiteTypeTitle, devSiteTypeLabel)
        
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-[v1]-8-[v2(v1)]-8-|", views: addressLabel, devSiteIdLabel, devSiteTypeLabel)
        addConstraintsWithFormat(format: "V:[v0]-8-[v1(v0)]-8-|", options: NSLayoutFormatOptions.alignAllTrailing, views: devSiteIdLabel, devSiteTypeLabel)
    }
    
    override func fillData() {
        addressLabel.text = devSite?.address
        devSiteIdLabel.text = devSite?.devId
        devSiteTypeLabel.text = devSite?.applicationType
    }
}
