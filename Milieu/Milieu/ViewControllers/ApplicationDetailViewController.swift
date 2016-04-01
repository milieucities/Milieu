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
import NVActivityIndicatorView

enum BackStatus{
    case Empty
    case Like
    case Dislike
}

class ApplicationDetailViewController: UIViewController {
    
    var annotation: ApplicationInfo!

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
    
    var activityIndicator: NVActivityIndicatorView!
    
    var backStatus: BackStatus = BackStatus.Empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
        applicationTypeLabel.text = annotation.type
        applicationIdLabel.text = annotation.devId
        reviewStatusLabel.text = annotation.newestStatus
        descriptionTextView.text = annotation.generalDescription
        if annotation.category == AnnotationCategory.InComment{
            commentButton.hidden = false
        }
        
        if let date = annotation.newestDate{
            
            // Transform the date from UTC standard string to human readable string with medium style
            statusDataLabel.text = DateUtil.transformStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
            
        }else{
            statusDataLabel.text = "Unknown"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detail", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ApplicationDetailViewController.detailBtnDidTap))
        
        activityIndicator = NVActivityIndicatorView(frame:CGRectMake(0, 0, 30, 30), type: .BallGridBeat, color: UIColor(red:158.0/255.0, green:211.0/255.0, blue:225.0/255.0, alpha:1))
        activityIndicator.center = applicationImageView.convertPoint(applicationImageView.center, fromView: applicationImageView)
        activityIndicator.hidesWhenStopped = true
        applicationImageView.addSubview(activityIndicator)
    }
    
    func detailBtnDidTap(){
        let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DetailNavigationController") as! UINavigationController
        let detailController = navController.topViewController as! FullDetailController
        detailController.annotation = annotation
        presentViewController(navController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchHeartLabel()
        fetchImage()
        
    }

    
    func fetchImage(){
        if annotation.title == nil{
            return
        }
        
        if annotation.title == "350 Sparks Street"{
            annotation.image = UIImage(named: "350Sparks1")
            self.applicationImageView.image = annotation.image
            self.applicationImageView.contentMode = .ScaleAspectFit
        }else if annotation.title == "400 Albert Street"{
            annotation.image = UIImage(named: "400Albert1")
            self.applicationImageView.image = annotation.image
            self.applicationImageView.contentMode = .ScaleAspectFit
        }else{
            
            if let image = annotation.image{
                self.applicationImageView.image = image
                self.applicationImageView.contentMode = .ScaleAspectFill
                return
            }else{
                let escapeAddress = annotation.title?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
                
                let urlString = "https://maps.googleapis.com/maps/api/streetview?size=500x250&location=\(escapeAddress!)%2COttawa%2COntario$2CCanada"
                
                activityIndicator.startAnimation()
                Alamofire.request(Method.GET, urlString).response{
                    request, response, data, error in
                    
                    if let data = data{
                        dispatch_async(dispatch_get_main_queue(),{
                            self.annotation.image = UIImage(data: data)
                            
                            self.applicationImageView.image = self.annotation.image
                            self.applicationImageView.contentMode = .ScaleAspectFill
                            self.activityIndicator.stopAnimation()
                            
                        })
                    }
                    
                }
            }
        }
    }
    
    func fetchHeartLabel(){
        Alamofire.request(.GET, NSURL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.Like.rawValue)?dev_site_id=\(annotation.devSiteUid!)")!, headers: Connection.AddictionalHttpHeaders)
        Alamofire.request(.GET, NSURL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.Dislike.rawValue)?dev_site_id=\(annotation.devSiteUid!)")!, headers: Connection.AddictionalHttpHeaders).responseJSON{
            response in
            
            if let _ = response.result.value as? NSArray{
                dispatch_async(dispatch_get_main_queue(),{
                    self.upHeartButton.setImage(UIImage(named: "heartEmpty"), forState: .Normal)
                    self.heartButton.setImage(UIImage(named: "upHeartEmpty"), forState: .Normal)
                })
            }
        }


    }
	
    
    deinit{
        AR5Logger.debug("Deinit the view!")
        applicationImageView = nil
        titleLabel = nil
        applicationTypeLabel = nil
        activityIndicator = nil
    }
    
    @IBAction func commentBtnDidTap(sender: AnyObject) {
        let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
        commentsController.devSiteId = annotation.devSiteUid
        popupController?.pushViewController(commentsController, animated: true)
    }
    
    @IBAction func votingBtnDidTap(sender: AnyObject) {
        let votingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VotingController") as! VotingController
        votingController.annotation = annotation
        popupController?.pushViewController(votingController, animated: true)
    }

    @IBAction func analysisBtnDidTap(sender: AnyObject) {
        let analysisController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AnalysisController") as! AnalysisController
        presentViewController(analysisController, animated: true, completion: nil)
    }
    

    @IBAction func upHeartBtnDidTap(sender: AnyObject) {
        if backStatus == BackStatus.Like{
            return
        }
        upHeartButton.enabled = true
        heartButton.enabled = true
        Alamofire.request(.GET, NSURL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.Like.rawValue)?dev_site_id=\(annotation.devSiteUid!)")!, headers: Connection.AddictionalHttpHeaders).responseJSON{
            response in
            
            if let _ = response.result.value as? NSArray{
                dispatch_async(dispatch_get_main_queue(),{
                    self.upHeartButton.enabled = true
                    self.heartButton.enabled = true
                    self.upHeartButton.setImage(UIImage(named: "heartFull"), forState: .Normal)
                    self.heartButton.setImage(UIImage(named: "upHeartEmpty"), forState: .Normal)
                    self.backStatus = .Like
                })
            }
        }

    }
    
    @IBAction func heartBtnDidTap(sender: AnyObject) {
        if backStatus == BackStatus.Dislike{
            return
        }
        upHeartButton.enabled = false
        heartButton.enabled = false
        Alamofire.request(.GET, NSURL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.Dislike.rawValue)?dev_site_id=\(annotation.devSiteUid!)")!, headers: Connection.AddictionalHttpHeaders).responseJSON{
            response in
            
            if let _ = response.result.value as? NSArray{
                dispatch_async(dispatch_get_main_queue(),{
                    self.upHeartButton.enabled = true
                    self.heartButton.enabled = true
                    self.upHeartButton.setImage(UIImage(named: "heartEmpty"), forState: .Normal)
                    self.heartButton.setImage(UIImage(named: "upHeartFull"), forState: .Normal)
                    self.backStatus = .Dislike
                })
            }
        }

    }
}
