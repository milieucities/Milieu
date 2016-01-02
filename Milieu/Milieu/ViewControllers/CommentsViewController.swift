//
//  CommentsViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class CommentsViewController: UITableViewController {

    var comments = [ApplicationComments]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSizeInPopup = CGSizeMake(300, 400)
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneBtnDidTap")
        comments = ApplicationComments.loadAllApplicationComments()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.nameLabel.text = comment.userName
        
        let dateString = NSDateFormatter.localizedStringFromDate(comment.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        cell.dateLabel.text = dateString
        cell.avatarImageView.image = UIImage(named: comment.userAvatar)
        cell.commentLabel.text = comment.content
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func doneBtnDidTap(){
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
