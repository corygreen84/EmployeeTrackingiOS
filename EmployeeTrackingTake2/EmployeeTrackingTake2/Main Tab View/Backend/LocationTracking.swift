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
    
    var locationManager:CLLocationManager?
    var arrayOfJobs:[Jobs]?
    
    var initialLocation:CLLocation?
    var locationTrackingToggle = false
    
    var loggedOffToggle = false
    
    var radius:Int = 100
    
    var jobName = ""
    
    var sendInfoToServer:SendInfoToServer?
    
    override init() {
        super.init()
        
        
        // notification to stop gps updates //
        NotificationCenter.default.addObserver(self, selector: #selector(loggedOff), name: NSNotification.Name(rawValue: "loggedOff"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(terminated), name: NSNotification.Name(rawValue: "terminated"), object: nil)
        
        sendInfoToServer = SendInfoToServer()
 
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.pausesLocationUpdatesAutomatically = false
        
        if(UserDefaults.standard.object(forKey: "jobName") != nil){
            jobName = UserDefaults.standard.object(forKey: "jobName") as! String
        }else{
            jobName = ""
        }
    }

    
    
    func loadJobs(jobs:[Jobs]){
        if(loggedOffToggle == false){
            arrayOfJobs = jobs
        
            if(arrayOfJobs!.count != 0){
                if(locationTrackingToggle == false){
                    print("starting")
                    startLocationUpdates()
                }
            }else{
                stopLocationUpdates()
            }
        }else{
            stopLocationUpdates()
        }
    }
    
    
    
    // starting and stopping location services //
    func startLocationUpdates(){

        if(UserDefaults.standard.object(forKey: "jobName") != nil){
            jobName = UserDefaults.standard.object(forKey: "jobName") as! String
        }else{
            jobName = ""
        }
        //jobName = ""
        
        self.singleLocationUpdate()
        locationManager?.startUpdatingLocation()
        locationTrackingToggle = true
    }
    

    @objc func loggedOff(){
        loggedOffToggle = true
        stopLocationUpdates()
    }
    
    
    
    @objc func terminated(){
        loggedOffToggle = true
        stopLocationUpdates()
        
        let userId = UserDefaults.standard.object(forKey: "id") as! String
        let userCompany = UserDefaults.standard.object(forKey: "company") as! String
        
        sendInfoToServer!.changeStatusInFirebase(status: false, userId: userId, userCompany: userCompany)
    }
    
    
    
    @objc func stopLocationUpdates(){
        UserDefaults.standard.set("", forKey: "jobName")
        jobName = UserDefaults.standard.object(forKey: "jobName") as! String
        locationTrackingToggle = false
        locationManager?.stopUpdatingLocation()
    }
    
    func singleLocationUpdate(){
        self.locationManager?.requestLocation()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error -> \(error.localizedDescription)")
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation:CLLocation = locations.last!
        
        // getting the first location //
        if(initialLocation == nil){
            initialLocation = lastLocation
        }else{
            
            var atAJob = false
            
            for jobs in arrayOfJobs!{
                let distanceFromJob = jobs.coordinates?.distance(from: CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude))
                
                // if the user is within the circle of a job //
                if(Int(distanceFromJob!) <= radius){
                    atAJob = true
                    
                    initialLocation = lastLocation
                    
                
                    if(jobs.name! != jobName){
                        // sends info that the user has logged out //
                        sendInfoToServer!.sendInfoToServerAtJob(jobId: jobs.id!, jobName: jobs.name!, jobAddress: jobs.address!, isAtJob: atAJob)
                        
                        jobName = jobs.name!
                        UserDefaults.standard.set(jobName, forKey: "jobName")
                        
                    }
                }
            }
            
            // for when the user is not at any job //
            if(atAJob == false){
                initialLocation = lastLocation
                
                // send info off to server //
                if(jobName != "Offsite"){

                    sendInfoToServer!.sendInfoToServerOffJob()
                    jobName = "Offsite"
                    UserDefaults.standard.set(jobName, forKey: "jobName")
                    
                }
            }
        }
    }
    
    
    
}
