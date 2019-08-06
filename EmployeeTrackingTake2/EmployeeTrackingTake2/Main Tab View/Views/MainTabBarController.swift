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
    
    var logOffButton:UIBarButtonItem?
 
    var backBone:Backbone?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOffButton = UIBarButtonItem(title: "Log off", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logOffOnClick))
        self.navigationItem.rightBarButtonItem = logOffButton!
        
        self.navigationItem.setHidesBackButton(true, animated: true)

        // starting up the backbone //
        Backbone.sharedInstance.initialize()
    }

    
    
    // logging off the user //
    @objc func logOffOnClick(){
        let companyName = UserDefaults.standard.object(forKey: "company") as! String
        let userId = UserDefaults.standard.object(forKey: "id") as! String
        
        let sendInfoToServer = SendInfoToServer()
        sendInfoToServer.delegate = self
        sendInfoToServer.changeStatusInFirebase(status: false, userId: userId, userCompany: companyName)
    }
    
    
    
    func returnLogOutStatus(done: Bool) {
        if(done){
            let firebaseAuth = Auth.auth()
            do{
                try firebaseAuth.signOut() // signing out of firebase //
            
            }catch let signOutError as NSError{
                print("error signing out \(signOutError)")
            }
            
        
            Backbone.sharedInstance.loggedOutBroadcast()
        
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
            let viewController = storyboard.instantiateViewController(withIdentifier: "Login") as! ViewController
            let navigation = UINavigationController(rootViewController: viewController)
            self.view.window?.rootViewController = navigation

        }
    }
}
