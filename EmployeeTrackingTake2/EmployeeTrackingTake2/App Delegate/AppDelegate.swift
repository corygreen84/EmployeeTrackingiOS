//
//  AppDelegate.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()

        if(Auth.auth().currentUser != nil){
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
            let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBar") as! MainTabBarController
            let navigation = UINavigationController(rootViewController: tabBarViewController)
            self.window?.rootViewController = navigation
            
            
            
            
            
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
            let viewController = storyboard.instantiateViewController(withIdentifier: "Login") as! ViewController
            let navigation = UINavigationController(rootViewController: viewController)
            self.window?.rootViewController = navigation
        }
        
        
        
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
        // sends out a notification to the GPS to turn things off before terminating... this is kind of a null issue since //
        // it gets turned off anyway.  But we do also need to sign the user out at the last moment as well... 
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "terminated"), object: self, userInfo: nil)
        
        if(Auth.auth().currentUser != nil){
            let authUser = Auth.auth()
            do{
                try authUser.signOut()
            }catch let signoutError as NSError{
                print("error signing out \(signoutError)")
            }
        }
        
        
    }


}

