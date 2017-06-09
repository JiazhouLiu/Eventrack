//
//  MenuTopCell.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class MenuTopCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var MenuTopTitle: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var menuDesc: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userWelcome: UILabel!
    @IBOutlet weak var userImage: CustomizableImageView!
    
    // cell initializor
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // login Button UI modification
        loginBtn.backgroundColor = .clear
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.borderColor = UIColor.white.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
