//
//  favouriteViewController.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 2/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class favouriteViewController: UIViewController {
    
    @IBOutlet weak var navMenuButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: uicolorFromHex(rgbValue: 0x2B8A36)], for:.selected)
        UINavigationBar.appearance().tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.revealViewController() != nil {
            navMenuButton.target = self.revealViewController()
            navMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            let swipeToRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRightVC))
            swipeToRightGesture.direction = .left
            let swipeToLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLeftVC))
            swipeToLeftGesture.direction = .right
            
            self.view.addGestureRecognizer(swipeToRightGesture)
            self.view.addGestureRecognizer(swipeToLeftGesture)
            
            //let tapScreen = UITapGestureRecognizer(target: self, action: #selector(tapToCloseMenu))
            //self.view.addGestureRecognizer(tapScreen)
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    func swipeToRightVC(_ recognizer: UISwipeGestureRecognizer) {
        if self.revealViewController().frontViewPosition == FrontViewPosition.right { self.revealViewController().setFrontViewPosition(FrontViewPosition.left, animated: true) }
        else{
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToWeekendVC), userInfo: nil, repeats: false)
        }
    }
    func swipeToLeftVC(_ recognizer: UISwipeGestureRecognizer) {
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToPopularVC), userInfo: nil, repeats: false)
    }
    func switchToPopularVC(){
        tabBarController?.selectedIndex = 0
    }
    func switchToWeekendVC(){
        tabBarController?.selectedIndex = 2
    }
//    func tapToCloseMenu(_ recognizer: UITapGestureRecognizer){
//        if self.revealViewController().frontViewPosition == FrontViewPosition.right { self.revealViewController().setFrontViewPosition(FrontViewPosition.left, animated: true) }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
}
