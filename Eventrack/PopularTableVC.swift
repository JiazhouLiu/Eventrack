//
//  PopularTableVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class PopularTableVC: UITableViewController {

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
            
            revealViewController().rearViewRevealWidth = 300
            navMenuButton.target = self.revealViewController()
            navMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            
            let swipeToRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRightVC))
            swipeToRightGesture.direction = .left
            self.view.addGestureRecognizer(swipeToRightGesture)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
        }
        
    }
    
    func swipeToRightVC(_ recognizer: UISwipeGestureRecognizer) {
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToFavouriteVC), userInfo: nil, repeats: false)
    }
    func switchToFavouriteVC(){
        tabBarController?.selectedIndex = 1
    }
    
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
