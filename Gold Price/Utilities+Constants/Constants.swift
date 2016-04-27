//
//  Constants.swift
//  Gold Price
//
//  Created by Laptop World on 27/04/2016.
//  Copyright © 2016 Geek Sol. All rights reserved.
//

import Foundation
struct Constants {
    
    struct API {
        static let BASE_URL = "https://www.xmlcharts.com/cache/precious-metals.php?format=json"
        static let GetRealTimeMetalQuotes = "GetRealTimeMetalQuotes"
        static let GetChartGold = "https://www.quandl.com/api/v3/datasets/BUNDESBANK/BBK01_WT5511.json?start_date=2016-01-01"
        static let TOKEN = "2FF98060B7A14493BBE1091AFF027082"
    }
    
    struct Defaults{
        static let SELECTED_UNIT = "selectedUnit"
        static let SELECTED_CURRENCY = "selectedCurrency"
    }
}