//
//  CommentsViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!

    var comments = [ApplicationComments]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneBtnDidTap")
    }
    
    override func viewDidLoad() {
        comments = ApplicationComments.loadAllApplicationComments()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        commentTextView.scrollEnabled = false
    }
    
    
    func doneBtnDidTap(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        if commentTextView.text.isEmpty{
            return
        }
        
        let commentString = commentTextView.text
        let newComment = ApplicationComments(userName: "Jonny L. Digger", date: NSDate(), content: commentString, userAvatar: "jonny")
        comments.append(newComment)
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
    
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate{
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.nameLabel.text = comment.userName
        
        let dateString = NSDateFormatter.localizedStringFromDate(comment.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        cell.dateLabel.text = dateString
        cell.avatarImageView.image = UIImage(named: comment.userAvatar)
        cell.commentLabel.text = comment.content
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    // MARK: - UITableViewDelegate
    
    
    func calculateHeightForConfiguredSizingCell(cell: UITableViewCell) -> CGFloat{
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }

}
