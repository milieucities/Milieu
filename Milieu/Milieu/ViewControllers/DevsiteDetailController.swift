//
//  DevsiteDetailController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-10-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

private let cellId = "infoId"

class DevsiteDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var annotation: ApplicationInfo!
    var devSite: DevSite {
        get{
            return annotation.devSite
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        navigationItem.title = "Detail"
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        collectionView?.register(HeaderImageCell.self, forCellWithReuseIdentifier: HeaderImageCell.cellId)
        collectionView?.register(GeneralInfoCell.self, forCellWithReuseIdentifier: GeneralInfoCell.cellId)
        collectionView?.register(DescriptionCell.self, forCellWithReuseIdentifier: DescriptionCell.cellId)
        collectionView?.register(StatusCell.self, forCellWithReuseIdentifier: StatusCell.cellId)

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: DevSiteCell
        switch indexPath.row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderImageCell.cellId, for: indexPath) as! DevSiteCell
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: GeneralInfoCell.cellId, for: indexPath) as! DevSiteCell
        case 2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusCell.cellId, for: indexPath) as! DevSiteCell
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: DescriptionCell.cellId, for: indexPath) as! DevSiteCell
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DevSiteCell
        }
        
        cell.devSite = devSite
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.row {
        case 0:
            return CGSize(width: view.frame.width, height: 250)
        case 1:
            return CGSize(width: view.frame.width, height: 100)
        case 2:
            return CGSize(width: view.frame.width, height: 60)
        case 3:
            if let description = devSite.description{
                let rect = NSString(string: description).boundingRect(with: CGSize(width:view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil)
                return CGSize(width: view.frame.width, height: rect.height + DescriptionCell.staticHeight + 24)
            }
            
            return CGSize(width: view.frame.width, height: 200)
            
        default:
            return CGSize(width: view.frame.width, height: 200)
        }
    }

}

extension DevsiteDetailController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToCommentSegue" {
            let commentController = segue.destination as! CommentsViewController
            commentController.devSite = devSite
        }
    }
}
