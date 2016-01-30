//
//  LocationMenuController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-19.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class LocationMenuController: UITableViewController {
    
    var neighbourhoods: [Neighbourhood] = {
        return NeighbourManager.sharedManager.fetchNeighbourhoods()}()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let neighbourManager = NeighbourManager.sharedManager
        neighbourManager.currentNeighbour = neighbourhoods[indexPath.row - 1]
        neighbourManager.createRegionForCurrentNeighbourhood()
        
        if revealViewController() != nil{
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapNavigationViewController") as! UINavigationController
            revealViewController().pushFrontViewController(navController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("neighbourTitleCell")! as UITableViewCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("neighbourNameCell")! as UITableViewCell
            let neighbour = neighbourhoods[indexPath.row - 1] as Neighbourhood
            
            cell.textLabel?.text = neighbour.name
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return neighbourhoods.count
    }
}
