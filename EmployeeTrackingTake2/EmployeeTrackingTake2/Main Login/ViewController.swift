//
//  ViewController.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/20/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var emailToggle = false
    var companyToggle = false
    var employeePasswordToggle = false
    
    var handle: AuthStateDidChangeListenerHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // if the user is still signed in //
        // push them to the main page //
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            let tabBarView = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! MainTabBarController
            self.navigationController?.pushViewController(tabBarView, animated: true)
        }
        
        emailTextField.delegate = self
        companyTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        companyTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
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
        
        // from here we sign the user in //
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (results, error) in
            
            if(error == nil){
                
                // setting the user company //
                UserDefaultData.sharedInstance.setUserCompany(company: self.companyTextField.text!)
                let tabBarView = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! MainTabBarController
                self.navigationController?.pushViewController(tabBarView, animated: true)
            }else{
                self.alertUser(title: "Error signing in", message: "There was an error signing in.  Please try again")
            }
        }
    }
    
    func alertUser(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
    }
    


}

