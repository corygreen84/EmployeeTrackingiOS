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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        companyTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        companyTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tapGesture)
    
        //self.textFieldView.layer.cornerRadius = 20.0
        self.signInButton.layer.cornerRadius = 20.0
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
                print("log in successful!")
            }else{
                print("no go!")
            }
        }
        
        
    }
    


}

