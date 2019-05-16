//
//  CurrentUser.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/16/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class CurrentUser: NSObject {
    static let sharedInstance = CurrentUser()
    var userID:String?
    
    var userFirstName:String?
    var userLastName:String?
    var userNumber:Int?
    var userEmail:String?
    var userPhoneNumber:Int?
    var userStatus:Bool?
    var userJobs:[String]?
    
    
    func deleteUser(){
        userID = nil
        userFirstName = nil
        userLastName = nil
        userNumber = nil
        userEmail = nil
        userPhoneNumber = nil
        userStatus = nil
        userJobs = nil
        
        self.deleteUserDefaults()
    }
    
    func saveUserToDefaults(    ){
        UserDefaults.standard.set(userID, forKey: "userId")
        UserDefaults.standard.set(userFirstName, forKey: "userFirstName")
        UserDefaults.standard.set(userLastName, forKey: "userLastName")
        UserDefaults.standard.set(userNumber, forKey: "userNumber")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userPhoneNumber, forKey: "userPhoneNumber")
        UserDefaults.standard.set(userStatus, forKey: "userStatus")
        UserDefaults.standard.set(userJobs, forKey: "userJobs")
        
        print("saved!")
    }
    
    func loadUserDefaults() -> (String, String, String, String, Int, Int, Bool, [String]){
        let id = UserDefaults.standard.object(forKey: "userId") as! String
        let firstName = UserDefaults.standard.object(forKey: "userFirstName") as! String
        let lastName = UserDefaults.standard.object(forKey: "userLastName") as! String
        let email = UserDefaults.standard.object(forKey: "userEmail") as! String
        
        let uNumber = UserDefaults.standard.object(forKey: "userNumber") as! Int
        let phoneNumber = UserDefaults.standard.object(forKey: "userPhoneNumber") as! Int
        
        let status = UserDefaults.standard.object(forKey: "userStatus") as! Bool
        let jobs = UserDefaults.standard.object(forKey: "userJobs") as! [String]
        
        
        return (id, firstName, lastName, email, uNumber, phoneNumber, status, jobs)
    }
    
    func deleteUserDefaults(){
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userFirstName")
        UserDefaults.standard.removeObject(forKey: "userLastName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userNumber")
        UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        UserDefaults.standard.removeObject(forKey: "userStatus")
        UserDefaults.standard.removeObject(forKey: "userJobs")
    }
}
