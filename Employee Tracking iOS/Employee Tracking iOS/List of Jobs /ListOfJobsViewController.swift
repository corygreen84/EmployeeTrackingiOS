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
    func loadingPassOn(loading: Bool) {
        
    }
    

    @IBOutlet weak var mainList: UITableView!
    
    var userJobs: [Job] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainList.delegate = self
        mainList.dataSource = self
        
        mainList.layer.cornerRadius = 5.0
        
        CurrentUser.sharedInstance.delegate = self
        CurrentUser.sharedInstance.loadUserJobIds()
        
    }
    
    func returnUsersJobs(jobs: [Job], status: Bool) {
        userJobs = jobs
        self.mainList.reloadData()
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userJobs.count * 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row % 2 == 0){
            return 80
        }else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row % 2 == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCellTableViewCell
            cell.layer.cornerRadius = 5.0
            
            cell.titleLabel.text = self.userJobs[indexPath.row / 2].jobName
            cell.addressLabel.text = self.userJobs[indexPath.row / 2].jobAddress
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "clear") as! ClearTableViewCell
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailView = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        detailView.job = self.userJobs[indexPath.row / 2]
        self.navigationController?.pushViewController(detailView, animated: true)
        
    }

}
