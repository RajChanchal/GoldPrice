//
//  Metal.swift
//  Gold Price
//
//  Created by Laptop World on 27/04/2016.
//  Copyright © 2016 Geek Sol. All rights reserved.
//

import Foundation

class Metal{

// MARK: Properties
    var metalName: String = ""
    var metalPrice:Double = 0.0
    var metalCurrency:String = ""
    init(metalName:String,metalPrice:Double){
        self.metalName = metalName.capitalizedString
        self.metalPrice = metalPrice
    }
}