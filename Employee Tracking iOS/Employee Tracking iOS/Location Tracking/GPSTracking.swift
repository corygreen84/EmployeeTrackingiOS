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
    
    var radius:Int = 500
    var timeIntervalOffSite = 2
    var timeIntervalOnSite = 1
    var locationManager:CLLocationManager?
    
    var timer:Timer?
    var counter = 0
    
    var arrayOfJobs:[Job] = []
    
    
    var initialLocation:CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
                    
                    if(Int(distanceFromJob!) <= radius  ){
                        atAJob = true
                        let difference = Calendar.current.dateComponents([.minute], from: initialLocation!.timestamp, to: lastLocation.timestamp)
                        let differenceInMinutes = difference.minute
                        
                        //if(differenceInMinutes! >= timeIntervalOnSite){
                            initialLocation = lastLocation
                            
                            // here I need to send the info to the server that the user has entered a job site or is still at //
                            // a job site //
                            self.sendInfoToServerAtJob(jobId: jobs.jobID!, jobName: jobs.jobName!, isAtJob: atAJob)
                        //}
                    }else{
                        atAJob = false
                    }
                }

                // for when the user is not at any job //
                if(atAJob == false){
                    let difference = Calendar.current.dateComponents([.minute], from: initialLocation!.timestamp, to: lastLocation.timestamp)
                    let differenceInMinutes = difference.minute

                    //if(differenceInMinutes! >= timeIntervalOffSite){
                        initialLocation = lastLocation
                    
                        // send info off to server //
                        self.sendInfoToServerOffJob()
                    //}
                }
            }
        }
    }
    
    func sendInfoToServerAtJob(jobId:String, jobName:String, isAtJob: Bool){
        print("at job")
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let userCompany = UserDefaults.standard.object(forKey: "userCompany") as! String
        
        let db = Firestore.firestore()
        let ref = db.collection("companies").document(userCompany).collection("employees").document(userId);
        ref.updateData(["jobsCurrentlyAt": jobName])
    }
    
    func sendInfoToServerOffJob(){
        print("not at job")
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let userCompany = UserDefaults.standard.object(forKey: "userCompany") as! String
        
        let db = Firestore.firestore()
        let ref = db.collection("companies").document(userCompany).collection("employees").document(userId);
        ref.updateData(["jobsCurrentlyAt": ""])
    }
}
