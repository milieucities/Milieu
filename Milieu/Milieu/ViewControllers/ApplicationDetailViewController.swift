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
    
    @IBOutlet weak var applicationImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
        applicationTypeLabel.text = annotation.type
        applicationIdLabel.text = annotation.devId
        reviewStatusLabel.text = annotation.newestStatus
        descriptionTextView.text = annotation.generalDescription
        
        if let date = annotation.newestDate{
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            if let dateObject = dateFormatter.dateFromString(date){
                statusDataLabel.text = NSDateFormatter.localizedStringFromDate(dateObject, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
            }else{
                statusDataLabel.text = date
            }
            
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
        popupController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsViewController"), animated: true)
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
