//
//  GPSTracking.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation


class GPSTracking: NSObject, CLLocationManagerDelegate {
    
    var distance:Int?
    var timeInterval = 50
    var locationManager:CLLocationManager?
    
    var timer:Timer?
    var counter = 0
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()
        
        locationManager?.startUpdatingLocation()
    }
    
    func loadUsersjobs(jobs: [Job]){
        
    }
    
    

    // if the user declines usage //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func startLocationTrackingOnce(){
        locationManager?.requestLocation()
    }
    
    
    func startLocationTracking(){
        locationManager?.startUpdatingLocation()
    }
    
    func endLocationTracking(){
        locationManager?.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error -> \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        
        if(lastLocation!.horizontalAccuracy >= 100.0){
            return
        }
        
    }
}
