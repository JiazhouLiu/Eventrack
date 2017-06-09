//
//  categoryCell.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 22/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class categoryCell: UITableViewCell {

    // cell initilizor
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false;                        //cell's view
        self.contentView.clipsToBounds = false;            //contentView
        self.contentView.superview?.clipsToBounds = false;
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }
   
}
