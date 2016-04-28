//
//  TodayViewController.swift
//  MetalValues
//
//  Created by Laptop World on 27/04/2016.
//  Copyright © 2016 Geek Sol. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding {
    private var metals:NSMutableDictionary = NSMutableDictionary()
    
    private var selectedCurrency:String!
    private var selectedUnit:String!
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(userDefaults.objectForKey(Constants.Defaults.SELECTED_CURRENCY) == nil){
            userDefaults.setObject("USD", forKey: Constants.Defaults.SELECTED_CURRENCY)
        }
        if(userDefaults.objectForKey(Constants.Defaults.SELECTED_UNIT) == nil){
            userDefaults.setObject("Gram", forKey: Constants.Defaults.SELECTED_UNIT)
        }
        userDefaults.synchronize()
        selectedCurrency = userDefaults.objectForKey(Constants.Defaults.SELECTED_CURRENCY)as!String
        selectedUnit = userDefaults.objectForKey(Constants.Defaults.SELECTED_UNIT)as!String
        // Do any additional setup after loading the view from its nib.
    }
    override func viewWillAppear(animated: Bool) {
        fetchMetalsData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        fetchMetalsData()
        completionHandler(NCUpdateResult.NewData)
    }
    func fetchMetalsData(){
        Alamofire.request(.GET, Constants.API.BASE_URL, parameters: nil)
            .responseJSON { response in
                switch response.result{
                    
                case .Success:
                    let json = JSON(data: response.data!)
                    self.metals.removeAllObjects()
                    for (key,subJson):(String, JSON) in json {
                        //self.metals.setValue(NSMutableArray(), forKey: key.uppercaseString)
                        self.metals.setObject(NSMutableArray(), forKey: key.uppercaseString)
                        for (subKey,subSubJson):(String, JSON) in subJson{
                            let metal:Metal = Metal(metalName: subKey,metalPrice: subSubJson.doubleValue)
                            self.metals[key.uppercaseString]?.addObject(metal)
                        }
                    }
                    self.tblView.reloadData()
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    //MARK: - Tableview Delegate & Datasource
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if self.metals.allKeys.count>0{
            return self.metals[selectedCurrency]!.count;
        }
        else{ return 0};
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let metalArray:NSMutableArray = self.metals[selectedCurrency] as! NSMutableArray
        let metal:Metal = metalArray[indexPath.row] as! Metal
        let cell:MetalCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MetalCell
        cell.configMetal(metal,currencyType: selectedCurrency,unitType: selectedUnit)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let url:NSURL  = NSURL(string: "liveGold://")!
        self.extensionContext?.openURL(url, completionHandler: nil)
    }
    
}
