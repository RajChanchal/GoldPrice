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
class ChartsView: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        self.fetchChartsData()
    }
    
    // MARK: - Helper Methods
    func fetchChartsData() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, Constants.API.GetChartGold, parameters: nil)
            .responseJSON { response in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                switch response.result{
                    
                case .Success:
                    let json = JSON(data: response.data!)
                    print("Data: \(json)")
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
}