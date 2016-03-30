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
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("neighbourTitleCell")! as UITableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("neighbourNameCell")! as UITableViewCell
            let neighbour = neighbourhoods[indexPath.row - 1]
            
            cell.textLabel?.text = neighbour.name
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return neighbourhoods.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SelectNeighbourToMap"){
            let navController = segue.destinationViewController as! UINavigationController
            let mapController = navController.topViewController as! MapViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            mapController.selectedNeighbour = neighbourhoods[indexPath.row - 1]
        }
    }
}
