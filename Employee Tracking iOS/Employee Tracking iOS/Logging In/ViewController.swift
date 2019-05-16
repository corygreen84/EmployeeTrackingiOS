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
    @IBOutlet weak var mainBackgroundImage: UIImageView!
    
    var emailToggle = false
    var companyToggle = false
    var employeeNumberToggle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // right away we should check to see if there is any data saved for the user //
        if(CurrentUser.sharedInstance.checkToSeeIfUserExists()){
            let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! MainPageViewController
            self.navigationController?.pushViewController(mainPage, animated: true)
        }
        
        emailTextField.delegate = self
        companyTextField.delegate = self
        employeeNumberTextField.delegate = self
        
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        companyTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        employeeNumberTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tapGesture)
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = Colors.sharedInstance.darkGrey
        signInButton.layer.cornerRadius = 5.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        companyTextField.text = ""
        employeeNumberTextField.text = ""
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
    
    @objc func dismissKeyBoard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
                if(doc!.documents.count == 0){
                    self.alertUser(title: "Error signing in.", message: "There was an error signing in.  Please check your log in credentials and try signing in again or contact your admin.")
                }
                //let newUser:CurrentUser = CurrentUser()
                var exists = false
                for document in doc!.documents{
                    var documentData = document.data()
                    let empTextField:Int? = Int(self.employeeNumberTextField.text!)
                    if(documentData["email"] as? String == self.emailTextField.text &&
                        documentData["employeeNumber"] as? Int == empTextField){
                        
                        CurrentUser.sharedInstance.userID = document["id"] as? String
                        CurrentUser.sharedInstance.userCompany = self.companyTextField.text!
                        CurrentUser.sharedInstance.userFirstName = document["first"] as? String
                        CurrentUser.sharedInstance.userLastName = document["last"] as? String
                        CurrentUser.sharedInstance.userEmail = document["email"] as? String
                        CurrentUser.sharedInstance.userStatus = document["status"] as? Bool
                        CurrentUser.sharedInstance.userPhoneNumber = document["phoneNumber"] as? Int
                        CurrentUser.sharedInstance.userNumber = document["employeeNumber"] as? Int
                        CurrentUser.sharedInstance.userJobs = document["jobs"] as? [String]
                        
                        CurrentUser.sharedInstance.saveUserToDefaults()
                        
                        // passing the data to the next view //
                        let mainPage = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! MainPageViewController
                        self.navigationController?.pushViewController(mainPage, animated: true)
                        return
                    }else{
                        exists = false
                    }
                    
                }
                
                if(exists == false){
                    self.alertUser(title: "Error signing in.", message: "There was an error signing in.  Please check your log in credentials and try signing in again or contact your admin.")
                }
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

