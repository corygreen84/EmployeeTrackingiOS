//
//  LoadingJobs.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@objc protocol ReturnJobDataDelegate{
    @objc optional func returnJobArray(jobs:[Jobs])
    @objc optional func returnPreliminaryJobsLoaded(done:Bool)
}

class LoadingJobs: NSObject {

    var company:String?
    var email:String?
    var id:String?

    var arrayOfJobIds:[String] = []
    var arrayOfJobs:[Jobs] = []
    
    var count = 0
    
    var db = Firestore.firestore()
    
    var delegate:ReturnJobDataDelegate?
    
    var employeeRefHandler:ListenerRegistration?
    var jobRefHandler:ListenerRegistration?
    
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeHandlers), name: NSNotification.Name(rawValue: "loggedOff"), object: nil)
        
        email = Auth.auth().currentUser?.email
    
    }
    
    func loadUserPreliminaryInfo(){
        
        if(email != nil){
            let userRef = db.collection("users").document(email!)
            userRef.getDocument { (doc, err) in
                if let document = doc, doc!.exists{
                    guard let data = document.data() else{
                        return
                    }
                    
                    guard let _company = data["company"] else{
                        return
                    }
                    
                    guard let _id = data["id"] else{
                        return
                    }
                    
                    self.company = (_company as! String)
                    self.id = (_id as! String)
                    
                    
                    UserDefaults.standard.set(self.company, forKey: "company")
                    UserDefaults.standard.set(self.id, forKey: "id")
                    
                    self.loadEmployeeInfoFromEmployees(company: self.company!, id: self.id!)
                    
                    
                    // sending info back to the server that the user has logged in //
                    let sendInfoToServer:SendInfoToServer = SendInfoToServer()
                    sendInfoToServer.changeStatusInFirebase(status: true, userId: self.id!, userCompany: self.company!)
                    
                    self.delegate?.returnPreliminaryJobsLoaded!(done: true)
                }
            }
        }
    }
    
    
    
    
    func loadEmployeeInfoFromEmployees(company:String, id:String){
        let companiesRef = db.collection("companies").document(company).collection("employees").document(id)
        companiesRef.getDocument { (document, error) in
            if let doc = document, document!.exists{
                guard let data = doc.data() else{
                    return
                }
                
                guard let employeeNumber = data["employeeNumber"] else{
                    return
                }
                
                guard let email = data["email"] else{
                    return
                }
                
                guard let phoneNumber = data["phoneNumber"] else{
                    return
                }
                
                guard let first = data["first"] else{
                    return
                }
                
                guard let last = data["last"] else{
                    return
                }
                
                guard let pass = data["password"] else{
                    return
                }
                
                
                UserDefaults.standard.set(employeeNumber, forKey: "employeeNumber")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                UserDefaults.standard.set(first, forKey: "first")
                UserDefaults.standard.set(last, forKey: "last")
                UserDefaults.standard.set(pass, forKey: "pass")

                // notification for when the user info has been loaded into the system //
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "doneLoadingUserInfo"), object: nil)
                
                print("set")
            }else{
                print("document doesnt exist")
            }
        }
    }
    

    // this is static and only loads once //
    func loadUserInfo(){

        if(email != nil){
            let userRef = db.collection("users").document(email!)
            userRef.getDocument { (doc, err) in
                if let document = doc, doc!.exists{
                    guard let data = document.data() else{
                        return
                    }
                    
                    guard let _company = data["company"] else{
                        return
                    }
                    
                    guard let _id = data["id"] else{
                        return
                    }
                    
                    self.company = (_company as! String)
                    self.id = (_id as! String)
                    
                    self.loadEmployeeInfoFromEmployees(company: self.company!, id: self.id!)
 
                    self.loadUserJobIds(company: self.company!, id: self.id!)
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    // this is dynamic and updates when there is new data //
    func loadUserJobIds(company:String, id:String){
        let employeeRef = db.collection("companies").document(company).collection("employees").document(id)
        employeeRefHandler = employeeRef.addSnapshotListener { (doc, err) in
            if(err == nil){
                guard let data = doc!.data() else{
                    return
                }

                
                self.arrayOfJobIds = data["jobs"] as? NSArray as! [String]
                self.arrayOfJobs.removeAll()
                for job in self.arrayOfJobIds{
                    
                    self.loadJobs(company: company, jobId: job)
                }
            }
        }
        
    }
    
    
    // this is dynamic and updates when there is new data //
    func loadJobs(company:String, jobId:String){
        let jobRef = db.collection("companies").document(company).collection("jobs").document(jobId)
        jobRefHandler = jobRef.addSnapshotListener { (doc, err) in
            if(err == nil){
                guard let data = doc!.data() else{
                    return
                }
                
                let address = data["address"] as! String
                let date = data["date"] as! String
                let name = data["name"] as! String
                let notes = data["notes"] as! String
                
                // getting location data //
                let locationGeoPoint = data["location"] as! GeoPoint
                let locationCLLocation = CLLocation(latitude: locationGeoPoint.latitude, longitude: locationGeoPoint.longitude)
                
                
                let newJob:Jobs = Jobs()
                newJob.name = name
                newJob.address = address
                newJob.date = date
                newJob.coordinates = locationCLLocation
                newJob.notes = notes
                newJob.id = jobId

                
                if(self.arrayOfJobs.count == 0){
                    self.arrayOfJobs.append(newJob)
                }else{
                    var exists = false
                    var indexFound = 0
                    for (index, jobs) in self.arrayOfJobs.enumerated(){
                        if(jobs.id == jobId){
                            exists = true
                            indexFound = index
                        }
                    }
                    
                    if(!exists){
                        self.arrayOfJobs.append(newJob)
                    }else{
                        self.arrayOfJobs.remove(at: indexFound)
                        self.arrayOfJobs.append(newJob)
                    }
                }
                
                
                if(self.arrayOfJobIds.count < self.arrayOfJobs.count){
                    
                    for (index, jobs) in self.arrayOfJobs.enumerated(){
                        if(!(self.arrayOfJobIds.contains(jobs.id!))){
                            self.arrayOfJobs.remove(at: index)
                        }
                    }
                }
                
                
                if(self.arrayOfJobIds.count == self.arrayOfJobs.count){
                    self.delegate?.returnJobArray!(jobs: self.arrayOfJobs)
                }
            }
        }
    }

    @objc func removeHandlers(){
        self.employeeRefHandler?.remove()
        self.jobRefHandler?.remove()
    }
}
