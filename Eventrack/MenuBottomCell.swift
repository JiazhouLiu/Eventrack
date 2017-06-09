//
//  MenuBottomCell.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class MenuBottomCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var menuImg: UIImageView!
    @IBOutlet weak var menuText: UILabel!
    
    // cell initializor
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
