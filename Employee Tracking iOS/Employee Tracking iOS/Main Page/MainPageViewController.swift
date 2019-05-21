//
//  MainPageViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/16/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, ReturnUserJobsDelegate {

    
    @IBOutlet weak var mainTableView: UITableView!
    
    var employee:CurrentUser?
    
    var cellNames = ["Jobs", "Communication"]
    var cellColors = [Colors.sharedInstance.lightBlue, Colors.sharedInstance.darkGrey]
    
    var locationTracking:GPSTracking?
    
    var listOfJobs:[Job] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
    
        // adding a log off button in the nav bar //
        let logOffButton:UIBarButtonItem = UIBarButtonItem(title: "Log off", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logOffOnClick))
        self.navigationItem.rightBarButtonItem = logOffButton
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        
        
        
        // loading the users jobs //
        CurrentUser.sharedInstance.delegate = self
        CurrentUser.sharedInstance.loadUserJobIds()
        
        // start up the gps tracking //
        locationTracking = GPSTracking()
    }
    
    
    
    // **** this is from the shared instance of the current user **** //
    func returnUsersJobs(jobs: [Job]) {
        listOfJobs = jobs
    }
    
    // this gets called when the users jobs have finished loading //
    func usersJobsDoneLoading(done: Bool) {
        if(done){
            
            // loading the jobs into the gps tracking //
            locationTracking?.loadUsersjobs(jobs: listOfJobs)
        }
    }
    
    // **** end of the shared instance of the current user **** //
    
    
    
    @objc func logOffOnClick(){
        CurrentUser.sharedInstance.deleteUser()
        
        locationTracking?.endLocationTracking()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
    
    
    // table view stuff //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainTableCell", for: indexPath) as! MainPageTableViewCell
        cell.mainLabel.text = self.cellNames[indexPath.row]
        cell.mainLabel.textColor = UIColor.white
        cell.backgroundColor = self.cellColors[indexPath.row]
        
        cell.layer.cornerRadius = 10.0
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            
            let selectedRow:UITableViewCell = tableView.cellForRow(at: indexPath)!
            selectedRow.contentView.backgroundColor = Colors.sharedInstance.lightBlue
            
            let jobView = self.storyboard?.instantiateViewController(withIdentifier: "Jobs") as! ListOfJobsViewController
            self.navigationController?.pushViewController(jobView, animated: true)
        }
    }
}
