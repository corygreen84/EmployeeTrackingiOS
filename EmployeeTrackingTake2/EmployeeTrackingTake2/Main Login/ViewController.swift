//
//  ViewController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate, ReturnJobDataDelegate {

    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityWheel: UIActivityIndicatorView!
    
    var emailToggle = false
    var companyToggle = false
    var employeePasswordToggle = false
    
    var viewUp = false
    
    var loadUserInfo:LoadingJobs?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
 
        emailTextField.delegate = self
        companyTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        companyTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        emailTextField.text = ""
        companyTextField.text = ""
        passwordTextField.text = ""
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        
        viewUp = false
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tapGesture)
    
        signInButton.isEnabled = false
        signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        self.signInButton.layer.cornerRadius = 20.0
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        companyTextField.text = ""
        passwordTextField.text = ""
        
        emailToggle = false
        companyToggle = false
        employeePasswordToggle = false
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        
        viewUp = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyBoard()
    }
    
    
    @objc func keyboardDidShow(notif:NSNotification){
        if(!viewUp){
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y - 140, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }) { (complete) in
                self.viewUp = true
            }
        }
    }
    
    @objc func keyboardDidHide(notif:NSNotification){
        if(viewUp){
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 140, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }) { (complete) in
                self.viewUp = false
            }
        }
    }
    
    
    
    @objc func textFieldChanged(_ textField:UITextField){
        let textFieldTag = textField.tag
        
        // email //
        if(textFieldTag == 0){
            if(checkForBlankTextField(textField: textField.text!) && checkEmailForCorrectFormat(textField: textField.text!)){
                emailToggle = true
            }else{
                emailToggle = false
            }
            
            
        // company //
        }else if(textFieldTag == 1){
            if(checkForBlankTextField(textField: textField.text!)){
                companyToggle = true
            }else{
                companyToggle = false
            }
            
            
        // password //
        }else if(textFieldTag == 2){
            if(checkForBlankTextField(textField: textField.text!)){
                employeePasswordToggle = true
            }else{
                employeePasswordToggle = false
            }
        }
        
        toggleSignInButton()
    }
    
    
    // checking to make sure the text field is not blank //
    func checkForBlankTextField(textField:String) -> Bool{
        if(textField != ""){
            return true
        }else{
            return false
        }
    }
    
    func checkEmailForCorrectFormat(textField:String) -> Bool{
        if(textField.contains("@") && textField.contains(".")){
            return true
        }else{
            return false
        }
        
    }
    
    
    @objc func dismissKeyBoard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


    
    
    // toggling on and off the sign in button //
    func toggleSignInButton(){
        if(emailToggle == true && companyToggle == true && employeePasswordToggle == true){
            signInButton.isEnabled = true
            signInButton.backgroundColor = Colors.sharedInstance.lightBlue
        }else{
            signInButton.isEnabled = false
            signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        }
    }
    
    @IBAction func signInOnClick(_ sender: UIButton) {

        moveSignInButtonBack()
        
        // from here we sign the user in //
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (results, error) in
            
            if(error == nil){
                let db = Firestore.firestore()
                
                let companyRef = db.collection("companies").document(self.companyTextField.text!)
                companyRef.getDocument(completion: { (document, error) in
                    if(document!.exists){

                        // loading user info and logging in //
                        self.loadUserInfo = LoadingJobs()
                        self.loadUserInfo?.delegate = self
                        self.loadUserInfo?.loadUserPreliminaryInfo()
                    
                        
                    }else{
                        
                        self.alertUser(title: "Error signing in", message: "The company name does not match our records.  Please try again")
                        do{
                            let firebaseAuth = Auth.auth()
                            try firebaseAuth.signOut()
                        }catch let signoutError as NSError{
                            print("error signing out \(signoutError)")
                        }
                    }
                })
                
            }else{
                self.alertUser(title: "Error signing in", message: "There was an error signing in.  Please try again")
            }
        }
 
    }

    
    // once the preliminary jobs has loaded, we push the view to tab bar //
    func returnPreliminaryJobsLoaded(done: Bool) {
        if(done){
            
            moveSignInButtonForward()
            
            // if the job has finished loading the preliminary info //
            let tabBarView = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! MainTabBarController
            self.navigationController?.pushViewController(tabBarView, animated: true)
        }
    }
    
    
    
    func alertUser(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func moveSignInButtonBack(){
        UIView.animate(withDuration: 0.2, animations: {
            self.signInButton.frame = CGRect(x: self.signInButton.frame.origin.x, y: self.signInButton.frame.origin.y, width: self.signInButton.frame.size.width - 40, height: self.signInButton.frame.size.height)
        }) { (complete) in
            self.activityWheel.startAnimating()
        }
    }
    
    func moveSignInButtonForward(){
        UIView.animate(withDuration: 0.2, animations: {
            self.signInButton.frame = CGRect(x: self.signInButton.frame.origin.x, y: self.signInButton.frame.origin.y, width: self.signInButton.frame.size.width + 40, height: self.signInButton.frame.size.height)
        }) { (complete) in
            self.activityWheel.stopAnimating()
        }
    }
}

