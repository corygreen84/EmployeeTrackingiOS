//
//  ViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/13/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ReturnSignInSignUpDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var signInAndCreate:FirebaseSignInSignUp?
    
    var textFieldCheck:TextFieldChecks?
    
    var emailAddressCorrect = false
    var passwordCorrect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInAndCreate = FirebaseSignInSignUp()
        signInAndCreate?.delegate = self
        
        textFieldCheck = TextFieldChecks()
        
        // assigning the text fields their delegate //
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // adding detection of text entry //
        self.usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // disabling the sign in button at startup //
        self.signInButton.isEnabled = false
        self.signInButton.setTitleColor(UIColor.white, for: UIControl.State.disabled)
        self.signInButton.backgroundColor = Colors.sharedInstance.darkGrey
    }
    
    // call back from the sign in or create user process //
    func returnSignUpSignInStatus(signInOrCreate: Bool, success: Bool, title: String, message: String) {
        
        self.alertUser(title: title, message: message)
    }
    
    
    
    // detecting text entry //
    @objc func textFieldDidChange(_ textField: UITextField){
        if(textField.tag == 0){
            // email //
            if(textFieldCheck?.checkTextFieldForBlanks(text: textField.text!) == true && textFieldCheck?.checkEmailFieldForCredentials(text: textField.text!) == true){
                emailAddressCorrect = true
            }else{
                emailAddressCorrect = false
            }
        }else if(textField.tag == 1){
            // password //
            if(textFieldCheck?.checkTextFieldForBlanks(text: textField.text!) == true){
                passwordCorrect = true
            }else{
                passwordCorrect = false
            }
        }
        toggleSignInButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    
    
    
    
    // toggles the visibility of the sign in button //
    func toggleSignInButton(){
        if(emailAddressCorrect == true && passwordCorrect == true){
            self.signInButton.isEnabled = true
            self.signInButton.backgroundColor = Colors.sharedInstance.lightBlue
        }else{
            self.signInButton.isEnabled = false
            self.signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        }
    }
    
    
    
    
    
    // button clicks //
    @IBAction func signInOnClick(_ sender: UIButton) {
        
        signInAndCreate?.signIn(email: usernameTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func signUpOnClick(_ sender: UIButton) {
        
        let signUp = self.storyboard?.instantiateViewController(withIdentifier: "Create") as! CreateUserViewController
        self.navigationController?.pushViewController(signUp, animated: true)
    
    }
    
    @IBAction func forgotPasswordOnClick(_ sender: UIButton) {
        
    }
    
    
    @IBAction func adminOnClick(_ sender: UIButton) {
        
    }
    

    // alerting the user //
    func alertUser(title:String ,message: String){
        let alert = UIAlertController(title: "Error \(title)", message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

