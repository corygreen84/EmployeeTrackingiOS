//
//  CurrentUser.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/16/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@objc protocol ReturnUserJobsDelegate{
    func returnUsersJobs(jobs: [Job])
    func usersJobsDoneLoading(done: Bool)
}

class CurrentUser: NSObject {
    static let sharedInstance = CurrentUser()
    var userID:String?
    var userCompany:String?
    
    var userFirstName:String?
    var userLastName:String?
    var userNumber:Int?
    var userEmail:String?
    var userPhoneNumber:Int?
    var userStatus:Bool?
    var userJobs:[String]?
    
    var userJobsArray:[Job] = []
    var arrayOfJobIds:[String] = []
    
    var delegate:ReturnUserJobsDelegate?
    
    func deleteUser(){
        
        self.changeStatusInFirebase(status: false)
        userID = nil
        userCompany = nil
        userFirstName = nil
        userLastName = nil
        userNumber = nil
        userEmail = nil
        userPhoneNumber = nil
        userStatus = nil
        userJobs = nil
        
        self.deleteUserDefaults()

    }
    
    func saveUserToDefaults(){
        
        UserDefaults.standard.set(userID, forKey: "userId")
        UserDefaults.standard.set(userCompany, forKey: "userCompany")
        UserDefaults.standard.set(userFirstName, forKey: "userFirstName")
        UserDefaults.standard.set(userLastName, forKey: "userLastName")
        UserDefaults.standard.set(userNumber, forKey: "userNumber")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userPhoneNumber, forKey: "userPhoneNumber")
        UserDefaults.standard.set(userStatus, forKey: "userStatus")
        UserDefaults.standard.set(userJobs, forKey: "userJobs")
        
        self.changeStatusInFirebase(status: true)
    }
    
    func checkToSeeIfUserExists() -> Bool{

        if(UserDefaults.standard.object(forKey: "userId") == nil ||
            UserDefaults.standard.object(forKey: "userCompany") == nil ||
            UserDefaults.standard.object(forKey: "userFirstName") == nil ||
            UserDefaults.standard.object(forKey: "userLastName") == nil ||
            UserDefaults.standard.object(forKey: "userEmail") == nil ||
            UserDefaults.standard.object(forKey: "userNumber") == nil ||
            UserDefaults.standard.object(forKey: "userPhoneNumber") == nil ||
            UserDefaults.standard.object(forKey: "userStatus") == nil ||
            UserDefaults.standard.object(forKey: "userJobs") == nil){
            
            return false
        }else{
            return true
        }
    }
    
    
    
    func loadUserDefaults() -> (String, String, String, String, String, Int, Int, Bool, [String]){
        let id = UserDefaults.standard.object(forKey: "userId") as! String
        let company = UserDefaults.standard.object(forKey: "userCompany") as! String
        let firstName = UserDefaults.standard.object(forKey: "userFirstName") as! String
        let lastName = UserDefaults.standard.object(forKey: "userLastName") as! String
        let email = UserDefaults.standard.object(forKey: "userEmail") as! String
        
        let uNumber = UserDefaults.standard.object(forKey: "userNumber") as! Int
        let phoneNumber = UserDefaults.standard.object(forKey: "userPhoneNumber") as! Int
        
        let status = UserDefaults.standard.object(forKey: "userStatus") as! Bool
        let jobs = UserDefaults.standard.object(forKey: "userJobs") as! [String]
        
        
        return (id, company, firstName, lastName, email, uNumber, phoneNumber, status, jobs)
    }
    
    func deleteUserDefaults(){
        
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userCompany")
        UserDefaults.standard.removeObject(forKey: "userFirstName")
        UserDefaults.standard.removeObject(forKey: "userLastName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userNumber")
        UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        UserDefaults.standard.removeObject(forKey: "userStatus")
        UserDefaults.standard.removeObject(forKey: "userJobs")
    }
    
    
    
    
    func changeStatusInFirebase(status:Bool){
        let db = Firestore.firestore()
        
        if(userID != nil && userCompany != nil){
            let ref = db.collection("companies").document(userCompany!).collection("employees").document(userID!)
            ref.updateData(["status": status]){err in
                if err != nil{
                    print("error writting to document")
                }else{
                    self.deleteUserDefaults()
                }
            }
        }
    }
    
    
    
    func loadUserJobIds(){
        
        let userInfo = CurrentUser.sharedInstance.loadUserDefaults()
        
        let userId = userInfo.0
        let userCompany = userInfo.1
        
        let db = Firestore.firestore()
        db.collection("companies").document(userCompany).collection("employees").document(userId).addSnapshotListener { (document, error) in
            if(error == nil){
                guard let data = document!.data() else{
                    return
                }

                self.arrayOfJobIds = data["jobs"] as? NSArray as! [String]
                for jobs in self.arrayOfJobIds{
                    self.loadJobWithId(company: userCompany, id: jobs)
                }
            }
        }
    }
    
    func loadJobWithId(company:String ,id: String){
        let db = Firestore.firestore()
        self.userJobsArray.removeAll()
        db.collection("companies").document(company).collection("jobs").document(id).addSnapshotListener { (document, error) in
            if(error == nil){
                guard let data = document?.data() else{
                    return
                }
                
                let locationGeoPoint = data["location"] as! GeoPoint
                let locationCLLocation = CLLocation(latitude: locationGeoPoint.latitude, longitude: locationGeoPoint.longitude)
                
                let newJob:Job = Job()
                newJob.jobID = document!.documentID
                newJob.jobName = (data["name"] as! String)
                newJob.jobAddress = (data["address"] as! String)
                newJob.jobCoordinates = locationCLLocation
                
                self.userJobsArray.append(newJob)

                if(self.userJobsArray.count == self.arrayOfJobIds.count){
                    self.delegate?.returnUsersJobs(jobs: self.userJobsArray)
                    self.delegate?.usersJobsDoneLoading(done: true)
                }else{
                    self.delegate?.usersJobsDoneLoading(done: false)
                }
                
                //self.delegate?.returnUsersJobs(jobs: self.userJobsArray)
            }
        }
    }
    
}
