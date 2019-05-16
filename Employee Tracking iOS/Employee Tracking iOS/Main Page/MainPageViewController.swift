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
    
    var cellNames = ["Jobs", "Communication"]
    var cellColors = [Colors.sharedInstance.lightBlue, Colors.sharedInstance.darkGrey]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellNames.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCollectionViewCell", for: indexPath) as! MainPageCustomCollectionViewCollectionViewCell
        
        cell.mainCollectionViewLabel.text = cellNames[indexPath.row]
        cell.backgroundColor = cellColors[indexPath.row]
        
        cell.layer.cornerRadius = 10.0
        
        return cell
    }
    
    
    
    
    

}
