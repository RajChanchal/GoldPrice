//
//  ChartsView.swift
//  Gold Price
//
//  Created by Laptop World on 27/04/2016.
//  Copyright © 2016 Geek Sol. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import SwiftChart
class ChartsView: UIViewController,ChartDelegate  {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var chartGold: Chart!
    private var labelLeadingMarginInitialConstant: CGFloat!
    private var goldValues:Array<NSMutableDictionary>= []
    override func viewDidLoad() {
        self.fetchChartsData()
//        let series = ChartSeries([0, 6.5, 2, 8, 4.1, 7, -3.1, 10, 8])
//        chartGold.addSeries(series)
        
//        let data = [(x: 0, y: 0), (x: 0.5, y: 3.1), (x: 1.2, y: 2), (x: 2.1, y: -4.2), (x: 2.6, y: 1.1)]
//        let series = ChartSeries(data: data)
//        chartGold.addSeries(series)
//        chartGold.delegate=self
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        self.fetchChartsData()
        
        
    }
    
    // MARK: - Helper Methods
    func fetchChartsData(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, Constants.API.GetChartGold, parameters: nil)
            .responseJSON { response in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                switch response.result{
                    
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print("JSON: \(json)")
                        let jsonValues = json["dataset"]["data"]
                        // Parse data
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        
                        for (_,subJson):(String, JSON) in jsonValues {
                            //Do something you want
                            let dataDic:NSMutableDictionary = [:]
                            var index:Int=0
                            for (_,subSubJson):(String, JSON) in subJson{
                                
                                if(index==0){
                                    dataDic.setObject(dateFormatter.dateFromString(subSubJson.stringValue)!, forKey: "date")
                                }else
                                {
                                   dataDic.setObject(subSubJson.floatValue, forKey: "close")
                                }
                                index+=1
                            }
                            self.goldValues.append(dataDic)
                        }
                        self.initializeChart()
                    }
                    
                    
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                                   }
        }
    }
    
    func initializeChart() {
        chartGold.delegate = self
        
        // Initialize data series and labels
        let stockValues = goldValues
        
        var serieData: Array<Float> = []
        var labels: Array<Float> = []
        var labelsAsString: Array<String> = []
        
        // Date formatter to retrieve the month names
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM"
        
        for (i, value) in stockValues.enumerate() {
            
            serieData.append(value["close"] as! Float)
            
            // Use only one label for each month
            let month = Int(dateFormatter.stringFromDate(value["date"] as! NSDate))!
            let monthAsString:String = dateFormatter.monthSymbols[month - 1]
            if (labels.count == 0 || labelsAsString.last != monthAsString) {
                labels.append(Float(i))
                labelsAsString.append(monthAsString)
            }
        }
        
        let series = ChartSeries(serieData)
        series.area = true
        
        // Configure chart layout
        
        chartGold.lineWidth = 0.5
        chartGold.labelFont = UIFont.systemFontOfSize(12)
        chartGold.xLabels = labels
        chartGold.xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
            return labelsAsString[labelIndex]
        }
        chartGold.xLabelsTextAlignment = .Center
        chartGold.yLabelsOnRightSide = true
        // Add some padding above the x-axis
        if(serieData.count>0){
            chartGold.minY = serieData.minElement()! - 5
        
            chartGold.addSeries(series)
        }
        
    }
    // Chart delegate
    
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            label.text = numberFormatter.stringFromNumber(value)!
            
            // Align the label to the touch left position, centered
            var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
            
            // Avoid placing the label on the left of the chart
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - label.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }
            
            labelLeadingMarginConstraint.constant = constant
            
        }
        
    }
    
    func didFinishTouchingChart(chart: Chart) {
        label.text = ""
        labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Redraw chart on rotation
        chartGold.setNeedsDisplay()
        
    }

}