import UIKit

protocol CountryPhoneCodePickerDelegate {
    func countryPhoneCodePicker(picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String)
}

struct Country {
    var code: String?
    var name: String?
    var phoneCode: String?
    
    init(code: String?, name: String?, phoneCode: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
    }
}

class CountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countries: [Country]!
    var countryPhoneCodeDelegate: CountryPhoneCodePickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        super.dataSource = self;
        super.delegate = self;
        
        countries = countryNamesByCode()
    }
    
    // MARK: - Country Methods
    
    func setCountry(code: String) {
        var row = 0
        for index in 0..<countries.count {
            if countries[index].code == code {
                row = index
                break
            }
        }
        
        self.selectRow(row, inComponent: 0, animated: true)
    }
    
    func countryNamesByCode() -> [Country] {
        var countries = [Country]()
        let allowedCountries:[String] = ["AUD","BRL","CAD","CHF","CNY","EUR","GBP","INR","JPY","MXN","RUB","USD","ZAR"]
        for code in NSLocale.ISOCurrencyCodes() {
            let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCurrencyCode, value: code)
            if(allowedCountries.contains(code)){
                let country = Country(code: code, name: countryName, phoneCode: code)
                countries.append(country)
            }
        }
        
        countries = countries.sort({ $0.name < $1.name })
        return countries
    }
    
    // MARK: - Picker Methods

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var resultView: CountryView
        
        if view == nil {
            resultView = (NSBundle.mainBundle().loadNibNamed("CountryView", owner: self, options: nil)[0] as! CountryView)
        } else {
            resultView = view as! CountryView
        }
        
        resultView.setup(countries[row])
        
        return resultView
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = countries[row]
        if let countryPhoneCodeDelegate = countryPhoneCodeDelegate {
            countryPhoneCodeDelegate.countryPhoneCodePicker(self, didSelectCountryCountryWithName: country.name!, countryCode: country.code!, phoneCode: country.phoneCode!)
        }
    }
    func selectedCountry() -> Country {
        return countries[self.selectedRowInComponent(0)]
    }
    func selectRowWithCode(code:String) {
        var index:Int=0
        var found=false
        for country in countries{
            if(country.code==code){
                found=true
                break;
            }
            index += 1
        }
        if(found){
            self.selectRow(index, inComponent: 0, animated: false)
        }else{
            self.selectRow(0, inComponent: 0, animated: false)
        }
    }
}
