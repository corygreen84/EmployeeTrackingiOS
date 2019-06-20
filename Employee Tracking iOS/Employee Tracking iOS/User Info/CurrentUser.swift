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
    func returnUsersJobs(jobs: [Job], status:Bool)
    func loadingPassOn(loading:Bool)
}

class CurrentUser: NSObject, ReturnStatusOfFileLoadToFirebaseDelegate {
    static let sharedInstance = CurrentUser()

    var userJobsArray:[Job] = []
    var arrayOfJobIds:[String] = []
    
    var delegate:ReturnUserJobsDelegate?
    
    var dayMonthYear:DateFormatter?
    var hourMinute:DateFormatter?

    var loadUserIdListener: ListenerRegistration?
    var loadUserJobsListener: ListenerRegistration?
    
    var jobData:[String:[String:String]] = [:]
    
    func deleteUser(){
        self.deleteUserDefaults()
    }

    func saveUserToDefaults(_userId: String, _userCompany: String, _userFirstName: String, _userLastName: String, _userNumber: Int, _userEmail: String, _userPhoneNumber: Int, _userStatus: Bool, _userJobs: [String]){
        
        UserDefaults.standard.set(_userId, forKey: "userId")
        UserDefaults.standard.set(_userCompany, forKey: "userCompany")
        UserDefaults.standard.set(_userFirstName, forKey: "userFirstName")
        UserDefaults.standard.set(_userLastName, forKey: "userLastName")
        UserDefaults.standard.set(_userNumber, forKey: "userNumber")
        UserDefaults.standard.set(_userEmail, forKey: "userEmail")
        UserDefaults.standard.set(_userPhoneNumber, forKey: "userPhoneNumber")
        UserDefaults.standard.set(_userStatus, forKey: "userStatus")
        UserDefaults.standard.set(_userJobs, forKey: "userJobs")

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
        
        let id = UserDefaults.standard.object(forKey: "userId")
        let company = UserDefaults.standard.object(forKey: "userCompany")
        let firstName = UserDefaults.standard.object(forKey: "userFirstName")
        let lastName = UserDefaults.standard.object(forKey: "userLastName")
        let email = UserDefaults.standard.object(forKey: "userEmail")
        let uNumber = UserDefaults.standard.object(forKey: "userNumber")
        let phoneNumber = UserDefaults.standard.object(forKey: "userPhoneNumber")
        let status = UserDefaults.standard.object(forKey: "userStatus")
        let jobs = UserDefaults.standard.object(forKey: "userJobs")
        
        
        return (id as! String, company as! String, firstName as! String, lastName as! String, email as! String, uNumber as! Int, phoneNumber as! Int, status as! Bool, jobs as! [String])
    }
    
    func deleteUserDefaults(){
        self.changeStatusInFirebase(status: false)
        
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userCompany")
        UserDefaults.standard.removeObject(forKey: "userFirstName")
        UserDefaults.standard.removeObject(forKey: "userLastName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userNumber")
        UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        UserDefaults.standard.removeObject(forKey: "userStatus")
        UserDefaults.standard.removeObject(forKey: "userJobs")
        
        self.detachListeners()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func loadUserJobIds(){
        
        let userInfo = CurrentUser.sharedInstance.loadUserDefaults()
        
        let userId = userInfo.0
        let userCompany = userInfo.1

        let db = Firestore.firestore()
        loadUserIdListener = db.collection("companies").document(userCompany).collection("employees").document(userId).addSnapshotListener { (document, error) in
            
            if(error == nil){
                guard let data = document!.data() else{
                    return
                }
                self.userJobsArray.removeAll()
                self.arrayOfJobIds = data["jobs"] as? NSArray as! [String]
                
                if(self.arrayOfJobIds.count == 0){
                    // if there are no jobs, we still need to know about it //
                    self.delegate?.returnUsersJobs(jobs: self.userJobsArray, status: true)
                }
                
                for jobs in self.arrayOfJobIds{
                    self.loadJobWithId(company: userCompany, id: jobs)
                }
            }
        }
    }
    
    func loadJobWithId(company:String ,id:String){
        let db = Firestore.firestore()
        
        loadUserJobsListener = db.collection("companies").document(company).collection("jobs").document(id).addSnapshotListener { (document, error) in

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
                
                if(self.userJobsArray.count == 0){
                    self.userJobsArray.append(newJob)
                }else{
                    var _exists = false
                    var _index = 0
                    for(index, jobs) in self.userJobsArray.enumerated(){
                        if(jobs.jobID == document!.documentID){
                            _exists = true
                            _index = index
                        }
                    }
                    
                    if(_exists){
                        self.userJobsArray.remove(at: _index)
                        self.userJobsArray.append(newJob)
                    }else{
                        self.userJobsArray.append(newJob)
                    }
                }

                if(self.userJobsArray.count == self.arrayOfJobIds.count){
                    self.delegate?.returnUsersJobs(jobs: self.userJobsArray, status: true)
                }
            }
        }
    }
    
    
    
    
    // **** saving the users last known location so as to not keep sending redundant **** //
    // **** data back to the server **** //
    func saveLastLocation(locationName:String){
        UserDefaults.standard.set(locationName, forKey: "lastLocation")
    }
    
