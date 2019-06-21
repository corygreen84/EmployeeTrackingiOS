//
//  DetailsViewController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/21/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    var job:Jobs?
    @IBOutlet weak var mainMap: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(job != nil){
            
            self.title = job!.name
            
            dateLabel.text = job!.date
            
            addressLabel.text = job!.address
            addressLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            notesTextView.text = job!.notes
            
            self.showLocationOnMap(long: job!.coordinates!.coordinate.longitude, lat: job!.coordinates!.coordinate.latitude)
        }
    }
    
    func showLocationOnMap(long: Double, lat: Double){
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        
        self.mainMap.setRegion(region, animated: true)
        self.mainMap.addAnnotation(annotation)
    }


}
