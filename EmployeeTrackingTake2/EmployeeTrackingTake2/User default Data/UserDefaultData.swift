//
//  UserDefaultData.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class UserDefaultData: NSObject {
    
    static let sharedInstance = UserDefaultData()
    
    
    func setUserCompany(company:String){
        UserDefaults.standard.set(company, forKey: "company")
    }
    
    func setUserID(id:String){
        UserDefaults.standard.set(id, forKey: "id")
    }
    
    
    func getUserCompany() ->String{
        if(UserDefaults.standard.object(forKey: "company") != nil){
            return UserDefaults.standard.object(forKey: "company") as! String
        }else{
            return ""
        }
    }
    
    func getUserId() ->String{
        if(UserDefaults.standard.object(forKey: "id") != nil){
            return UserDefaults.standard.object(forKey: "id") as! String
        }else{
            return ""
        }
        
    }
    
    
    
    func deleteUserCompany(){
        UserDefaults.standard.removeObject(forKey: "company")
    }
    
    func deleteUserID(){
        UserDefaults.standard.removeObject(forKey: "id")
    }
    
    
    

}
