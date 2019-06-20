//
//  SendLogOffTextFile.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 6/6/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Firebase

@objc protocol ReturnStatusOfFileLoadToFirebaseDelegate{
    func status(loading:Bool)
}

class SendLogOffTextFile: NSObject {
    
    var listener:ListenerRegistration?
    
    let db = Firestore.firestore()
    
    var dayMonthYear:DateFormatter?
    var hourMinute:DateFormatter?
    
    var delegate:ReturnStatusOfFileLoadToFirebaseDelegate?
    
    override init(){
        super.init()
    }
    
    
    func loadUserInfoFromServer(userCompany:String, userId:String){
        
        
        dayMonthYear = DateFormatter()
        dayMonthYear?.dateFormat = "MM-dd-yyyy"
        
        hourMinute = DateFormatter()
        hourMinute?.dateFormat = "HH:mm"
        
        
        let date = Date()
        let dayMonthYearString:String = ((dayMonthYear?.string(from: date))!)
        
        let hourMinuteString:String = ((hourMinute?.string(from: date))!)
        
        self.delegate?.status(loading: true)
        
        // getting data once //
        db.collection("companies").document(userCompany).collection("employees").document(userId).getDocument { (document, error) in
            if let document = document, document.exists{
                guard let data = document.data() else{
                    return
                }
                let _data = data["jobHistory"]
                if(_data != nil){
                    let returnedString = self.removeBackSlashFromString(text: "\(_data!)")
                    //print(returnedString)
                    
                    self.sendTextFileToServer(text: returnedString, company: userCompany, id: userId, dayMonthYearString: dayMonthYearString, hourMinuteString: hourMinuteString)
                    
                    
                }else{
                    print("data is nil")
                }
            }
        }
    }
    
    func sendTextFileToServer(text:String, company:String, id:String, dayMonthYearString: String, hourMinuteString: String){
        
        
        let fileName = "\(dayMonthYearString)"
        
    
        // writing to a local file //
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let fileURL = dir.appendingPathComponent(fileName)
            let filePath = fileURL.path
            do{
                // try to write the text file //
                try text.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
            }catch{
                print("error writing to file")
            }
            
            
            // reading from the file //
            var readString = ""
            do{
                readString = try String(contentsOf: fileURL)
            }catch let error as NSError{
                print("failed to load \(error.localizedDescription)")
            }
            
            if(readString != ""){
                let storage = Storage.storage()
                let storageRef = storage.reference()
                
                let stringData = Data(readString.utf8)
                let textReference = storageRef.child("\(company)/\(id)/\(fileName).txt")
                
                _ = textReference.putData(stringData, metadata: nil) { (metaData, error) in
                    
                    // success in uploading //
                    // now we can delete the file from local storage //
                    do{
                        let fileManager = FileManager.default
                        if(fileManager.fileExists(atPath: filePath)){
                            
                            try fileManager.removeItem(atPath: filePath)
                            self.delegate?.status(loading: false)
                            
                            
                        }else{
                            print("file does not exist")
                        }
                        
                    }catch{
                        print("error deleting")
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    func removeBackSlashFromString(text:String) -> String{
        var targetString:String?
        targetString = text.replacingOccurrences(of: "\\", with: "")
        return targetString!
    }
    
}


