//
//  LoggingOutSpinnerAndBackground.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 6/7/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class LoggingOutSpinnerAndBackground: NSObject {

    var mainView:UIView?
    
    var opaqueBackground:UIView?
    
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    init(view:UIView) {
        super.init()
        mainView = view
        opaqueBackground = UIView(frame: self.mainView!.frame)
    }
    
    
    func createOpaqueBackground(){
        if(mainView != nil){
            
            opaqueBackground!.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
            
            self.mainView?.addSubview(opaqueBackground!)
            
            // create a spinner //
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            self.mainView?.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: self.mainView!.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: self.mainView!.centerYAnchor).isActive = true
            
            let loadingLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self.mainView?.frame.size.width)!, height: 30.0))
            loadingLabel.center = CGPoint(x: 50, y: 50)
            loadingLabel.text = "Logging Off..."
            loadingLabel.textColor = UIColor.black
            
            self.mainView?.addSubview(loadingLabel)
            
        }
    }
    
    
    func removeOpaqueBackground(){
        
        self.spinner.stopAnimating()
        
        self.opaqueBackground?.removeFromSuperview()
    }
    
    
    
}
