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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "neighbourTitleCell")! as UITableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "neighbourNameCell")! as UITableViewCell
            let neighbour = neighbourhoods[(indexPath as NSIndexPath).row - 1]
            
            cell.textLabel?.text = neighbour.name
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return neighbourhoods.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectNeighbourToMap"){
            let navController = segue.destination as! UINavigationController
            let mapController = navController.topViewController as! MapViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            mapController.selectedNeighbour = neighbourhoods[(indexPath as NSIndexPath).row - 1]
        }
    }
}
