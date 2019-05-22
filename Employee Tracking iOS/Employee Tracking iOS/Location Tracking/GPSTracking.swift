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

class GPSTracking: NSObject, CLLocationManagerDelegate {
    
    var distance:Int = 500
    var timeInterval = 2
    var locationManager:CLLocationManager?
    
    var timer:Timer?
    var counter = 0
    
    var arrayOfJobs:[Job] = []
    
    
    var initialLocation:CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()
        
        self.startLocationTracking()
        //self.singleLocationUpdate()
    }
    
    func loadUsersjobs(jobs: [Job]){
        // for each job that comes in, we need to compare it against the users current location //
        // to see if they are in or out of the jobs location //
        
        arrayOfJobs = jobs
        
        for jo in jobs{
            print(jo.jobName)
        }
    }
    
    

    // if the user declines usage //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    
    
    func singleLocationUpdate(){
        locationManager?.requestLocation()
    }

    func startLocationTracking(){
        //locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.startUpdatingLocation()
    }
    
    func endLocationTracking(){
        locationManager?.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error -> \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation:CLLocation = locations.last!
        if(lastLocation.horizontalAccuracy <= 200){
            
            // getting the first location //
            if(initialLocation == nil){
                initialLocation = lastLocation
            }else{

                var atAJob = false
                for jobs in arrayOfJobs{
                    let distanceFromJob = jobs.jobCoordinates?.distance(from: CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude))
                    
                    if(Int(distanceFromJob!) <= distance){
                        atAJob = true
                        
                        // here I need to send the info to the server that the user has entered a job site or is still at //
                        // a job site //
                        self.sendInfoToServerAtJob(jobId: jobs.jobID!, jobName: jobs.jobName!, isAtJob: atAJob)
                    }else{
                        atAJob = false
                    }
                    
                }

                // for when the user is not at any job //
                if(atAJob == false){
                    let difference = Calendar.current.dateComponents([.minute], from: initialLocation!.timestamp, to: lastLocation.timestamp)
                    let differenceInMinutes = difference.minute

                    if(differenceInMinutes! >= timeInterval){
                        initialLocation = lastLocation
                    
                        // send info off to server //
                        self.sendInfoToServerOffJob()
                    }
                }
            }
        }
    }
    
    func sendInfoToServerAtJob(jobId:String, jobName:String, isAtJob: Bool){
        print("job -> \(jobId) and job Name -> \(jobName) is at the job \(isAtJob)" )
        var userId = UserDefaults.standard.object(forKey: "userId") as! String
        
    }
    
    func sendInfoToServerOffJob(){
        print("is not at the job")
        var userId = UserDefaults.standard.object(forKey: "userId") as! String
    }
}
