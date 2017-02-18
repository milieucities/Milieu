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
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!

    var devSiteComments = [ApplicationComments]()
    var devSite: DevSite!
    var user: User?
    let accountMgr = AccountManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        commentTextView.isScrollEnabled = false
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = accountMgr.fetchUser()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    
    func loadComments(){

        let headers: HTTPHeaders = [
            "Authorization": accountMgr.token?.jwt! ?? ""
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
    


    
    func doneBtnDidTap(){
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func sendComment(_ sender: AnyObject) {
        if commentTextView.text.isEmpty{
            return
        }
        
        create(comment: commentTextView.text)
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate{
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = devSiteComments[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = comment.userName
        cell.commentLabel.text = comment.body
        cell.userId = comment.userId
        cell.commentId = comment.id
        
        // Truncate the date string
        let dateString = comment.createdAt
        let newEndIndex = dateString.index(dateString.endIndex, offsetBy: -4)
        let truncated = dateString.substring(to: newEndIndex)
        cell.dateLabel.text = DateUtil.transformStringFromDate(truncated, dateStyle: .medium, timeStyle: .short, stringFormat: .customizeFormat(format: "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone(abbreviation: "UTC")!))
        cell.voteCountLabel.text = String(comment.voteCount)
        cell.votedUp = (comment.votedUp == nil) ? false : true
        cell.votedDown = (comment.votedDown == nil) ? false : true
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            print("Deleted")
            let id: Int = (tableView.cellForRow(at: indexPath) as! CommentCell).commentId
            
            delete(comment: id, onSuccess: {
                self.devSiteComments.remove(at: indexPath.row)
                if self.devSiteComments.count == 0{
                    tableView.reloadData()
                }else{
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }, onFailure: { message in
                //Temp do nothing
            })
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (tableView.cellForRow(at: indexPath) as! CommentCell).userId == user?.id {
            return .delete
        }else{
            return .none
        }
    }
    
}

extension CommentsViewController{
    func create(comment: String){
        let headers: HTTPHeaders = [
            "Authorization": accountMgr.fetchToken()?.jwt! ?? "",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "body": comment
        ]
        
        let url = Connection.DevSiteUrl + "/\(devSite.id)" + "/comments"
        
        let request = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate()
        debugPrint(request)
        
        request.responseJSON{
            response in
            
            let result = response.result
            
            debugPrint(response)
            switch result{
            case .success:
                let comment = JSON(result.value!)
                let newComment = ApplicationComments(comment: comment)
                self.devSiteComments.insert(newComment, at: 0)
                self.commentTextView.text = ""

                self.tableView.reloadData()
                break
            case .failure:
                let message = JSON.init(data: response.data!)["description"].stringValue
                WhisperService.showWhisper(message: message, controller: self.navigationController!)
                break
            }
        }
    }
    
    func delete(comment:Int, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": accountMgr.token?.jwt! ?? ""
        ]

        let url = Connection.DevSiteUrl + "/\(devSite.id)" + "/comments" + "/\(comment)"
        
        Alamofire.request(url, method: .delete, headers: headers).validate().responseJSON{
            response in
            
            let result = response.result
            
            debugPrint(response)
            switch result{
            case .success:
                onSuccess()
            case .failure:
                let message = JSON.init(data: response.data!)["description"].stringValue
                debugPrint(message)
                onFailure(message)
            }
        }
    }
}
