//
//  JobsViewController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

class JobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReturnBackboneDelegate{

    @IBOutlet weak var mainTableView: UITableView!
    
    var company:String?
    var email:String?

    var passedInJobs:[Jobs] = []
    
    var locationTracking:LocationTracking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self

        // loading the user data through the back bone //
        Backbone.sharedInstance.delegate = self
        Backbone.sharedInstance.loadUserJobsBackgone()

        // get GPS started ... //
        locationTracking = LocationTracking()
        
    }
    
    
    // backbone return functions //
    func returnPreliminaryJobsLoadedBackbone(done: Bool) {
        // not really used by this controller //
    }
    
    func returnJobsArrayBackbone(jobs: [Jobs]) {
        passedInJobs = jobs
        self.mainTableView.reloadData()

        // load the jobs into the location tracking //
        locationTracking!.loadJobs(jobs: passedInJobs)
    }

    
    
    
    
    
    
    
    // **** table view stuff **** //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passedInJobs.count * 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row % 2 == 0){
            return 70
        }else{
            return 20
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row % 2 == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobsCell") as! JobsCustomCell
        
            cell.NameLabel.text = passedInJobs[indexPath.row / 2].name
            cell.AddressLabel.text = passedInJobs[indexPath.row / 2].address
            cell.DateLabel.text = passedInJobs[indexPath.row / 2].date
            
            
            
            cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            cell.layer.cornerRadius = 5.0
        
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClearCell") as! ClearSeperatorCell
            
            return cell
        }
    }
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailView = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailsViewController
        detailView.job = self.passedInJobs[indexPath.row / 2]
        self.navigationController?.pushViewController(detailView, animated: true)
        
    }


}
