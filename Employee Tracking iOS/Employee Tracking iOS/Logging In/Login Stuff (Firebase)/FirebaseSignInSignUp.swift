//
//  FirebaseSignInSignUp.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/14/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

@objc protocol ReturnSignInSignUpDelegate{
    func returnSignUpSignInStatus(signInOrCreate: Bool, success: Bool, title: String, message: String)
}

class FirebaseSignInSignUp: NSObject {
    
    var delegate: ReturnSignInSignUpDelegate?
    
    override init() {
        super.init()
    }
    
    // signing up //
    func signUp(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if(error == nil){
                self.delegate?.returnSignUpSignInStatus(signInOrCreate: true, success: true, title: "Success", message: "You have successfully created a new account")
            }else{
                self.delegate?.returnSignUpSignInStatus(signInOrCreate: true, success: false, title: "Error", message: "There was an error creating a new account.  Please try again.")
            }
        }
    }
    
    // signing in //
    func signIn(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if(error == nil){
                self.delegate?.returnSignUpSignInStatus(signInOrCreate: false, success: true, title: "Success", message: "You have successfully signed in.")
            }else{
                self.delegate?.returnSignUpSignInStatus(signInOrCreate: false, success: false, title: "Error", message: "There was an error signing in.  Please try again.")
            }
        }
    }
    
    
}


