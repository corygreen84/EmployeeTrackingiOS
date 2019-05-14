//
//  TextFieldChecks.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/14/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class TextFieldChecks: NSObject {

    override init() {
        super.init()
    }
    
    func checkTextFieldForBlanks(text: String) -> Bool{
        if(text != ""){
            return true
        }else{
            return false
        }
    }
    
    func checkEmailFieldForCredentials(text: String) -> Bool{
        if(text.contains("@") && text.contains(".")){
            return true
        }else{
            return false
        }
    }
    
}
