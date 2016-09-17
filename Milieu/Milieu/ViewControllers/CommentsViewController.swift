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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentSizeInPopup = CGSize(width: 300, height: 400)
        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CommentsViewController.doneBtnDidTap))
    }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        commentTextView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllComments()
    }
    
    
    func doneBtnDidTap(){
        self.dismiss(animated: true, completion: nil)
    }

    
    func displayComments(_ result: AnyObject){
        
        if let comments = ((result as! NSArray)[0] as! NSDictionary)["all_comments_of_devsite"] as? NSArray{
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
    
    @IBAction func sendComment(_ sender: AnyObject) {
        if commentTextView.text.isEmpty{
            return
        }
        
        let commentString = commentTextView.text
        let newComment = ApplicationComments(userName: "Jonny L. Digger", date: DateUtil.transformStringFromDate(DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.medium), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short, stringFormat: MilieuDateFormat.noFormat), content: commentString!, userAvatar: "jonny")
        devSiteComments.append(newComment)
        commentTextView.text = ""
        
        self.tableView.reloadData()
        
        let delay = 0.1 * Double(NSEC_PER_MSEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
            }
        })
        
    }
    
    // TODO: Server Communication
    func fetchAllComments(){
        
        AR5Logger.debug("DevSiteUID: \(devSiteId)")
        
        Alamofire.request(URL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.FetchCommentsForDevSite.rawValue)?dev_site_id=\(devSiteId)")!, method: .get).responseJSON{ response in
            
            DispatchQueue.main.async(execute: {
                
                if let result = response.result.value{
                    self.displayComments(result as AnyObject)
                }
            })
        }

    }
    
    func commitComment(_ message: String){
        
        Alamofire.request(URL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.FetchCommentsForDevSite.rawValue)?dev_site_id=\(devSiteId)")!, method: .get).responseJSON{ response in
            
            debugPrint(response.result.error)
            debugPrint(response.response)
            debugPrint(response.request)
            debugPrint(response.result.value)
            DispatchQueue.main.async(execute: {
            
            if let result = response.result.value{
            self.displayComments(result as AnyObject)
            }
            })
        }
    }
    
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate{
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = devSiteComments[(indexPath as NSIndexPath).row]
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devSiteComments.count
    }
    
    // MARK: - UITableViewDelegate
    
    
    func calculateHeightForConfiguredSizingCell(_ cell: UITableViewCell) -> CGFloat{
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if devSiteComments.count == 0{
            let label = UILabel(frame: CGRect(x: 0,y: 0,width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = ""
            label.textAlignment = .center
            label.sizeToFit()
            tableView.backgroundView = label
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            return 0
        }else{
            tableView.backgroundView = nil
            return 1
        }
        

    }
    
}
