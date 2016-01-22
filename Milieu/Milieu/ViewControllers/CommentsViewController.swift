//
//  CommentsViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire

class CommentsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!

    var devSiteComments = [ApplicationComments]()
    var devSiteId: Int!
    
    let serverUrl = "http://159.203.32.15"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneBtnDidTap")
    }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        commentTextView.scrollEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllComments()
    }
    
    
    func doneBtnDidTap(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func displayComments(result: AnyObject){
        
        if let comments = (result[0] as! NSDictionary)["all_comments_of_devsite"] as? NSArray{
            if comments.count > 0{
                var appComments = [ApplicationComments]()
                for comment in comments{
                    let commentObject = ApplicationComments(comment: comment as! NSDictionary)
                    appComments.append(commentObject)
                }
                devSiteComments = appComments
                tableView.reloadData()
            }else{
                // TODO: Add a empty view to saying that there is no comment yet
                AR5Logger.debug("No comments found")
            }
        }
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        if commentTextView.text.isEmpty{
            return
        }
        
        let commentString = commentTextView.text
        let newComment = ApplicationComments(userName: "Jonny L. Digger", date: DateUtil.transformStringFromDate(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.MediumStyle), dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle, stringFormat: MilieuDateFormat.NoFormat), content: commentString, userAvatar: "jonny")
        devSiteComments.append(newComment)
        commentTextView.text = ""
        
        self.tableView.reloadData()
        
        let delay = 0.1 * Double(NSEC_PER_MSEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.None, animated: true)
            }
        })
        
    }
    
    // TODO: Server Communication
    func fetchAllComments(){
        
        AR5Logger.debug("DevSiteUID: \(devSiteId)")
        
        Alamofire.request(.GET, NSURL(string: "\(serverUrl)\(RequestType.FetchCommentsForDevSite.rawValue)?dev_site_id=\(devSiteId)")!).responseJSON{
            response in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let result = response.result.value{
                    self.displayComments(result)
                }
            })
        }
        
    }
    
    func commitComment(message: String){
        Alamofire.request(.GET, NSURL(string: "\(serverUrl)\(RequestType.FetchCommentsForDevSite.rawValue)?dev_site_id=\(devSiteId)")!).responseJSON{
            response in
            
            debugPrint(response.result.error)
            debugPrint(response.response)
            debugPrint(response.request)
            debugPrint(response.result.value)
            dispatch_async(dispatch_get_main_queue(), {
                
                if let result = response.result.value{
                    self.displayComments(result)
                }
            })
        }

    }
    
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate{
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let comment = devSiteComments[indexPath.row]
        cell.nameLabel.text = comment.userName
        
        let dateString = comment.date
        cell.dateLabel.text = dateString
        if comment.userAvatar.isEmpty{
            cell.avatarImageView.image = nil
        }else{
            cell.avatarImageView.image = UIImage(named: comment.userAvatar)
        }
        
        cell.commentLabel.text = comment.content
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devSiteComments.count
    }
    
    // MARK: - UITableViewDelegate
    
    
    func calculateHeightForConfiguredSizingCell(cell: UITableViewCell) -> CGFloat{
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
