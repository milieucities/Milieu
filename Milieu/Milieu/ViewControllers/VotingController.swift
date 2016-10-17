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
        self.contentSizeInPopup = CGSize(width: 300, height: 400)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(VotingController.doneBtnDidTap))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationRatingView.delegate = self
        typeRatingView.delegate = self
        
//        addressLabel.text = annotation.title
//        typeLabel.text = annotation.type
//        applicationIdLabel.text = annotation.devId
//        reviewStatusLabel.text = annotation.newestStatus
//        if let date = annotation.newestDate{
//            
//            // Transform the date from UTC standard string to human readable string with medium style
//            statusDateLabel.text = DateUtil.transformStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
//            
//        }else{
//            statusDateLabel.text = "Unknown"
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationRate = Int(locationRatingView.rating)
        typeRate = Int(locationRatingView.rating)
    }
    
    func doneBtnDidTap(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitVoting(_ sender: AnyObject) {
        
//        let locationParams: [String: AnyObject] = ["score":locationRate, "dimension":"location", "klass":"DevSite", "id": annotation.devSiteUid!]
//        let typeParams: [String: AnyObject] = ["score":typeRate, "dimension":"app_type", "klass":"DevSite", "id": annotation.devSiteUid!]
//        submitButton.hidden = true
//        sendResults(locationParams)
//        sendResults(typeParams)
    }
    
    func sendResults(_ params: [String: AnyObject]){
        Alamofire.request(URL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.SubmitVoting.rawValue)")!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: Connection.AdditionalHttpHeaders).responseJSON{
            response in
            
            debugPrint(response.result.error)
            debugPrint(response.response)
            debugPrint(response.request)
            
            if params["dimension"] as! String == "app_type"{
                DispatchQueue.main.async(execute: {
                    
                    self.submitButton.isHidden = false
                    self.submitButton.setTitle("Done", for: .normal)
                    self.submitButton.isEnabled = false
                    self.delay(2.0){
                        self.submitButton.isHidden = true
                    }
                })
            }
        }
}
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
}

extension VotingController: FloatRatingViewDelegate{
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        if ratingView === locationRatingView{
            locationRate = Int(rating)
        }else if ratingView === typeRatingView{
            typeRate = Int(rating)
        }
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Float) {
        // Required delegate method
    }
}
