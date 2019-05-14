//
//  CreateUserViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/14/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var employeeNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var firstNameFilled = false
    var lastNameFilled = false
    var emailFilled = false
    var companyFilled = false
    var employeeNumberFilled = false
    var passwordFilled = false
    
    var textCheck:TextFieldChecks?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signUpButton.isEnabled = false
        self.signUpButton.backgroundColor = Colors.sharedInstance.darkGrey
        
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.companyTextField.delegate = self
        self.employeeNumberTextField.delegate = self
        self.passwordTextField.delegate = self
        
        textCheck = TextFieldChecks()
        
        self.firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.companyTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.employeeNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // checking to make sure things are good to go before submitting //
    @objc func textFieldDidChange(_ textField: UITextField){
        if(textField.tag == 0){
            // first name //
            if(textCheck?.checkTextFieldForBlanks(text: textField.text!) == true){
                firstNameFilled = true
            }else{
                firstNameFilled = false
            }
        }else if(textField.tag == 1){
            // last name //
            if(textCheck?.checkTextFieldForBlanks(text: textField.text!) == true){
                lastNameFilled = true
            }else{
                lastNameFilled = false
            }
        }else if(textField.tag == 2){
            // email //
            if(textCheck?.checkEmailFieldForCredentials(text: textField.text!) == true){
                emailFilled = true
            }else{
                emailFilled = false
            }
        }else if(textField.tag == 3){
            // company //
            if(textCheck?.checkTextFieldForBlanks(text: textField.text!) == true){
                emailFilled = true
            }else{
                emailFilled = false
            }
        }else if(textField.tag == 4){
            // employee number //
            if(textCheck?.checkTextFieldForBlanks(text: textField.text!) == true){
                employeeNumberFilled = true
            }else{
                employeeNumberFilled = false
            }
        }else if(textField.tag == 5){
            // password //
            if(textCheck?.checkTextFieldForBlanks(text: textField.text!) == true){
                passwordFilled = true
            }else{
                passwordFilled = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    func toggleSignUpButton(){
        if(firstNameFilled == true &&
            lastNameFilled == true &&
            emailFilled == true &&
            companyFilled == true &&
            employeeNumberFilled == true &&
            passwordFilled == true){
            self.signUpButton.isEnabled = true
            self.signUpButton.backgroundColor = Colors.sharedInstance.lightBlue
        }else{
            self.signUpButton.isEnabled = false
            self.signUpButton.backgroundColor = Colors.sharedInstance.darkGrey
        }
    }

}
