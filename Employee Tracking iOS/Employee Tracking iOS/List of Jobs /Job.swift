//
//  Job.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation

class Job: NSObject {
    
    var jobID: String?
    var jobName: String?
    var jobAddress: String?
    var jobCoordinates: CLLocation?
    var jobStatus: Bool?

}
