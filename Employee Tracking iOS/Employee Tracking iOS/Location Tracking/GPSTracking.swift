//
//  GPSTracking.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

@objc protocol ReturnLocationData{
    func locationStatusDenied()
}

class GPSTracking: NSObject, CLLocationManagerDelegate{
    
    var radius:Int = 100
    var timeIntervalOffSite = 1
    var timeIntervalOnSite = 1
    var locationManager:CLLocationManager?
    
    var locationTrackingToggle = false
    
    var timer:Timer?
    var counter = 0
    
    var arrayOfJobs:[Job] = []
    
    var initialLocation:CLLocation?
    
    var delegate:ReturnLocationData?
    
    var jobName = ""
    
    var _arrayOfJobs:[AnyObject] = []
    
    
    
    override init() {
        super.init()
        
        self.setup()
    }
    
    func setup(){
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()

        self.startLocationTracking()
    }
    
    func loadUsersjobs(jobs: [Job]){
        // for each job that comes in, we need to compare it against the users current location //
        // to see if they are in or out of the jobs location //
        arrayOfJobs = jobs
        
        // if location tracking has been turned off because the user has no jobs //
        // then, if there are jobs, turn it back on //
        if(arrayOfJobs.count != 0){
            if(locationTrackingToggle == false){
                startLocationTracking()
            }
        }else{
            endLocationTracking()
        }
    }
    
    

    // if the user declines usage //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            self.delegate?.locationStatusDenied()
        default:
            break
        }
    }
    
    
    
    func singleLocationUpdate(){
        locationManager?.requestLocation()
    }

    func startLocationTracking(){
        jobName = ""
        self.singleLocationUpdate()
        locationManager?.startUpdatingLocation()
        locationTrackingToggle = true
        
        print("\nstarted location tracking \n")
    }
    
    func endLocationTracking(){
        locationManager?.stopUpdatingLocation()
        jobName = ""
        locationTrackingToggle = false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error -> \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let lastLocation:CLLocation = locations.last!

            // getting the first location //
            if(initialLocation == nil){
                initialLocation = lastLocation
            }else{

                var atAJob = false

                for jobs in arrayOfJobs{
                    let distanceFromJob = jobs.jobCoordinates?.distance(from: CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude))
                    
                    // if the user is within the circle of a job //
                    if(Int(distanceFromJob!) <= radius  ){
                        atAJob = true

                        initialLocation = lastLocation
                        
                        if(jobs.jobName! != jobName){

                            // sends info that the user has logged out //
                            CurrentUser.sharedInstance.sendInfoToServerAtJob(jobId: jobs.jobID!, jobName: jobs.jobName!, jobAddress: jobs.jobAddress!, isAtJob: atAJob)
                            jobName = jobs.jobName!
                        }
                    }
                }

                // for when the user is not at any job //
                if(atAJob == false){
                        initialLocation = lastLocation

                    // send info off to server //
                    if(jobName != "Offsite"){
                        //self.sendInfoToServerOffJob()
                        CurrentUser.sharedInstance.sendInfoToServerOffJob()
                        jobName = "Offsite"
                        
                    }
                }
            }
    }
}