    func loadLastLocation() -> String{
        guard let lastLocation = UserDefaults.standard.object(forKey: "lastLocation") else{
            return ""
        }
        return lastLocation as! String
    }
    
    func deleteLastLocation(){
        UserDefaults.standard.removeObject(forKey: "lastLocation")
    }
    
    func detachListeners(){
        loadUserJobsListener?.remove()
        loadUserIdListener?.remove()
    }
    
    
    
    
    
    
    
    
    
    
    
    // **** updates to the server **** //
    func changeStatusInFirebase(status:Bool){
        let db = Firestore.firestore()
        
        let _id = UserDefaults.standard.object(forKey: "userId") as? String
        let _company = UserDefaults.standard.object(forKey: "userCompany") as? String
        
        dayMonthYear = DateFormatter()
        dayMonthYear?.dateFormat = "MM-dd-yyyy"
        
        hourMinute = DateFormatter()
        hourMinute?.dateFormat = "HH:mm"
        
        
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)
        
        
        
        if(_id != nil && _company != nil){
            
            
            
            let ref = db.collection("companies").document(_company!).collection("employees").document(_id!)
            
            // logging in //
            if(status){
                
                
                // need to generate a unique id //
                let identifier = UUID()
                
                // generating an object to send to the server //
                let objectToServer = "\"\(identifier)\":{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"Logged In\", \"jobAddress\": \"Offsite\", \"jobId\": \"Offsite\"}"
                
                
                ref.updateData(["status": status, "jobHistory": FieldValue.arrayUnion([objectToServer])]) { (error) in
                    if(error == nil){
                        print("good to go")
                    }
                }
                
            // logging off //
            }else{
                
                let identifier = UUID()
                // generating an object to send to the server //
                let objectToServer = "\"\(identifier)\":{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"Logged Off\", \"jobAddress\": \"Offsite\", \"jobId\": \"Offsite\"}"
                

                ref.updateData(["status": status, "jobsCurrentlyAt": "", "jobHistory": FieldValue.arrayUnion([objectToServer])]){err in
                    if err != nil{
                        print("error writting to document")

                    }else{
 
                        // **** because the user is logging off - we send off the compiled text string to storage **** //
                        
                        let sendLogOutFile = SendLogOffTextFile()
                        sendLogOutFile.delegate = self
                        sendLogOutFile.loadUserInfoFromServer(userCompany: _company!, userId: _id!)
                        
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    // sends info to the server if offsite //
    func sendInfoToServerOffJob(){
        guard let userId = UserDefaults.standard.object(forKey: "userId") else{
            return
        }
        
        guard let userCompany = UserDefaults.standard.object(forKey: "userCompany") else{
            return
        }
        
        dayMonthYear = DateFormatter()
        dayMonthYear?.dateFormat = "MM-dd-yyyy"
        
        hourMinute = DateFormatter()
        hourMinute?.dateFormat = "HH:mm"
        
        
        
        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)
        

        let identifier = UUID()
        // generating an object to send to the server //
        let objectToServer = "\"\(identifier)\":{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"Offsite\", \"jobAddress\": \"Offsite\", \"jobId\": \"Offsite\"}"

        let db = Firestore.firestore()
        let ref = db.collection("companies").document(userCompany as! String).collection("employees").document(userId as! String)
        
        
        ref.updateData(["jobHistory": FieldValue.arrayUnion([objectToServer]), "jobsCurrentlyAt": "Offsite"]){err in
            if(err != nil){
                print("error in updating \(err.debugDescription)")
            }else{
                
            }
            
        }
    }
    
    
    
    // sends info to the server if on the job //
    func sendInfoToServerAtJob(jobId:String, jobName:String, jobAddress:String, isAtJob: Bool){
        
        guard let userId = UserDefaults.standard.object(forKey: "userId") else{
            return
        }
        
        guard let userCompany = UserDefaults.standard.object(forKey: "userCompany") else{
            return
        }
        
        
        
        
        dayMonthYear = DateFormatter()
        dayMonthYear?.dateFormat = "MM-dd-yyyy"
        
        hourMinute = DateFormatter()
        hourMinute?.dateFormat = "HH:mm"
        
        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)
        
        let identifier = UUID()
        // generating an object to send to the server //
        let objectToServer = "\"\(identifier)\":{\"date\": \"\(dayMonthYearString)\", \"time\": \"\(hourMinuteString)\", \"jobName\": \"\(jobName)\", \"jobAddress\": \"\(jobName)\", \"jobId\": \"\(jobId)\"}"

        let db = Firestore.firestore()
        let ref = db.collection("companies").document(userCompany as! String).collection("employees").document(userId as! String)
        
        ref.updateData(["jobHistory": FieldValue.arrayUnion([objectToServer]), "jobsCurrentlyAt": jobName]){err in
            if(err != nil){
                print("error in updating \(err.debugDescription)")
            }else{
                
            }
        }
    }
    
    
    func status(loading: Bool) {
        self.delegate?.loadingPassOn(loading: loading)
    }
}
