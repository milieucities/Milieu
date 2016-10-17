//
//  StatusesCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-30.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class StatusCell: DevSiteCell{
    static let cellId = "statusInfoCell"
    
    let statusTitle: UILabel = {
        return DevSiteCell.buildStandardLabel(text:"Status:", font: UIFont.boldSystemFont(ofSize: 12))
    }()
    
    let statusDateTitle: UILabel = {
        return DevSiteCell.buildStandardLabel(text:"Date:", font: UIFont.boldSystemFont(ofSize: 12))
    }()
    
    let statusLabel: UILabel = {
        return DevSiteCell.buildStandardLabel(alignment:.right)
    }()
    
    
    let statusDateLabel: UILabel = {
        return DevSiteCell.buildStandardLabel(alignment:.right)
    }()
    
    
    override func setupViews(){
        backgroundColor = UIColor.white

        addSubview(statusTitle)
        addSubview(statusDateTitle)
        addSubview(statusLabel)
        addSubview(statusDateLabel)
        
        
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-[v1]-8-|", options: NSLayoutFormatOptions.alignAllCenterY, views: statusTitle, statusLabel)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-[v1]-8-|", options: NSLayoutFormatOptions.alignAllCenterY, views: statusDateTitle, statusDateLabel)
        
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-[v1(v0)]-8-|", views: statusTitle, statusDateTitle)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-[v1(v0)]-8-|", options: NSLayoutFormatOptions.alignAllLeading, views: statusLabel, statusDateLabel)
    }
    
    override func fillData() {
        guard let latestStatusDict = devSite?.statuses?.first else {
            return
        }
        
        let latestStatus:String = (latestStatusDict["status"] as? String) ?? "N/A"
        let latestDate:String = (latestStatusDict["status_date"] as? String) ?? "N/A"
        
        statusLabel.text = latestStatus
        statusDateLabel.text = latestDate
    }
}
