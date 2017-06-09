//
//  SearchTopCell.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class SearchTopCell: UITableViewCell {
    

    // IBoutlet
    @IBOutlet weak var tokenView: KSTokenView!
    
    // cell initializor
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bringSubview(toFront: tokenView) // bring subview to front, so user can use tokenview
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
