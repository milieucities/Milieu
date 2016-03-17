//
//  VotingController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-22.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire

class VotingController: UIViewController {
    
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var applicationIdLabel: UILabel!
    @IBOutlet weak var reviewStatusLabel: UILabel!
    @IBOutlet weak var statusDateLabel: UILabel!
    
    @IBOutlet weak var locationRatingView: FloatRatingView!
    @IBOutlet weak var typeRatingView: FloatRatingView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var annotation: ApplicationInfo!
    var locationRate: Int!
    var typeRate: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneBtnDidTap")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationRatingView.delegate = self
        typeRatingView.delegate = self
        
        addressLabel.text = annotation.title
        typeLabel.text = annotation.type
        applicationIdLabel.text = annotation.devId
        reviewStatusLabel.text = annotation.newestStatus
        if let date = annotation.newestDate{
            
            // Transform the date from UTC standard string to human readable string with medium style
            statusDateLabel.text = DateUtil.transformStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
            
        }else{
            statusDateLabel.text = "Unknown"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationRate = Int(locationRatingView.rating)
        typeRate = Int(locationRatingView.rating)
    }
    
    func doneBtnDidTap(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitVoting(sender: AnyObject) {
        
        let locationParams: [String: AnyObject] = ["score":locationRate, "dimension":"location", "klass":"DevSite", "id": annotation.devSiteUid!]
        let typeParams: [String: AnyObject] = ["score":typeRate, "dimension":"app_type", "klass":"DevSite", "id": annotation.devSiteUid!]
        submitButton.hidden = true
        sendResults(locationParams)
        sendResults(typeParams)
    }
    
    func sendResults(params: [String: AnyObject]){
        
        Alamofire.request(.POST, NSURL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.SubmitVoting.rawValue)")!, parameters: params, headers: Connection.AddictionalHttpHeaders, encoding: .JSON).responseJSON{
            response in
            
            debugPrint(response.result.error)
            debugPrint(response.response)
            debugPrint(response.request)
            debugPrint(response.result.value?.boolValue)
            
            if params["dimension"] as! String == "app_type"{
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.submitButton.hidden = false
                    self.submitButton.setTitle("Done", forState: .Normal)
                    self.submitButton.enabled = false
                    self.delay(2.0){
                        self.submitButton.hidden = true
                    }
                })
            }
        }
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
}

extension VotingController: FloatRatingViewDelegate{
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        if ratingView === locationRatingView{
            locationRate = Int(rating)
        }else if ratingView === typeRatingView{
            typeRate = Int(rating)
        }
    }
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating: Float) {
        // Required delegate method
    }
}