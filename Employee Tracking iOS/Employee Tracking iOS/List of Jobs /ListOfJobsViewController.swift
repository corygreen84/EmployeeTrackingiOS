//
//  ListOfJobsViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ListOfJobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReturnUserJobsDelegate {

    @IBOutlet weak var mainList: UITableView!
    
    var userJobs: [Job] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainList.delegate = self
        mainList.dataSource = self
        
        CurrentUser.sharedInstance.delegate = self
        CurrentUser.sharedInstance.loadUserJobIds()
        
    }
    
    func returnUsersJobs(jobs: [Job]) {
        userJobs = jobs
        self.mainList.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userJobs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCellTableViewCell
        
        cell.titleLabel.text = self.userJobs[indexPath.row].jobName
        cell.addressLabel.text = self.userJobs[indexPath.row].jobAddress
        
        
        return cell
    }

}
