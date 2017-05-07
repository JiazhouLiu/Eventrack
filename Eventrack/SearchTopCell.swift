//
//  SearchTopCell.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class SearchTopCell: UITableViewCell {
    

    @IBOutlet weak var tokenView: KSTokenView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bringSubview(toFront: tokenView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
