//
//  MainPageViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/16/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class MainPageViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, ReturnUserJobsDelegate, ReturnLocationData {

    @IBOutlet weak var mainTableView: UITableView!
    
    var employee:CurrentUser?
    
    var cellNames = ["Jobs", "Communication"]
    var cellColors = [Colors.sharedInstance.lightBlue, Colors.sharedInstance.darkGrey]
    
    var locationTracking:GPSTracking?
    
    var listOfJobs:[Job] = []
    
    var employeeStatusChanged = false
    
    var listener:ListenerRegistration?
    
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
        locationTracking?.delegate = self
        
        loadUserInfoForChangesMadeByAdmin()
    }
    
    
    func locationStatusDenied() {
        self.logOffOnClick()
    }
    
    
    
    func loadUserInfoForChangesMadeByAdmin(){
        guard let userId = UserDefaults.standard.object(forKey: "userId") else{
            return
        }
        guard let userCompany = UserDefaults.standard.object(forKey: "userCompany") else{
            return
        }
        let db = Firestore.firestore()
        
    
        listener = (db.collection("companies").document(userCompany as! String).collection("employees").document(userId as! String).addSnapshotListener { (document, error) in
        
            if(error == nil){
                guard let data = document!.data() else{
                    return
                }
                
                
                if(self.employeeStatusChanged == false){
                    let currentUserInfo = CurrentUser.sharedInstance.loadUserDefaults()
                    
                    let currentUserFirstName = currentUserInfo.2
                    let currentUserLastName = currentUserInfo.3
                    let currentUserEmail = currentUserInfo.4
                    let currentUserNumber = currentUserInfo.5
                    let currentUserPhone = currentUserInfo.6
                    
                    if(currentUserFirstName != data["first"] as! String ||
                        currentUserLastName != data["last"] as! String ||
                        currentUserEmail != data["email"] as! String ||
                        currentUserNumber != data["employeeNumber"] as! Int ||
                        currentUserPhone != data["phoneNumber"] as! Int){
                        
                        self.employeeStatusChanged = true
                        
                        let alert = UIAlertController(title: "User info changed.", message: "There were changes made by the Admin to your employee info.  Please contact your admin and try logging in again with the updated info.", preferredStyle: UIAlertController.Style.alert)
                        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action) in

                            self.logOffOnClick()
                        })
                        alert.addAction(okButton)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            })
    
    }
    
    
    
    // **** this is from the shared instance of the current user **** //
    func returnUsersJobs(jobs: [Job], status: Bool) {
        if(status){

            listOfJobs = jobs
            // loading the jobs into the gps tracking //
            locationTracking?.loadUsersjobs(jobs: listOfJobs)
        }
    }
    
    
    
    @objc func logOffOnClick(){
        
        self.listener?.remove()
        
        CurrentUser.sharedInstance.deleteUser()
        CurrentUser.sharedInstance.detachListeners()
        
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
