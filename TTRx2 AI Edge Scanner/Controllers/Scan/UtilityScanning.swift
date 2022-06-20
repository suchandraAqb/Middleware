//
//  UtilityScanning.swift
//  MatrixScanBubblesSample
//
//  Created by Saugata Bhandari on 22/04/20.
//  Copyright © 2020 Scandit. All rights reserved.
//

import UIKit


class UtilityScanning: NSObject {
    static private let COMPONENT_CODE = "TTLIBS_UTILS_GS1_BARCODE_DECODER"
    /**
     * @desc GS1 Barcode
     *
     * @var string|null
     */
    var gs1_barcode : String? = nil

    /**
     * @desc Cleaned GS1 Barcode
     *
     * @var string
     */
    private var cleaned_gs1_barcode    = ""



    /**
     * @desc ASCII to clean
     *
     * @var array
     */
    private let ascii_to_clean : [UInt8]   = [9,10,13,32]



    /**
     * @desc Delimiter
     *
     * @var null
     */
    private var delimeter: Character? = nil

    /**
     * @desc Decoded Info
     *
     * @var array
     */
     var decoded_info = [String :[String : Any]]()



    /**
     * @desc ASCII to clean
     *
     * @var array
     */
     private let barcode_formats        = ["EAN-8", "EAN/UPC"]
    /**
    * @desc GS1 App Identifiers
    *
    * @var array|null
    */
    private let gs1_app_identifiers = [
        "00" : ["desc" : "Container Serial Number",     "length" : 18,    "is_fixed" : true ],
        "01" : ["desc" : "Product GTIN",                 "length" : 14, "is_fixed" : true     ],
        "10" : ["desc" : "Batch/Lot Number",             "length" : 20, "is_fixed" : false ],
        "11" : ["desc" : "Production Date",             "length" : 6,     "is_fixed" : true     ],
        "13" : ["desc" : "Packaging Date",             "length" : 6,     "is_fixed" : true     ],
        "15" : ["desc" : "Best Before Date",             "length" : 6,     "is_fixed" : true     ],
        "16" : ["desc" : "Sell By Date",                 "length" : 6,     "is_fixed" : true     ],
        "17" : ["desc" : "Expiration Date",             "length" : 6,     "is_fixed" : true     ],
        "21" : ["desc" : "SerialNumber",                 "length" : 20, "is_fixed" : false ]
    ]
    
    
    /**
    * @desc Parse Barcode
    *
    * @throws TTLibsException
    *
    * Error #: 001xx
    *
    */
    
    init(with barcodeString : String) {
        self.gs1_barcode = barcodeString
        super.init()
        self.parse_barcode()
    }
    
    private func parse_barcode(){
        self.clean_gs1()
        var cleaned_gs1_barcode = self.cleaned_gs1_barcode
        let original_cleaned_gs1_barcode = cleaned_gs1_barcode
        print(original_cleaned_gs1_barcode)
        
        // Check for delimeter
        let charArray : [Character] = Array(cleaned_gs1_barcode)
        if (charArray[0].asciiValue! < UInt8(48) || charArray[0].asciiValue! > UInt8(57))  {
            self.delimeter = charArray[0]
           // let index = self.cleaned_gs1_barcode.index(self.cleaned_gs1_barcode.endIndex, offsetBy: -10)
            let index = self.cleaned_gs1_barcode.index(self.cleaned_gs1_barcode.startIndex, offsetBy: 1)
            cleaned_gs1_barcode = String(self.cleaned_gs1_barcode.suffix(from: index))
        }
        let barcode_format  =  self.detect_barcode_format()
        if(!barcode_format.isEmpty && self.barcode_formats.contains(barcode_format)){
            print("This bar code does not work with the GS1 Barcode feature.")
            return
        }
        if ( self.delimeter == nil ) {
            // Default delimiter
            self.delimeter = Character(UnicodeScalar(29))

            if (!cleaned_gs1_barcode.contains(self.delimeter!) ){
                if (cleaned_gs1_barcode.contains("*") ) {
                    self.delimeter = "*"
                }else if (cleaned_gs1_barcode.contains(":") ) {
                    self.delimeter = ":"
                }else if (cleaned_gs1_barcode.contains("|") ) {
                    self.delimeter = "|"
                }
            }
        }
        if(cleaned_gs1_barcode.isEmpty){
            print("Invalid Barcode provided")
            return
        }
        repeat {
            let ai_prefix = String(cleaned_gs1_barcode.prefix(2))
            if(self.gs1_app_identifiers.keys.contains(ai_prefix)){
                let start = cleaned_gs1_barcode.index(cleaned_gs1_barcode.startIndex, offsetBy: 2)
                let length : Int = self.gs1_app_identifiers[ai_prefix]!["length"] as! Int
                
                var substr_component = ""
                if length + 2 > cleaned_gs1_barcode.count{
                    substr_component    =  String(cleaned_gs1_barcode.suffix(from: start))
                }else{
                    let end = cleaned_gs1_barcode.index(cleaned_gs1_barcode.startIndex, offsetBy: 2 + length)
                    let range = start..<end
                    substr_component    =  String(cleaned_gs1_barcode[range])
                }
                print(substr_component)
                if(substr_component.contains(self.delimeter!)){
                    if(self.gs1_app_identifiers[ai_prefix]!["is_fixed"] as! Bool){
                        print("Incorrect length of BarCode component")
                        return
                    }

                    substr_component  =  String(substr_component.prefix(upTo: substr_component.firstIndex(of:self.delimeter!)!))
                    let isValid =  self.validate_barcode_component(ai: ai_prefix, value: substr_component)
                    print(isValid)
                    if isValid {
                        let st = cleaned_gs1_barcode.index(cleaned_gs1_barcode.firstIndex(of: self.delimeter!)!, offsetBy: 1)
                        cleaned_gs1_barcode    = String(cleaned_gs1_barcode.suffix(from:st))
                        print(cleaned_gs1_barcode as Any)
                    }else{
                        return
                    }
                    
                }else{
                    // validate
                    let isValid =  self.validate_barcode_component(ai: ai_prefix, value: substr_component)
                    if(isValid){
                        //                        let st = cleaned_gs1_barcode.index(cleaned_gs1_barcode.firstIndex(of: self.delimeter!)!, offsetBy: 2)
                        //                        cleaned_gs1_barcode    = String(cleaned_gs1_barcode.suffix(from:st))
                        let length : Int = self.gs1_app_identifiers[ai_prefix]!["length"] as! Int
                        if length + 2  <= cleaned_gs1_barcode.count {
                            let index = cleaned_gs1_barcode.index(cleaned_gs1_barcode.startIndex, offsetBy: length + 2)
                            cleaned_gs1_barcode =  String(cleaned_gs1_barcode.suffix(from: index))
                        }else{
                            cleaned_gs1_barcode = ""
                        }
                        
                        print(cleaned_gs1_barcode as Any)
                    }else{
                        return
                    }
                    
                }
                if(!self.decoded_info.keys.contains(ai_prefix)){
                    print(["name" : self.gs1_app_identifiers[ai_prefix]!["desc"] as Any,"value" : substr_component] as Any)
                    self.decoded_info[ai_prefix] = ["name" : self.gs1_app_identifiers[ai_prefix]!["desc"] as! String,"value" : substr_component]
                }
                print(self.decoded_info as Any)

            }else{
                print("Unknown GS1 Application Identifier present in the BarCode.")
                return
            }

        } while(!cleaned_gs1_barcode.isEmpty)
    }
    
