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
        vote(up: true)
    }
    
    @IBAction func dislikeComment(_ sender: Any) {
        vote(up: false)
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
        votedUp = !votedUp
        votedDown = false
        likeButton.setTitleColor((votedUp ? Color.primary : Color.lightGray), for: .normal)
        dislikeButton.setTitleColor(Color.lightGray, for: .normal)
        voteCountLabel.text = String(Int(voteCountLabel.text!)! + (votedUp ? 1 : -1))
    }
    
    func dislikeButtonIsPressed(){
        votedUp = false
        votedDown = !votedDown
        likeButton.setTitleColor(Color.lightGray, for: .normal)
        dislikeButton.setTitleColor((votedDown ? Color.primary : Color.lightGray), for: .normal)
        voteCountLabel.text = String(Int(voteCountLabel.text!)! + (votedDown ? -1 : 1))
    }
    
    /**
     If up is true, then vote a up for the comment. Otherwise, vote a down for the comment.
    */
    func vote(up: Bool){
        let headers: HTTPHeaders = [
            "Authorization": accountMgr.fetchToken()?.jwt! ?? "",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "comment_id": commentId,
            "up": up
        ]
        
        let url = Connection.VoteUrl
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON{
            response in
            
            let result = response.result
            
            debugPrint(response)
            switch result{
            case .success:
                if up{
                    self.likeButtonIsPressed()
                }else{
                    self.dislikeButtonIsPressed()
                }
                break
            case .failure:
                let message = JSON.init(data: response.data!)["description"].stringValue
                debugPrint(message)
                break
            }
        }
    }
}
