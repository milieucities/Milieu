//
//  CommentCell.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CommentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBAction func likeComment(_ sender: Any) {
        like()
    }
    
    @IBAction func dislikeComment(_ sender: Any) {
        dislikeButtonIsPressed()
    }
    
    var userId: Int?
    var commentId: Int!
    var votedDown: Bool = false
    var votedUp: Bool = false
    
    let accountMgr = AccountManager.sharedInstance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if votedUp{
            likeButton.setTitleColor(Color.primary, for: .normal)
        }
        
        if votedDown{
            dislikeButton.setTitleColor(Color.primary, for: .normal)
        }
    }
    
    func likeButtonIsPressed(){
        votedUp = true
        votedDown = false
        likeButton.setTitleColor(Color.primary, for: .normal)
        dislikeButton.setTitleColor(Color.lightGray, for: .normal)
        voteCountLabel.text = String(Int(voteCountLabel.text!)! + 1)
    }
    
    func dislikeButtonIsPressed(){
        votedUp = false
        votedDown = true
        likeButton.setTitleColor(Color.lightGray, for: .normal)
        dislikeButton.setTitleColor(Color.primary, for: .normal)
        voteCountLabel.text = String(Int(voteCountLabel.text!)! - 1)
    }
    
    func like(){
        let headers: HTTPHeaders = [
            "Authorization": accountMgr.fetchToken()?.jwt! ?? "",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "comment_id": commentId,
            "up": true
        ]
        
        let url = Connection.VoteUrl
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON{
            response in
            
            let result = response.result
            
            debugPrint(response)
            switch result{
            case .success:
                self.likeButtonIsPressed()
                break
            case .failure:
                let message = JSON.init(data: response.data!)["description"].stringValue
                debugPrint(message)
                break
            }
        }
    }
    
    func dislike(){
//        let headers: HTTPHeaders = [
//            "Authorization": accountMgr.fetchToken()?.jwt! ?? ""
//        ]
//        
//        let url = Connection.VoteUrl + "/\(commentId)"
//        
//        Alamofire.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON{
//            response in
//            
//            let result = response.result
//            
//            debugPrint(response)
//            switch result{
//            case .success:
//                self.likeButtonIsPressed()
//                break
//            case .failure:
//                let message = JSON.init(data: response.data!)["description"].stringValue
//                debugPrint(message)
//                break
//            }
//        }
    }
}
