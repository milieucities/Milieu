//
//  LocationSelectionViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-12.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

protocol LocationSelectionDelegate: class{
    func selectNeighbourhood(neighbourhood: Neighbourhood, withRegion region: MKCoordinateRegion?)
}

class LocationSelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var backgroundColoredViews: [UIView]!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectedLoctionBtn: UIButton!
    
    var coreDataStack: CoreDataStack!
    weak var delegate: LocationSelectionDelegate?
    
    var neighbourhoods: [Neighbourhood]!
    var selectedNeighbourhood: Neighbourhood?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        // Clear background colors from labels and buttons
        for view in backgroundColoredViews{
            view.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        neighbourhoods = NeighbourManager.sharedManager.fetchNeighbourhoods()
    }
    
    @IBAction func showLocation(sender: AnyObject) {
        if let neighbour = selectedNeighbourhood{
            let neighbourManager = NeighbourManager.sharedManager
            neighbourManager.currentNeighbour = neighbour
            neighbourManager.createRegionForCurrentNeighbourhood()
            self.delegate?.selectNeighbourhood(neighbour, withRegion: neighbourManager.currentRegion!)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            selectedLoctionBtn.setTitle("Please choose a location", forState: .Normal)
        }
        
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(DefaultsValue.UserCurrentLocation, forKey: DefaultsKey.SelectedNeighbour)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Populate Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return neighbourhoods.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return neighbourhoods[row].name
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = neighbourhoods[row].name!
        let myTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont(name:"PingFang TC", size: 18.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNeighbourhood = neighbourhoods[row]
        selectedLoctionBtn.setTitle("\(selectedNeighbourhood!.name!), OTTAWA", forState: .Normal)
    }
}

