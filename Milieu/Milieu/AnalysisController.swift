//
//  AnalysisController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-27.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import PNChart
import CoreGraphics
import QuartzCore
import Foundation

class AnalysisController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let item = PNPieChartDataItem(value: 50, color: UIColor(red: 255.0/255.0, green: 123.0/255.0, blue: 121.0/255.0, alpha: 1.0), description: "Support")
        let item2 = PNPieChartDataItem(value: 50, color: UIColor(red: 104.0/255.0, green: 163.0/255.0, blue: 255.0/255.0, alpha: 1.0), description: "Oppose")
        let items = [item, item2]
        let pieChart = PNPieChart(frame: CGRectMake(0, 0, 240, 240), items: items)
        pieChart.descriptionTextColor = UIColor.whiteColor()
        pieChart.descriptionTextShadowOffset = CGSizeMake(0, 0)
        pieChart.descriptionTextFont = UIFont(name: "AvenirNext-Heavy", size: 16.0)
        pieChart.strokeChart()
        containerView.addSubview(pieChart)
    }

    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
