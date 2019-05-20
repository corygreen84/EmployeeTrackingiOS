//
//  DetailViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var longTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    var job:Job?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        if(job != nil){
            self.title = job!.jobName
            addressLabel.text = job!.jobAddress
            longTextField.text = "\(job!.jobCoordinates!.coordinate.longitude)"
            latTextField.text = "\(job!.jobCoordinates!.coordinate.latitude)"
            
            self.showLocationOnMap(long: job!.jobCoordinates!.coordinate.longitude, lat: job!.jobCoordinates!.coordinate.latitude)
        }
    }
    
    
    func showLocationOnMap(long: Double, lat: Double){
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        
        self.mainMapView.setRegion(region, animated: true)
        self.mainMapView.addAnnotation(annotation)
    }
}
