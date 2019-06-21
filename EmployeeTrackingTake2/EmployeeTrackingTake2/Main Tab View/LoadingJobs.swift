//
//  LoadingJobs.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

@objc protocol ReturnJobDataDelegate{
    func returnJobData(jobs:[Jobs])
}

class LoadingJobs: NSObject {

    var company:String?
    var email:String?
    var id:String?
    
    var db = Firestore.firestore()
    
    var delegate:ReturnJobDataDelegate?
    
    override init(){
        super.init()
        
        email = Auth.auth().currentUser?.email
        loadUserInfo()
    }
    
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
    
    
    func loadUserJobIds(company:String, id:String){
        let employeeRef = db.collection("companies").document(company).collection("employees").document(id)
        employeeRef.addSnapshotListener { (doc, err) in
            if(err == nil){
                guard let data = doc!.data() else{
                    return
                }
                
                let jobs = data["jobs"] as? NSArray as! [String]
                    
                for job in jobs{
                    print(job)
                }
                
            }
        }
        
    }
    
    
    func loadJobs(){
        
    }
    
}
