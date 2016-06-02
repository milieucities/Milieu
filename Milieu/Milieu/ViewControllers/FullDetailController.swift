//
//  FullDetailController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-29.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import Alamofire

class FullDetailController: UITableViewController{
    
    var annotation: ApplicationInfo!
    var cardSizeArray = [200, 228, 300, 272]
    
    // Header View
    private let kTableHeaderHeight: CGFloat = 200.0
    var headerView: UIView!
    
    override func viewDidLoad() {
        tableView.separatorColor = UIColor.clearColor()
    
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        
        fillHeader()
        updateHeaderView()
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight{
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("GeneralInfoCell") as! GeneralInfoCell
            cell.addressLabel.text = annotation.title
            cell.applicationTypeLabel.text = annotation.type
            cell.applicationIdLabel.text = annotation.devId
            cell.newestStatusLabel.text = annotation.newestStatus
            cell.statusDateLabel.text = DateUtil.transformStringFromDate(annotation.newestDate, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell") as! DescriptionCell
            cell.descriptionTextView.text = annotation.generalDescription
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("StatusesCell") as! StatusesCell
            
            let devApp = annotation.devApp
            let statuses = devApp.statuses?.reverse()
            let count = statuses?.count
            var statusKey = [String]()
            var statusDate = [String]()
            
            var i: Int = 0
            for i = 0; i < 6; i += 1{
                if i < count{
                    let status = statuses![i] as! Status
                    let date = status.statusDate!
                    let readableDate = DateUtil.transformStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
                    statusKey.append(status.status!)
                    statusDate.append(readableDate)
                }else{
                    statusKey.append("")
                    statusDate.append("")
                }
            }
            
            cell.status1Label.text = statusKey[0]
            cell.status2Label.text = statusKey[1]
            cell.status3Label.text = statusKey[2]
            cell.status4Label.text = statusKey[3]
            cell.status5Label.text = statusKey[4]
            cell.status6Label.text = statusKey[5]
            cell.date1Label.text = statusDate[0]
            cell.date2Label.text = statusDate[1]
            cell.date3Label.text = statusDate[2]
            cell.date4Label.text = statusDate[3]
            cell.date5Label.text = statusDate[4]
            cell.date6Label.text = statusDate[5]
            return cell
        }
    }
    
    func fillHeader(){
        let imageView = headerView.viewWithTag(1) as! UIImageView
        if let image = annotation.image{
            imageView.image = image
        }else{
            let escapeAddress = annotation.title?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            let urlString = "https://maps.googleapis.com/maps/api/streetview?size=500x250&location=\(escapeAddress!)%2COttawa%2COntario$2CCanada"
            if annotation.title == "350 Sparks Street"{
                imageView.image = UIImage(named: "350Sparks1")
            }else if annotation.title == "400 Albert Street"{
                imageView.image = UIImage(named: "400Albert1")
            }else{
                imageView.loadImageWithURL(urlString)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(cardSizeArray[indexPath.row] as Int)
    }

}
