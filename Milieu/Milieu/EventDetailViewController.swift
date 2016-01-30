//
//  EventDetailViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-22.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    var annotation: EventInfo!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
        address1Label.text = annotation.address1
        address2Label.text = annotation.address2
        timeLabel.text = annotation.time
        contactLabel.text = annotation.email
        descriptionTextView.text = annotation.generalDescription
    }

}
