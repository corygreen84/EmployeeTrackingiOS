//
//  MainPageViewController.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/16/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var employee:CurrentUser?
    
    var cellNames = ["Jobs", "Communication"]
    var cellColors = [Colors.sharedInstance.lightBlue, Colors.sharedInstance.darkGrey]
    
    
    var locationTracking:GPSTracking?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // adding a log off button in the nav bar //
        let logOffButton:UIBarButtonItem = UIBarButtonItem(title: "Log off", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logOffOnClick))
        self.navigationItem.rightBarButtonItem = logOffButton
        
        self.navigationItem.setHidesBackButton(true, animated: true)

        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        locationTracking = GPSTracking()
        
    }
    
    
    
    
    @objc func logOffOnClick(){
        
        CurrentUser.sharedInstance.deleteUser()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionCell

        cell.mainCollectionViewLabel.text = cellNames[indexPath.row]
        cell.backgroundColor = cellColors[indexPath.row]
        
        cell.layer.cornerRadius = 5.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            let jobView = self.storyboard?.instantiateViewController(withIdentifier: "Jobs") as! ListOfJobsViewController
            self.navigationController?.pushViewController(jobView, animated: true)
        }
    }
}
