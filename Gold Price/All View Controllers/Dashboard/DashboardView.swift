//
//  DashboardView.swift
//  Gold Price
//
//  Created by Laptop World on 27/04/2016.
//  Copyright © 2016 Geek Sol. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class DashboardView: UIViewController,UITableViewDataSource,UITableViewDelegate,CountryPhoneCodePickerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    // MARK: Properties
    private var metals:NSMutableDictionary = NSMutableDictionary()
    private var selectedCurrency:String = NSUserDefaults.standardUserDefaults().objectForKey(Constants.Defaults.SELECTED_CURRENCY)as!String
    private var selectedUnit:String = NSUserDefaults.standardUserDefaults().objectForKey(Constants.Defaults.SELECTED_UNIT)as!String
    private var txtFieldCurrency:UITextField = UITextField(frame: CGRectZero)
    private var txtFieldUnit:UITextField = UITextField(frame: CGRectZero)
    private var currencyPicker: CountryPicker? = nil
    private var unitPicker:UIPickerView?=nil
    private let units=["Gram","Kilogram","Ounce","P.Wt"]
    @IBOutlet weak var btnUnitPicker: UIButton!
    @IBOutlet weak var btnCurrencyPicker: UIButton!
    @IBOutlet private weak var tblView: UITableView!
// MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCurrencyPicker()
        self.setupUnitPicker()
        self.fetchMetalsData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let metal:Metal = self.metals[selectedCurrency]![indexPath.row] as! Metal
        let cell:MetalCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MetalCell
        cell.configMetal(metal,currencyType: selectedCurrency,unitType: selectedUnit)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
// MARK: - Helper Methods
    func fetchMetalsData(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, Constants.API.BASE_URL, parameters: nil)
            .responseJSON { response in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
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
// MARK: - ActonMethods
    
    @IBAction func btnRefreshAction(sender: AnyObject) {
        self.fetchMetalsData()
    }
    
    @IBAction func btnCurrencyPickerAction(sender: AnyObject) {
        txtFieldCurrency.becomeFirstResponder()
    }
    
    @IBAction func bntUnitPickerAction(sender: AnyObject) {
        txtFieldUnit.becomeFirstResponder()
    }
    func setupCurrencyPicker() {
        self.view.addSubview(txtFieldCurrency)
        currencyPicker = CountryPicker(frame: CGRectMake(0, 200, view.frame.width, 300))
        currencyPicker!.backgroundColor = .whiteColor()
        currencyPicker!.showsSelectionIndicator = true
        currencyPicker!.countryPhoneCodeDelegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(currencyPickerDoneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(currencyPickerCancelTapped))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        txtFieldCurrency.inputView = currencyPicker
        txtFieldCurrency.inputAccessoryView = toolBar
        currencyPicker?.selectRowWithCode(selectedCurrency)
    }
    func setupUnitPicker() {
        self.view.addSubview(txtFieldUnit)
        unitPicker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
        unitPicker!.backgroundColor = .whiteColor()
        unitPicker!.showsSelectionIndicator = true
        unitPicker?.dataSource=self
        unitPicker?.delegate=self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(unitPickerDoneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(unitPickerCancelTapped))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        txtFieldUnit.inputView = unitPicker
        txtFieldUnit.inputAccessoryView = toolBar
        //unitPicker?.selectRowWithCode(selectedCurrency)
    }
    func currencyPickerDoneTapped() {
        let country:Country = currencyPicker!.selectedCountry()
        selectedCurrency = country.code!
        btnCurrencyPicker.setImage(UIImage(named: selectedCurrency), forState: .Normal)
        txtFieldCurrency.resignFirstResponder()
        tblView.reloadData()
        NSUserDefaults.standardUserDefaults().setObject(selectedCurrency, forKey: Constants.Defaults.SELECTED_CURRENCY)
    }
    func currencyPickerCancelTapped() {
        txtFieldCurrency.resignFirstResponder()
        currencyPicker?.selectRowWithCode(selectedCurrency)
    }
    func unitPickerDoneTapped() {
        selectedUnit = units[(unitPicker?.selectedRowInComponent(0))!]
        btnUnitPicker.setTitle(selectedUnit, forState: .Normal)
        txtFieldUnit.resignFirstResponder()
        tblView.reloadData()
        NSUserDefaults.standardUserDefaults().setObject(selectedUnit, forKey: Constants.Defaults.SELECTED_UNIT)
    }
    func unitPickerCancelTapped() {
        txtFieldUnit.resignFirstResponder()
        //currencyPicker?.selectRowWithCode(selectedCurrency)
    }
// MARK: - Currency PickerDelegate
    func countryPhoneCodePicker(picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String){
//        btnCurrencyPicker.setImage(UIImage(named: countryCode), forState: .Normal)
    }
// MARK: - Unit PickerDelegate/Datasource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{return 1}
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return units.count
    }
//    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
//        return NSAttributedString (string: units[row])
//    }
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return units[row]
    }
}


