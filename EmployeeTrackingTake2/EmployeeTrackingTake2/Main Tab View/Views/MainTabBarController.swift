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

class MainTabBarController: UITabBarController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var passedInCompany:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // adding a log off button in the nav bar //
        let logOffButton:UIBarButtonItem = UIBarButtonItem(title: "Log off", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logOffOnClick))
        self.navigationItem.rightBarButtonItem = logOffButton
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        
        // just in case the user state changes in the middle of this page //
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user == nil){
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // logging off the user //
    @objc func logOffOnClick(){
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }catch let signoutError as NSError{
            print("error signing out \(signoutError)")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

}
