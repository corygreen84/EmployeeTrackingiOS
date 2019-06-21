//
//  JobsViewController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

class JobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReturnJobDataDelegate {

    @IBOutlet weak var mainTableView: UITableView!
    
    var company:String?
    var email:String?
    var loadUserJobs:LoadingJobs?
    
    var passedInJobs:[Jobs] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        loadUserJobs = LoadingJobs()
        loadUserJobs?.delegate = self
    }
    
    func returnDataChanged(jobId: String) {
        
        // reloading the tableview //
        //mainTableView.reloadData()
    }
    
    func returnJobData(jobs: [Jobs]) {
        passedInJobs = jobs
        
        mainTableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passedInJobs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobsCell") as! JobsCustomCell
        
        cell.NameLabel.text = passedInJobs[indexPath.row].name
        cell.AddressLabel.text = passedInJobs[indexPath.row].address
        cell.DateLabel.text = passedInJobs[indexPath.row].date
        
        return cell
    }
    
    
    
    
    
    
    
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        print("appeared!")
    }

}
