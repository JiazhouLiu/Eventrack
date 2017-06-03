//
//  PopularTableVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class PopularTableVC: UITableViewController {

    @IBOutlet weak var navMenuButton: UIBarButtonItem!
    //static var eventNum: Int = 0
    var eventsArray = [Dictionary<String, AnyObject>]()
    var initialLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: uicolorFromHex(rgbValue: 0x2B8A36)], for:.selected)
        UINavigationBar.appearance().tintColor = UIColor.white
        self.addSampleCat()
        
        
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        ref.child("events").child("eventsList").observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            // Get event details
            if let eventList = snapshot.value as? Dictionary<String, AnyObject>{
                for (_, value) in eventList {
                    if value is Dictionary<String, AnyObject>{
                        self.tableView.reloadData()
                        self.initialLoad = false
                        print("\(self.eventsArray.count) and \(self.initialLoad)")
                        //PopularTableVC.eventNum += 1
                        //print(self.eventNum)
                        let eventName = value["eventName"] as? String ?? ""
                        
                        let eventDate = value["eventDate"] as? String ?? ""
                        let eventTag = value["eventTag"] as? String ?? ""
                        let eventStatus = value["eventStatus"] as? String ?? ""
                        let storageRef: FIRStorageReference! = DataService.instance.storageRef
                        // create path for user image
                        let imagePath = "eventImage\(eventName.removingWhitespaces())/eventPoster.jpg"
                        
                        // create image reference
                        let imageRef = storageRef.child(imagePath)
                        imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }else{
                                if let data = data {
                                    let eventImage = UIImage(data: data)!
                                    self.eventsArray.append(["name": eventName as AnyObject, "date": eventDate as AnyObject, "tag": eventTag as AnyObject, "image": eventImage, "status": eventStatus as AnyObject])
                                    //print("first: \(self.eventsArray.count)")
                                    
                                }
                                
                            }
                        })
                        
                        
                    }
                }
                
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        if ( self.initialLoad == false ) {
            self.tableView.reloadData()
        }
        print("\(self.eventsArray.count) and \(self.initialLoad)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        eventsArray.removeAll()
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
    
    func handleChildAdded(snapshot: FIRDataSnapshot) {
        
        
        
        //upon first load, don't reload the tableView until all children are loaded
        if ( self.initialLoad == false ) {
            self.tableView.reloadData()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print(PopularTableVC.eventNum)
        /*if let numberRows = self.eventsArray.count{
            //print(numberRows)
            return numberRows
        }*/
        
        return 5
    }
    
    func addSampleCat(){
        DataService.instance.saveEventCategory(cat: "Ceremony")
        DataService.instance.saveEventCategory(cat: "Concert")
        DataService.instance.saveEventCategory(cat: "Conference")
        DataService.instance.saveEventCategory(cat: "Exhibit")
        DataService.instance.saveEventCategory(cat: "Festival")
        DataService.instance.saveEventCategory(cat: "Film")
        DataService.instance.saveEventCategory(cat: "Fundraiser")
        DataService.instance.saveEventCategory(cat: "Heat Athletics")
        DataService.instance.saveEventCategory(cat: "Information Session/Fair")
        DataService.instance.saveEventCategory(cat: "Lecture")
        DataService.instance.saveEventCategory(cat: "Meeting")
        DataService.instance.saveEventCategory(cat: "Party")
        DataService.instance.saveEventCategory(cat: "Performance")
        DataService.instance.saveEventCategory(cat: "Protest")
        DataService.instance.saveEventCategory(cat: "Reception")
        DataService.instance.saveEventCategory(cat: "Recreation and Intramurals")
        DataService.instance.saveEventCategory(cat: "Reunion")
        DataService.instance.saveEventCategory(cat: "Seminar")
        DataService.instance.saveEventCategory(cat: "Theatre")
        DataService.instance.saveEventCategory(cat: "Thunderbird Athletics")
        DataService.instance.saveEventCategory(cat: "Workshop")
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegEventCell", for: indexPath) as! RegEventCell/*
        cell.eventTitle.text = eventsArray[indexPath.row]["name"] as? String
        cell.eventStatus.text = eventsArray[indexPath.row]["status"] as? String
        cell.eventTag.text = eventsArray[indexPath.row]["tag"] as? String
        cell.eventDate.text = eventsArray[indexPath.row]["date"] as? String
        cell.eventImage.image = eventsArray[indexPath.row]["image"] as? UIImage*/
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 250.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
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
