//
//  LocationSelectionViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-12.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit

class LocationSelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var backgroundColoredViews: [UIView]!
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        // Clear background colors from labels and buttons
        for view in backgroundColoredViews{
            view.backgroundColor = UIColor.clearColor()
        }
        
        pickerData = ["ottawa", "toronto", "montreal", "vancouver"]
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName: UIFont(name:"PingFang TC", size: 18.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()])
        return myTitle
    }
}
