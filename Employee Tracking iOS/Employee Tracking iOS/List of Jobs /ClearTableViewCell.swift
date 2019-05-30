//
//  ClearTableViewCell.swift
//  Employee Tracking iOS
//
//  Created by Cory Green on 5/30/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class ClearTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.backgroundColor = UIColor.clear
    }

}
