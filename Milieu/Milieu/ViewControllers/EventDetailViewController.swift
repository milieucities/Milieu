//
//  EventDetailViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-22.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire

class EventDetailViewController: UIViewController {

    var annotation: EventInfo!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
        address1Label.text = annotation.address1
        address2Label.text = annotation.address2
        timeLabel.text = annotation.time
        contactLabel.text = annotation.email
        descriptionTextView.text = annotation.generalDescription
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchImage()
    }
    
    func fetchImage(){
        if annotation.title == nil{
            return
        }
        
        let escapeAddress = annotation.address2?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        
        let urlString = "https://maps.googleapis.com/maps/api/streetview?size=500x250&location=\(escapeAddress!)%2COttawa%2COntario$2CCanada"
        
        Alamofire.request(Method.GET, urlString).response{
            request, response, data, error in
            
            if let data = data{
                dispatch_async(dispatch_get_main_queue(),{
                    self.imageView.image = UIImage(data: data)
                    self.imageView.contentMode = .ScaleAspectFill
                    
                })
            }
            
        }
        
    }

}
