//
//  JobsViewController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

class JobsViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var company:String?
    
    var email:String?
    
    var loadUserJobs:LoadingJobs?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserJobs = LoadingJobs()
        
    }
    
    
    
    func loadJobs(){
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        print("appeared!")
    }

}
