//
//  LocationTracking.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/24/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation

class LocationTracking: NSObject, CLLocationManagerDelegate{
    
    var passedInJobs:[Jobs] = []
    
    var radius:Int = 100
    
    //var jobName = ""
    //var jobAddress = ""
    
    var locationManager:CLLocationManager?
    var initialLocation:CLLocation?
    
    var loggedOffToggle = false
    var locationTrackingToggle = false
    
    var sendInfoToServer:SendInfoToServer?
    
    override init() {
        super.init()
        
        sendInfoToServer = SendInfoToServer()
        
        // notification to stop gps updates //
        NotificationCenter.default.addObserver(self, selector: #selector(loggedOff), name: NSNotification.Name(rawValue: "loggedOff"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(terminated), name: NSNotification.Name(rawValue: "terminated"), object: nil)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        //UserDefaults.standard.removeObject(forKey: "jobName")
        //UserDefaults.standard.removeObject(forKey: "jobAddress")
        
    }
    
    
    
    func loadJobs(jobs:[Jobs]){
        if(loggedOffToggle == false){
            passedInJobs = jobs
            if(passedInJobs.count != 0){
                startLocationUpdates()
            }else{
                stopLocationUpdates()
            }
        }else{
            stopLocationUpdates()
        }
    }
    
    
    
    func startLocationUpdates(){

        self.singleLocationUpdate()
        locationManager?.startUpdatingLocation()
        locationTrackingToggle = true
    }
    
    func singleLocationUpdate(){
        self.locationManager?.requestLocation()
    }
    
    func stopLocationUpdates(){

        locationTrackingToggle = false
        locationManager?.stopUpdatingLocation()
    }
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation:CLLocation = locations.last!
        
        if(initialLocation == nil){
            initialLocation = lastLocation
        }else{
            var atAJob = false
            
            for jobs in passedInJobs{
                let distanceFromJob = jobs.coordinates?.distance(from: CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude))
                
                // if the user is within the circle of a job //
                if(Int(distanceFromJob!) <= radius){
                    atAJob = true
                    
                    initialLocation = lastLocation
   
                    
                    var jobName = ""
                    var jobAddress = ""
                    if(UserDefaults.standard.object(forKey: "jobName") != nil){
                        jobName = UserDefaults.standard.object(forKey: "jobName") as! String
                    }
                    
                    if(UserDefaults.standard.object(forKey: "jobAddress") != nil){
                        jobAddress = UserDefaults.standard.object(forKey: "jobAddress") as! String
                    }


                    
                    if(jobs.name != jobName || jobs.address != jobAddress){
                        // sends info that the user has logged out //
                        sendInfoToServer!.sendInfoToServerAtJob(jobId: jobs.id!, jobName: jobs.name!, jobAddress: jobs.address!, isAtJob: atAJob)
                        
                        UserDefaults.standard.set(jobs.name, forKey: "jobName")
                        UserDefaults.standard.set(jobs.address, forKey: "jobAddress")
                    }
                }
            }
            // for when the user is not at any job //
            if(atAJob == false){
                initialLocation = lastLocation

                var jobName = ""
                var jobAddress = ""
                if(UserDefaults.standard.object(forKey: "jobName") != nil){
                    jobName = UserDefaults.standard.object(forKey: "jobName") as! String
                }
                
                if(UserDefaults.standard.object(forKey: "jobAddress") != nil){
                    jobAddress = UserDefaults.standard.object(forKey: "jobAddress") as! String
                }
                if(jobName != "Offsite" || jobAddress != "Offsite"){
                    
                    sendInfoToServer!.sendInfoToServerOffJob()
                    UserDefaults.standard.set("Offsite", forKey: "jobName")
                    UserDefaults.standard.set("Offsite", forKey: "jobAddress")
                }
                
            }
        }
    }
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error -> \(error.localizedDescription)")
    }
    
    
    
    // from the notification center //
    @objc func loggedOff(){
        
        UserDefaults.standard.set("Offsite", forKey: "jobName")
        UserDefaults.standard.set("Offsite", forKey: "jobAddress")
        
        loggedOffToggle = true
        stopLocationUpdates()
    }
    
    @objc func terminated(){
        
        UserDefaults.standard.set("Offsite", forKey: "jobName")
        UserDefaults.standard.set("Offsite", forKey: "jobAddress")
        
        loggedOffToggle = true
        stopLocationUpdates()
        
        let userId = UserDefaults.standard.object(forKey: "id") as! String
        let userCompany = UserDefaults.standard.object(forKey: "company") as! String
        
        sendInfoToServer!.changeStatusInFirebase(status: false, userId: userId, userCompany: userCompany)
    }

}
