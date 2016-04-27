//
//  MetalCell.swift
//  Gold Price
//
//  Created by Laptop World on 27/04/2016.
//  Copyright © 2016 Geek Sol. All rights reserved.
//

import UIKit
import MKUnits

class MetalCell: UITableViewCell {
    
    @IBOutlet weak var lblMetalName: UILabel!
    @IBOutlet weak var lblCurrentPrice: UILabel!
    var metal:Metal!
    
    func configMetal(metal:Metal,currencyType:String,unitType:String) {
        self.metal = metal
        lblMetalName.text = self.metal.metalName
        lblCurrentPrice.text = String("\(self.metal.metalPrice)")
        let localeComponents = [NSLocaleCurrencyCode: currencyType]
        let localeIdentifier = NSLocale.localeIdentifierFromComponents(localeComponents)
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        let currencySymbol = locale.objectForKey(NSLocaleCurrencySymbol) as! String
        var unit:String=""
        var unitValue:Double=self.metal.metalPrice
        if(unitType=="Gram"){
            unit="g"
        }else if(unitType=="Ounce"){
            unit="oz"
            unitValue = self.convertGramToKgRate(unitValue)
            
        }else if(unitType=="Kilogram"){
            unit="kg"
            unitValue = self.convertGramToKgRate(unitValue)
        }else if(unitType=="P.Wt"){
            unit="pw"
            unitValue = self.convertGramToPennyWeightRate(unitValue)
        }
        lblCurrentPrice.text = String("\(currencySymbol)\(unitValue)/\(unit)")
    }
    func convertGramToPennyWeightRate(gramRate:Double) -> Double {
        return Double(round(1000*(gramRate*1.55517))/1000)
    }
    func convertGramToKgRate(gramRate:Double) -> Double {
        return Double(round(1000*(gramRate*1000))/1000)
    }
    func convertGramToOunceRate(gramRate:Double) -> Double {
        return Double(round(1000*(gramRate*28.3495))/1000)
    }
}