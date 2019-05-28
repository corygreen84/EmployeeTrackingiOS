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
    func returnlocation(location:CLLocation)
}

class GPSTracking: NSObject, CLLocationManagerDelegate {
    
    var radius:Int = 500
    var timeIntervalOffSite = 1
    var timeIntervalOnSite = 1
    var locationManager:CLLocationManager?
    
    var locationTrackingToggle = false
    
    var timer:Timer?
    var counter = 0
    
    var arrayOfJobs:[Job] = []
    
    var initialLocation:CLLocation?
    
    var dayMonthYear:DateFormatter?
    var hourMinute:DateFormatter?
    
    var delegate:ReturnLocationData?
    
    var jobName = ""
    
    override init() {
        super.init()
        
        dayMonthYear = DateFormatter()
        dayMonthYear?.dateFormat = "MM-dd-yyyy"
        
        hourMinute = DateFormatter()
        hourMinute?.dateFormat = "HH:mm"
        
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
        
    }
    
    
    
    func singleLocationUpdate(){
        locationManager?.requestLocation()
    }

    func startLocationTracking(){
        jobName = ""
        self.singleLocationUpdate()
        locationManager?.startUpdatingLocation()
        locationTrackingToggle = true
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

        
        self.delegate?.returnlocation(location: lastLocation)
            
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
                        //let difference = Calendar.current.dateComponents([.minute], from: initialLocation!.timestamp, to: lastLocation.timestamp)
                        //let differenceInMinutes = difference.minute
                        
                        //if(differenceInMinutes! >= timeIntervalOnSite){
                        initialLocation = lastLocation
                        if(jobs.jobName! != jobName){
                            self.sendInfoToServerAtJob(jobId: jobs.jobID!, jobName: jobs.jobName!, jobAddress: jobs.jobAddress!, isAtJob: atAJob)
                            jobName = jobs.jobName!
                        }

                        
                        //}
                    }
                }

                // for when the user is not at any job //
                if(atAJob == false){
                    //let difference = Calendar.current.dateComponents([.minute], from: initialLocation!.timestamp, to: lastLocation.timestamp)
                    //let differenceInMinutes = difference.minute

                    //if(differenceInMinutes! >= timeIntervalOffSite){
                        initialLocation = lastLocation
                    // should be making a judgement call for the users speed //
                    // here.... //
                    
                    // send info off to server //
                    if(jobName != "Offsite"){
                        self.sendInfoToServerOffJob()
                        jobName = "Offsite"
                    }
                        //self.sendInfoToServerOffJob()
                    //}
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
        
        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)
        
        let objectToServer = ["date": dayMonthYearString, "time": hourMinuteString, "jobName": jobName, "jobAddress": jobAddress, "jobId":jobId]


        let db = Firestore.firestore()
        let ref = db.collection("companies").document(userCompany as! String).collection("employees").document(userId as! String);
        ref.updateData(["jobHistory": FieldValue.arrayUnion([objectToServer]), "jobsCurrentlyAt": jobName]){err in
            if(err != nil){
                print("error in updating \(err.debugDescription)")
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
        
        
        // constructing the event object //
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)

        let objectToServer = ["date": dayMonthYearString, "time": hourMinuteString, "jobName": "Offsite", "jobAddress": "Offsite", "jobId":"Offsite"]
        

        let db = Firestore.firestore()
        let ref = db.collection("companies").document(userCompany as! String).collection("employees").document(userId as! String);
        ref.updateData(["jobHistory": FieldValue.arrayUnion([objectToServer]), "jobsCurrentlyAt": "Offsite"]){err in
            if(err != nil){
                print("error in updating \(err.debugDescription)")
            }
        }
        
    }
}
