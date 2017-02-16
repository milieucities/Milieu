//
//  ApplicationDetailViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import UIKit
import STPopup
import NVActivityIndicatorView

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
    
    @IBOutlet weak var applicationImageView: UIImageView!
    
    var activityIndicator: NVActivityIndicatorView!
    
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
        
        activityIndicator = NVActivityIndicatorView(frame:CGRect(x: 0, y: 0, width: 30, height: 30), type: .orbit, color: UIColor(red:158.0/255.0, green:211.0/255.0, blue:225.0/255.0, alpha:1))
        
        applicationImageView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        applicationImageView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: applicationImageView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        applicationImageView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: applicationImageView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
    }
    
    func detailBtnDidTap(){
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let detailController = navController.topViewController as! DevsiteDetailController
//        detailController.devSite = devSite
        present(navController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let image = annotation.cacheSmallImage{
            applicationImageView.image = image
            applicationImageView.contentMode = .scaleAspectFill
        }else{
            fetchImage()
        }
    }

    
    func fetchImage(){
        
        
        guard let url = devSite.imageUrl else{
            return
        }
        
        let escapeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let resizeUrl = (escapeUrl as NSString).replacingOccurrences(of: "size=600x600", with: "size=500x250")
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        applicationImageView.loadImageWithURL(url: resizeUrl){
            self.annotation.cacheSmallImage = self.applicationImageView.image
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    @IBAction func commentBtnDidTap(_ sender: AnyObject) {
        let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsController.devSite = devSite
        popupController?.push(commentsController, animated: true)
    }
    
}
