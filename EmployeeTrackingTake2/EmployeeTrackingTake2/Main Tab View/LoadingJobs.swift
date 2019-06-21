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
    func returnJobData(jobs:[Jobs])
    func returnDataChanged(jobId:String)
}

class LoadingJobs: NSObject {

    var company:String?
    var email:String?
    var id:String?

    var arrayOfJobIds:[String] = []
    var arrayOfJobs:[Jobs] = []
    var dictionaryOfJobs:[String:Jobs] = [:]
    
    var count = 0
    
    var db = Firestore.firestore()
    
    var delegate:ReturnJobDataDelegate?
    
    override init(){
        super.init()
        
        email = Auth.auth().currentUser?.email
        loadUserInfo()
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
                    
                    self.loadUserJobIds(company: self.company!, id: self.id!)
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    // this is dynamic and updates when there is new data //
    func loadUserJobIds(company:String, id:String){
        let employeeRef = db.collection("companies").document(company).collection("employees").document(id)
        employeeRef.addSnapshotListener { (doc, err) in
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
        jobRef.addSnapshotListener { (doc, err) in
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
                
                
                
                
                self.delegate?.returnJobData(jobs: self.arrayOfJobs)
                
                
                /*
                if(self.arrayOfJobs.count == self.arrayOfJobIds.count){
                    self.delegate?.returnDataChanged(jobId: jobId)
                    self.delegate?.returnJobData(jobs: self.arrayOfJobs)
                }
                */

            }
        }
    }
}
