//
//  ViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/13/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var employeeNumberTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var emailToggle = false
    var companyToggle = false
    var employeeNumberToggle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        companyTextField.delegate = self
        employeeNumberTextField.delegate = self
        
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        companyTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        employeeNumberTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        signInButton.layer.cornerRadius = 5.0
    }
    
    
    
    // checking for changes in the text field //
    @objc func textFieldChanged(_ textField:UITextField){
        let textFieldTag = textField.tag
        if(textFieldTag == 0){
            if(checkForBlankTextField(textField: textField.text!) && checkEmailForCorrectFormat(textField: textField.text!)){
                emailToggle = true
            }else{
                emailToggle = false
            }
        }else if(textFieldTag == 1){
            if(checkForBlankTextField(textField: textField.text!)){
                employeeNumberToggle = true
            }else{
                employeeNumberToggle = false
            }
        }else if(textFieldTag == 2){
            if(checkForBlankTextField(textField: textField.text!)){
                companyToggle = true
            }else{
                companyToggle = false
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
    
    
    func toggleSignInButton(){
        if(emailToggle == true && companyToggle == true && employeeNumberToggle == true){
            signInButton.isEnabled = true
            signInButton.backgroundColor = Colors.sharedInstance.lightBlue
        }else{
            signInButton.isEnabled = false
            signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        }
    }
    
    
    
    
    
    @IBAction func signInOnClick(_ sender: UIButton) {
        
        let db = Firestore.firestore()
        let ref = db.collection("companies").document(companyTextField.text!).collection("employees")
        ref.getDocuments { (doc, error) in
            if(doc != nil && error == nil){
                let newUser:CurrentUser = CurrentUser()
                for document in doc!.documents{
                    var documentData = document.data()
                    if(documentData["email"] as? String == self.emailTextField.text){
                        
                        newUser.userID = documentData["id"] as? String
                        newUser.userEmail = documentData["email"] as? String
                        newUser.userFirstName = documentData["first"] as? String
                        newUser.userLastName = documentData["last"] as? String
                        newUser.userPhoneNumber = documentData["phoneNumber"] as? Int
                        newUser.userNumber = documentData["employeeNumber"] as? Int
                        newUser.userJobs = documentData["jobs"] as? [String]
                    }
                }
                
                // passing the data to the next view //
                let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! MainPageViewController
                mainPage.employee = newUser
                self.navigationController?.pushViewController(mainPage, animated: true)
            }else{
                self.alertUser(title: "Error signing in.", message: "There was an error signing in.  Please check your log in credentials and try signing in again or contact your admin.")
                
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

