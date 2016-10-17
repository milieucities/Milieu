//
//  CardCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-29.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {


    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        cardSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func cardSetup(){
        cardView.alpha = 1.0
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 1
        cardView.layer.shadowOffset = CGSize(width: -1, height: 1)
        cardView.layer.shadowRadius = 1
        
        cardView.layer.shadowOpacity = 0.2
        
    }
}
