//
//  Backbone.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 7/1/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnBackboneDelegate{
    func returnJobsArrayBackbone(jobs:[Jobs])
    func returnPreliminaryJobsLoadedBackbone(done: Bool)
}

class Backbone: NSObject, ReturnJobDataDelegate {
    
    static let sharedInstance = Backbone()
    
    var delegate:ReturnBackboneDelegate?
    
    var loadingJobs:LoadingJobs?
    var locationTracking:LocationTracking?
    
    var company:String?
    var id:String?

    func initialize(){
        loadingJobs = LoadingJobs()
        loadingJobs?.delegate = self
        
        locationTracking = LocationTracking()
    }
    
    func loadUserJobsBackgone(){
        loadingJobs?.loadUserInfo()
    }
    
    func returnJobArray(jobs: [Jobs]) {
        
        locationTracking?.loadJobs(jobs: jobs)
        self.delegate?.returnJobsArrayBackbone(jobs: jobs)
    }
    
    
    func returnPreliminaryJobsLoaded(done: Bool) {
        self.delegate?.returnPreliminaryJobsLoadedBackbone(done: done)
    }
    
    
    // **** logging out stuff **** //
    func loggedOutBroadcast(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loggedOff"), object: self)
    }
    

}
