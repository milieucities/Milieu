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

    let supportVsOppose:[PNPieChartDataItem] = [PNPieChartDataItem(value: 50, color: UIColor(red: 255.0/255.0, green: 123.0/255.0, blue: 121.0/255.0, alpha: 1.0), description: "Support"),
                            PNPieChartDataItem(value: 50, color: UIColor(red: 104.0/255.0, green: 163.0/255.0, blue: 255.0/255.0, alpha: 1.0), description: "Oppose")]
    
    let voterOccupation:[PNPieChartDataItem] = [PNPieChartDataItem(value: 10, color: UIColor(red:0.87, green:0.37, blue:0.43, alpha:1), description: "Researchers"),
                            PNPieChartDataItem(value: 20, color: UIColor(red:0.92, green:0.64, blue:0.62, alpha:1), description: "Others"),
                            PNPieChartDataItem(value: 30, color: UIColor(red:0.96, green:0.81, blue:0.69, alpha:1), description: "Students"),
                            PNPieChartDataItem(value: 5, color: UIColor(red:0.78, green:0.77, blue:0.67, alpha:1), description: "Goverment employees"),
                            PNPieChartDataItem(value: 40, color: UIColor(red:0.55, green:0.67, blue:0.61, alpha:1), description: "Urban Developer")]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func drawPieChart(chartView: UIView, legendView: UIView, items: [PNPieChartDataItem]){
        
        // Draw the Chart
        let chartWidth = min(chartView.frame.width, chartView.frame.height)
        let startPoint = (chartView.frame.width - chartWidth)/2
        
        print("Chart View Width: \(chartView.frame.size.width), Chart View Height: \(chartView.frame.size.height), ChartWidth: \(chartWidth), startPoint: \(startPoint), WholeViewWidth: \(view.frame.width)")
        let pieChart = PNPieChart(frame: CGRectMake(0, 0, chartWidth, chartWidth), items: items)
        pieChart.showOnlyValues = true
        pieChart.descriptionTextColor = UIColor.whiteColor()
        pieChart.descriptionTextShadowOffset = CGSizeMake(0, 0)
        pieChart.descriptionTextFont = UIFont(name: "AvenirNext-Heavy", size: 14.0)
        
        pieChart.strokeChart()
        chartView.addSubview(pieChart)
        
        // Draw the Legend
        pieChart.legendStyle = PNLegendItemStyle.Stacked
        pieChart.legendFont = UIFont(name: "AvenirNext", size: 10.0)
        pieChart.legendFontColor = UIColor.blackColor()
        let legend = pieChart.getLegendWithMaxWidth(legendView.frame.width)
        
        let startY = (legendView.frame.size.width - legend.frame.size.height) / 2
        legend.frame = CGRectMake(0, startY, legendView.frame.size.width, legendView.frame.size.height)
        
        legendView.addSubview(legend)
    }

}

extension AnalysisController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ChartCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)! as UITableViewCell
        if indexPath.row == 0{
            let title = cell.contentView.viewWithTag(101) as! UILabel
            title.text = "Support VS. Oppose"
            let chartView = cell.contentView.viewWithTag(102)! as UIView
            let legendView = cell.contentView.viewWithTag(103)! as UIView
            drawPieChart(chartView, legendView: legendView, items: supportVsOppose)
        }else if indexPath.row == 1{
            let title = cell.contentView.viewWithTag(101) as! UILabel
            title.text = "Voter's Occupation"
            let chartView = cell.contentView.viewWithTag(102)! as UIView
            let legendView = cell.contentView.viewWithTag(103)! as UIView
            drawPieChart(chartView, legendView: legendView, items: voterOccupation)

        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension AnalysisController: UINavigationBarDelegate{
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}