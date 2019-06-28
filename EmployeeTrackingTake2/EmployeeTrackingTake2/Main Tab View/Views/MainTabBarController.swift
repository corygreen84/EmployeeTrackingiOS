//
//  MainTabBarController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//




// from here we should present the user with the various tabs //
// the GPS should also be started up and managed //

import UIKit
import Firebase

class MainTabBarController: UITabBarController, ReturnStatusOfLogout{
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var passedInCompany:String?

    var loadUserInfo:LoadingJobs?
    var locationTracking:LocationTracking?
    
    var sendInfoToServer:SendInfoToServer?
    
    var alertToggle = false
    
    var userChangeHandler:ListenerRegistration?
    
    var logOffButton:UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // making sure that the user data has been loaded properly before trying to use it //
        NotificationCenter.default.addObserver(self, selector: #selector(loadedData), name: NSNotification.Name(rawValue: "doneLoadingUserInfo"), object: nil)

        // adding a log off button in the nav bar //
        logOffButton = UIBarButtonItem(title: "Log off", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logOffOnClick))
        self.navigationItem.rightBarButtonItem = logOffButton!
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        
        logOffButton!.isEnabled = false
        
        
    }

    @objc func loadedData(){
        
        logOffButton!.isEnabled = true
        // creating a listener for when employee data changes in the background //
        let company = UserDefaults.standard.object(forKey: "company") as! String
        let id = UserDefaults.standard.object(forKey: "id") as! String
        
        // setting a snapshot listener for when the employees data changes //
        let db = Firestore.firestore()
        userChangeHandler = db.collection("companies").document(company).collection("employees").document(id).addSnapshotListener { (document, error) in
            if(error == nil){
                
                
                guard let data = document?.data() else{
                    return
                }
                guard let employeeNumber = data["employeeNumber"] else{
                    return
                }
                guard let email = data["email"] else{
                    return
                }
                guard let phoneNumber = data["phoneNumber"] else{
                    return
                }
                guard let first = data["first"] else{
                    return
                }
                guard let last = data["last"] else{
                    return
                }
                guard let pass = data["password"] else{
                    return
                }
                
                if(employeeNumber as! Int != UserDefaults.standard.object(forKey: "employeeNumber") as! Int ||
                    email as! String != UserDefaults.standard.object(forKey: "email") as! String ||
                    phoneNumber as! Int != UserDefaults.standard.object(forKey: "phoneNumber") as! Int ||
                    first as! String != UserDefaults.standard.object(forKey: "first") as! String ||
                    last as! String != UserDefaults.standard.object(forKey: "last") as! String ||
                    pass as! String != UserDefaults.standard.object(forKey: "pass") as! String){
                    
                    if(self.alertToggle == false){
                    
                        self.alertUser(title: "Logging Out", message: "The admin has changed your personal data on the backend.  Please sign back in using the updated credentials")
                        self.alertToggle = true
                    }
                }
            }
        }
    }
    
    
    
    
    func alertUser(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            self.logOffOnClick()
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    // logging off the user //
    @objc func logOffOnClick(){
        
        // need to send out a signal to let the GPS know that the user has logged off //
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loggedOff"), object: self, userInfo: nil)
        
        self.userChangeHandler?.remove()

        // logging off in firebase //
        let company = UserDefaults.standard.object(forKey: "company") as! String
        let id = UserDefaults.standard.object(forKey: "id") as! String
        
        
        // this sends the status back to the server that the user //
        // has logged out... it also sends a packet of data //
        // with the users log out info
        sendInfoToServer = SendInfoToServer()
        sendInfoToServer!.delegate = self
        sendInfoToServer!.changeStatusInFirebase(status: false, userId: id, userCompany: company)
    }
    

    
    
    
    func returnLogOutStatus(done: Bool) {
        if(done){
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
