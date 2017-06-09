//
//  CommentCell.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 9/6/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    // cell IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    
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
