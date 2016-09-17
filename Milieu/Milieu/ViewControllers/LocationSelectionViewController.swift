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
    func selectNeighbourhood(_ neighbourhood: Neighbourhood, withRegion region: MKCoordinateRegion?)
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
            view.backgroundColor = UIColor.clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        neighbourhoods = NeighbourManager.sharedManager.fetchNeighbourhoods()
    }
    
    @IBAction func useCurrentLocation(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Populate Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return neighbourhoods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return neighbourhoods[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = neighbourhoods[row].name!
        let myTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont(name:"PingFang TC", size: 18.0)!, NSForegroundColorAttributeName: UIColor.white])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNeighbourhood = neighbourhoods[row]
        selectedLoctionBtn.setTitle("\(selectedNeighbourhood!.name!), OTTAWA", for: UIControlState())
    }
}

