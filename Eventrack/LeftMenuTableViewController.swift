//
//  LeftMenuTableViewController.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LeftMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
            case 0: return 1
            case 1: return 5
            default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTopTableViewCell", for: indexPath) as! MenuTopCell
            if FIRAuth.auth()?.currentUser == nil{
                cell.MenuTopTitle.text = "Eventrack"
                cell.loginBtn.setTitle("Log In", for: .normal)
                cell.loginBtn.addTarget(self, action: #selector(loginFC(button:)), for: .touchUpInside)
            }else{
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                let userID = FIRAuth.auth()?.currentUser?.uid
                ref.child("users").child(userID!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let displayName = value?["Display name"] as? String ?? ""
                    cell.MenuTopTitle.text = displayName
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                cell.menuDesc.text = "Welcome to Eventrack"
                
                cell.loginBtn.setTitle("Log Out", for: .normal)
                cell.loginBtn.addTarget(self, action: #selector(logoutFC(button:)), for: .touchUpInside)
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuBottomTableViewCell", for: indexPath) as! MenuBottomCell
            
            switch (indexPath.row){
            case 0:
                cell.menuText.text = "Create an Event"
                cell.menuImg.image = #imageLiteral(resourceName: "Add-Events")
            case 1:
                cell.menuText.text = "My Events"
                cell.menuImg.image = #imageLiteral(resourceName: "My-Events")
            case 2:
                cell.menuText.text = "My Tickets"
                cell.menuImg.image = #imageLiteral(resourceName: "My-Tickets")
            case 3:
                cell.menuText.text = "My Favourites"
                cell.menuImg.image = #imageLiteral(resourceName: "Favourite-Event")
            case 4:
                cell.menuText.text = "Search Events"
                cell.menuImg.image = #imageLiteral(resourceName: "Search-Events")
            default: return cell
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0{
            return 230.0
        }
        else{
            return 60.0;
        }
        
    }
 
    func loginFC(button: UIButton){
        performSegue(withIdentifier: "loginVC", sender: nil)
    }
    func logoutFC(button: UIButton){
        AuthService.instance.logout()
        showToast(message: "Successfully Logged Out")
        self.tableView.reloadData()
//        if let storyboard = self.storyboard {
//            let vc = storyboard.instantiateInitialViewController()
//            self.present(vc!, animated: false, completion: nil)
//        }
        
    }
    
    // toast function for notification
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2 - 200, width: 250, height: 100))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.numberOfLines = 2
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.9
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }


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
