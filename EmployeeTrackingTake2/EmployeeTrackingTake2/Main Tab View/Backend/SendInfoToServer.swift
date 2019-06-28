//
//  SendInfoToServer.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/24/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@objc protocol ReturnStatusOfLogout{
    func returnLogOutStatus(done:Bool)
}

class SendInfoToServer: NSObject {

    var dayMonthYear:DateFormatter?
    var hourMinute:DateFormatter?
    
    var delegate:ReturnStatusOfLogout?

    override init() {
        super.init()
        
        dayMonthYear = DateFormatter()
        dayMonthYear?.dateFormat = "MM-dd-yyyy"
        
        hourMinute = DateFormatter()
        hourMinute?.dateFormat = "HH:mm"
    }

    
    
    func changeStatusInFirebase(status:Bool, userId:String, userCompany:String){

        let db = Firestore.firestore()

        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)
        
        let ref = db.collection("companies").document(userCompany).collection("employees").document(userId)
        
        // logging in //
        if(status){
            
            let objectToServer = "{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"Logged In\", \"jobAddress\": \"Offsite\", \"jobId\": \"Offsite\"}"
            
            
            ref.updateData(["status": status, "jobHistory": FieldValue.arrayUnion([objectToServer])]) { (error) in
                if(error == nil){
                    print("good to go")
                }
            }
            
            
        // logging off //
        }else{

            // generating an object to send to the server //
            let objectToServer = "{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"Logged Off\", \"jobAddress\": \"Offsite\", \"jobId\": \"Offsite\"}"
            
            ref.updateData(["status": status, "jobsCurrentlyAt": "", "jobHistory": FieldValue.arrayUnion([objectToServer])]){err in
                if err != nil{
                    print("error writting to document \(err.debugDescription)")
                    
                }else{

                    let firebaseAuth = Auth.auth()
                    do{
                    
                        // signing out of firebase //
                        try firebaseAuth.signOut()
                        
                        
                    }catch let signOutError as NSError{
                        print("error signing out \(signOutError)")
                    }
                    
                    self.delegate?.returnLogOutStatus(done: true)

                }
            }
            
        }
    }
    
    
    
    // problem lies here //
    func sendInfoToServerAtJob(jobId:String, jobName:String, jobAddress:String, isAtJob: Bool){
        let db = Firestore.firestore()

        let userId = UserDefaults.standard.object(forKey: "id") as! String
        let userCompany = UserDefaults.standard.object(forKey: "company") as! String
        
        
        
        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)

        let objectToServer = "{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"\(jobName)\", \"jobAddress\": \"\(jobAddress)\", \"jobId\": \"\(jobId)\"}"
        
        let ref = db.collection("companies").document(userCompany).collection("employees").document(userId)
        
        
        ref.updateData(["jobHistory": FieldValue.arrayUnion([objectToServer]), "jobsCurrentlyAt": jobName]){err in
            if(err != nil){
                print("error in updating \(err.debugDescription)")
            }else{
                
            }
        }
        
    }
    
    func sendInfoToServerOffJob(){
        
        let db = Firestore.firestore()
        
        let userId = UserDefaults.standard.object(forKey: "id") as! String
        let userCompany = UserDefaults.standard.object(forKey: "company") as! String
    
        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)

        let objectToServer = "{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"Offsite\", \"jobAddress\": \"Offsite\", \"jobId\": \"Offsite\"}"
        
        let ref = db.collection("companies").document(userCompany).collection("employees").document(userId)
        
        
        ref.updateData(["jobHistory": FieldValue.arrayUnion([objectToServer]), "jobsCurrentlyAt": "Offsite"]){err in
            if(err != nil){
                print("error in updating \(err.debugDescription)")
            }else{
                print("Good to go")
            }
        }
    }
}


