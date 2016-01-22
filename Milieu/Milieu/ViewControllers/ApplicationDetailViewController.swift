//
//  ApplicationDetailViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import UIKit

class ApplicationDetailViewController: UIViewController {
    
    var annotation: ApplicationInfo!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var applicationTypeLabel: UILabel!
    @IBOutlet weak var applicationIdLabel: UILabel!
    @IBOutlet weak var reviewStatusLabel: UILabel!
    @IBOutlet weak var statusDataLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var applicationImageView: UIImageView!
    
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
            statusDataLabel.text = DateUtil.transformStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .MediumStyle, stringFormat: MilieuDateFormat.UTCStandardFormat)
            
        }else{
            statusDataLabel.text = "Unknown"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        AR5Logger.debug("Deinit the view!")
        applicationImageView = nil
        titleLabel = nil
        applicationTypeLabel = nil
    }
    
    @IBAction func commentBtnDidTap(sender: AnyObject) {
        let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
        commentsController.devSiteId = annotation.devSiteUid
        popupController?.pushViewController(commentsController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
