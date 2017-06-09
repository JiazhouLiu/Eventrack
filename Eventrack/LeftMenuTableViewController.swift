//
//  LeftMenuTableViewController.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LeftMenuTableViewController: UITableViewController {

    var spinner: UIActivityIndicatorView!
    
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
            case 1: return 6    // 6 navations
            default: return 0
        }
    }

    @IBAction func titleTapped(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil{
            performSegue(withIdentifier: "leftPanelToProfile", sender: nil) // navigate to profile screen
        }
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTopTableViewCell", for: indexPath) as! MenuTopCell
            if FIRAuth.auth()?.currentUser == nil{ // Not log in status
                cell.loginBtn.setTitle("Log In", for: .normal)
                cell.loginBtn.addTarget(self, action: #selector(loginFC(button:)), for: .touchUpInside)
                cell.loginBtn.isHidden = false
                cell.MenuTopTitle.isHidden = false
                cell.menuDesc.isHidden = false
                cell.userNameLabel.isHidden = true
                cell.userImage.isHidden = true
                cell.userWelcome.isHidden = true
            }else{  // Logged in status
                cell.loginBtn.isHidden = true
                cell.MenuTopTitle.isHidden = true
                cell.menuDesc.isHidden = true
                cell.userNameLabel.isHidden = false
                cell.userImage.isHidden = false
                cell.userWelcome.isHidden = false
                var ref: FIRDatabaseReference!
                ref = FIRDatabase.database().reference()
                let userID = FIRAuth.auth()?.currentUser?.uid
                
                self.spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
                self.spinner.color = UIColor.lightGray
                self.spinner.center = cell.userImage.center
                cell.contentView.addSubview(spinner)
                self.spinner.hidesWhenStopped = true
                self.spinner.startAnimating()
                
                // get user attribute from database and display it in the top cell
                ref.child("users").child(userID!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let displayName = value?["username"] as? String ?? ""
                    cell.userNameLabel.text = displayName
                    
                    let storageRef: FIRStorageReference! = DataService.instance.storageRef
                    // create path for user image
                    let imagePath = "profileImage\(userID!)/userPic.jpg"
                    
                    // create image reference
                    let imageRef = storageRef.child(imagePath)
                    imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }else{
                            if let data = data {
                                cell.userImage.image = UIImage(data: data)
                                self.spinner.stopAnimating()
                            }
                        }
                    })
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
            return cell
        }
        else{   // bottom cells
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuBottomTableViewCell", for: indexPath) as! MenuBottomCell
            
            switch (indexPath.row){
            case 0: // create event function and screen
                cell.menuText.text = "Create an Event"
                cell.menuImg.image = #imageLiteral(resourceName: "Add-Events")
            case 1: // my event function and screen
                cell.menuText.text = "My Events"
                cell.menuImg.image = #imageLiteral(resourceName: "My-Events")
            case 2: // my ticket function and screen
                cell.menuText.text = "My Tickets"
                cell.menuImg.image = #imageLiteral(resourceName: "My-Tickets")
            case 3: // my favourite function and screen
                cell.menuText.text = "My Favourites"
                cell.menuImg.image = #imageLiteral(resourceName: "Favourite-Event")
            case 4: // search event function and screen
                cell.menuText.text = "Search Events"
                cell.menuImg.image = #imageLiteral(resourceName: "Search-Events")
            case 5: // about page screen
                cell.menuText.text = "About Page"
                cell.menuImg.image = #imageLiteral(resourceName: "about")
            default: return cell
            }
            
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0{
            return 230.0    // top cell height
        }
        else{
            return 60.0;    // bottom cells height
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if section == 1{
            switch row{
            case 0:
                // Create an event
                if FIRAuth.auth()?.currentUser != nil{
                    performSegue(withIdentifier: "LeftMenuToCreate", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Login Required", message: "You must login first to create an event", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
                break
            case 1:
                // My Events
                if FIRAuth.auth()?.currentUser != nil{
                    performSegue(withIdentifier: "LeftMenuToMyEvents", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Login Required", message: "You must login first to view my events", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
                break
            case 2:
                //My Tickets
                if FIRAuth.auth()?.currentUser != nil{
                    performSegue(withIdentifier: "LeftMenuToMyTickets", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Login Required", message: "You must login first to view my tickets", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
                break
            case 3:
                //My favourite
                if FIRAuth.auth()?.currentUser != nil{
                    performSegue(withIdentifier: "LeftMenuToFavouriteSegue", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Login Required", message: "You must login first to view my favourite events", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
                break
            case 4:
                // Search Events
                performSegue(withIdentifier: "LeftMenuToSearchSegue", sender: nil)
                break
            case 5:
                performSegue(withIdentifier: "LeftMenuToAboutSegue", sender: nil)
            default:
                break
            }
        }
    }

 
    func loginFC(button: UIButton){
        performSegue(withIdentifier: "loginVC", sender: nil)    // navigate to login screen
    }
    
    // logout function
    func logoutFC(button: UIButton){
        AuthService.instance.logout()
        let alertController = UIAlertController(title: "Success", message: "You have successfully logged out!", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateInitialViewController()
                self.present(vc!, animated: true, completion: nil)
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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

    // prepare for segue and congigure the tab bar view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LeftMenuToFavouriteSegue"{
            let svc = segue.destination as! UITabBarController;
            svc.selectedIndex = 1
        }
        
    }

}
