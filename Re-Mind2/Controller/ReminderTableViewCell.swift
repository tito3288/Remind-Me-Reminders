//
//  ReminderTableViewCell.swift
//  Re-Mind2
//
//  Created by Bryan Arambula on 2/22/22.
//

import UIKit
import QuartzCore

class ReminderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
            
        detailsLabel.layer.cornerRadius = 5
        detailsLabel.layer.masksToBounds = true
    }
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var bodyLabel:UILabel!
    @IBOutlet weak var detailsLabel:UILabel!

}
