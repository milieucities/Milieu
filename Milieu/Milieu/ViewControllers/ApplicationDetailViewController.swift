//
//  ApplicationDetailViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire
import STPopup

enum BackStatus{
    case empty
    case like
    case dislike
}

class ApplicationDetailViewController: UIViewController {
    
    var annotation: ApplicationInfo!
    var devSite: DevSite {
        get{
            return annotation.devSite
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var applicationTypeLabel: UILabel!
    @IBOutlet weak var applicationIdLabel: UILabel!
    @IBOutlet weak var reviewStatusLabel: UILabel!
    @IBOutlet weak var statusDataLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var upHeartButton: UIButton!
    
    @IBOutlet weak var applicationImageView: UIImageView!
    
//    var activityIndicator: NVActivityIndicatorView!
    
    var backStatus: BackStatus = BackStatus.empty
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initData()
    }
    
    func initData(){
        // Get the first part of the title string
        // i.e. if the title is '70 Richmond Road, Ottawa, Ontario, Canada', then this will only
        // take the '70 Richmond Road'
        titleLabel.text = (devSite.address ?? "N/A").characters.split(separator: ",").map(String.init)[0]
        applicationTypeLabel.text = devSite.applicationType
        applicationIdLabel.text = devSite.devId
        reviewStatusLabel.text = devSite.status
        descriptionTextView.text = devSite.description ?? "N/A"
        statusDataLabel.text = devSite.statusDate
        if annotation.category == AnnotationCategory.InComment{
            commentButton.isHidden = false
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detail", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ApplicationDetailViewController.detailBtnDidTap))
        
//        activityIndicator = NVActivityIndicatorView(frame:CGRect(x: 0, y: 0, width: 30, height: 30), type: .BallGridBeat, color: UIColor(red:158.0/255.0, green:211.0/255.0, blue:225.0/255.0, alpha:1))
//        activityIndicator.center = applicationImageView.convertPoint(applicationImageView.center, fromView: applicationImageView)
//        activityIndicator.hidesWhenStopped = true
//        applicationImageView.addSubview(activityIndicator)
    }
    
    func detailBtnDidTap(){
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let detailController = navController.topViewController as! FullDetailController
        detailController.annotation = annotation
        present(navController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchImage()
    }

    
    func fetchImage(){
        
        
        guard let url = devSite.imageUrl else{
            return
        }
        
        let escapeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let resizeUrl = (escapeUrl as NSString).replacingOccurrences(of: "size=600x600", with: "size=500x250")
        
//        activityIndicator.startAnimation()
        
        self.applicationImageView.loadImageWithURL(url: resizeUrl){
            
//            self.activityIndicator.stopAnimation()
        }
    }
    
    
    deinit{
        AR5Logger.debug("Deinit the view!")
        applicationImageView = nil
        titleLabel = nil
        applicationTypeLabel = nil
//        activityIndicator = nil
    }
    
    @IBAction func commentBtnDidTap(_ sender: AnyObject) {
//        let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
//        commentsController.devSiteId = annotation.devSiteUid
//        popupController?.pushViewController(commentsController, animated: true)
    }
    
}