    /**
     * @desc Validate Barcode Component
     *
     * @param string $ai
     * @param string $value
     *
     * @return boolean
     * @throws TTLibsException
     */
    private func validate_barcode_component( ai: String, value : String ) -> Bool{
        
        if(!self.validate_length(ai: ai, value: value)){
            return false
        }
        switch (ai){
        case "11","13","15","16","17":
            return self.format_date(ai, value)
        default:
            return true
        }
        
    }
    
    /**
     * @desc Validate when the component is a Date
     *
     * @param    string            $ai
     * @param    string            $value
     *
     * @throws TTLibsException
     *
     * @return boolean
     *
     * Error #: 002xx
     */
    private func format_date(_ ai : String, _ value: String) -> Bool{
        //NOTE:param $ai use for future
        let valueNew = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (valueNew.count  < 6 ) {
            print("Invalid value received for a date field")
            return false
        }
        let valueCharArray : [Character] = Array(valueNew)
        
        let year    = "20" + String(valueCharArray[0]) + String(valueCharArray[1])
        let month    =  String(valueCharArray[2]) + String(valueCharArray[3])
        var day    =  String(valueCharArray[4]) + String(valueCharArray[5])
        
        let dtformatter = DateFormatter()
        dtformatter.dateFormat = "yyyy-MM-dd"
        if(day == "00"){
            day = "01"
        }
        guard let date_validate : Date = dtformatter.date(from: year + "-" + month + "-" + day) else {
            print("Invalid date format")
            return false
            
        }
        
        let dtformatter1 = ISO8601DateFormatter()
        if #available(iOS 11.0, *) {
            dtformatter1.formatOptions.insert(.withFractionalSeconds)
        } else {
            dtformatter1.formatOptions.insert(.withInternetDateTime)
            // Fallback on earlier versions
        }  // this is only available effective iOS 11 and macOS 10.13
        dtformatter1.timeZone = TimeZone(secondsFromGMT: 0)
        let isoDateString = dtformatter1.string(from: date_validate)
        print(isoDateString)
        decoded_info[ai]    =    [
            "name"    :    gs1_app_identifiers[ai]!["desc"] as! String,
            "value"    :    isoDateString
        ]
        return true
    }
    
    /**
     * @desc Validate Length
     * @param int     $ai
     * @param string $value
     *
     * @return boolean
     */
    private func validate_length( ai: String, value : String) -> Bool{
        //print(self.gs1_app_identifiers[ai]!["is_fixed"] as Any,"........",self.gs1_app_identifiers[ai]!["length"] as Any)
        if(self.gs1_app_identifiers[ai]!["is_fixed"] != nil && self.gs1_app_identifiers[ai]!["is_fixed"] as! Bool){
            if(self.gs1_app_identifiers[ai]!["length"] as! Int == value.count){
                return true
            }else{
                return false
            }
        }else if(self.gs1_app_identifiers[ai]!["length"] != nil){
            if(value.count > 0 && value.count <= self.gs1_app_identifiers[ai]!["length"] as! Int){
                return true
            }else{
                return false
            }
        }

        return false // In case of impossible condition
    }

    /**
     * @desc Cleaned GS1
     *
     */
    private func clean_gs1(){
        for char in Array(self.gs1_barcode!) {
            if(!self.ascii_to_clean .contains(char.asciiValue!)){
                self.cleaned_gs1_barcode += String(char)
            }
        }
    }
    /**
     * @desc Detect Barcode Format
     *
     * @return string|null
     * @throws TTException
     */
    private func detect_barcode_format() -> String{
        if NSPredicate(format: "SELF MATCHES %@", "/^[0-9]{8}$/").evaluate(with: self.cleaned_gs1_barcode) {
           return "EAN-8"
        }else  if NSPredicate(format: "SELF MATCHES %@", "/^[0-9]{12,13}$/").evaluate(with: self.cleaned_gs1_barcode) {
            return "EAN/UPC"
        }
       return ""
    }
}
