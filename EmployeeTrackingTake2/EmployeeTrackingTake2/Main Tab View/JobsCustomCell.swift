//
//  JobsCustomCell.swift
//  EmployeeTrackingTake2
//
//  Created by Cory Green on 6/21/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class JobsCustomCell: UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
