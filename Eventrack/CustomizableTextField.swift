//
//  CustomizableTextField.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 21/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableTextField: UITextField {

    
    // add cornerRadius attribute for UITextField
    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    // add cornerRadius attribute for UITextField
    @IBInspectable var borderWidth: CGFloat = 0 {
        
        didSet{
            layer.borderWidth = borderWidth
        }
    }
}
