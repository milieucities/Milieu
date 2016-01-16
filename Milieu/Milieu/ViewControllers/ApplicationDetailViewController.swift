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
    @IBOutlet weak var applicationImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
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
