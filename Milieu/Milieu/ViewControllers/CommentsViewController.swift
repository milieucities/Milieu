//
//  CommentsViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CommentsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!

    var devSiteComments = [ApplicationComments]()
    var devSite: DevSite!
    let accountMgr = AccountManager.sharedInstance
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.contentSizeInPopup = CGSize(width: 300, height: 400)
//        self.landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CommentsViewController.doneBtnDidTap))
//    }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        commentTextView.isScrollEnabled = false
    }
    
    func loadComments(){

        let headers: HTTPHeaders = [
            "Authorization": accountMgr.fetchToken()?.jwt! ?? ""
        ]
        
        let url = Connection.DevSiteUrl + "/\(devSite.id)" + "/comments"
        Alamofire.request(url, method: .get, headers: headers).responseJSON{
            response in
            
            let result = response.result
            
            debugPrint(response)
            switch result{
            case .success:
                let comments = JSON(result.value!)["comments"].arrayValue
                if comments.count > 0{
                    var appComments = [ApplicationComments]()
                    for comment in comments{
                        let commentObject = ApplicationComments(comment: comment)
                        appComments.append(commentObject)
                    }
                    self.devSiteComments = appComments
                    self.tableView.reloadData()
                }
                break
            case .failure:
                let message = JSON.init(data: response.data!)["message"].stringValue
                debugPrint(message)
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadComments()
    }
    
    
    func doneBtnDidTap(){
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func sendComment(_ sender: AnyObject) {
        if commentTextView.text.isEmpty{
            return
        }
        
        let commentString = commentTextView.text
        let newComment = ApplicationComments(content: commentString!)
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
    
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate{
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = devSiteComments[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = comment.userName
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
            label.text = "No one comment yet!"
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
