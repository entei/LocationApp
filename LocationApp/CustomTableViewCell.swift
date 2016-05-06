//
//  CustomTableViewCell.swift
//  LocationApp
//
//  Created by expsk on 5/5/16.
//  Copyright © 2016 pavlovsky. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    // MARK: Properties

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
