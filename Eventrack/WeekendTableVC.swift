//
//  WeekendTableVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class WeekendTableVC: UITableViewController {

    // variable
    @IBOutlet weak var navMenuButton: UIBarButtonItem!
    var eventsList = [Event]()
    var noFavFlag = false
    var spinner: UIActivityIndicatorView!
    var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tab bar configuration
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: uicolorFromHex(rgbValue: 0x2B8A36)], for:.selected)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // no item message setup
        message = UILabel(frame: CGRect(x: 0, y: 0, width: 170, height:40))
        message.text = "No Weekend Events"
        message.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:20)
        self.view.addSubview(message)
        message.isHidden = true
        
        loadEvents()    // load event function
        setupSpinner()  // setup spinner function
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        if self.revealViewController() != nil { // handle gesture
            navMenuButton.target = self.revealViewController()
            navMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            let swipeToLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLeftVC))
            swipeToLeftGesture.direction = .right
            self.view.addGestureRecognizer(swipeToLeftGesture)
            let swipeToRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToRightVC))
            swipeToRightGesture.direction = .left
            self.view.addGestureRecognizer(swipeToRightGesture)
            
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    // swipe left to navigate to favourite screen
    func swipeToLeftVC(_ recognizer: UISwipeGestureRecognizer) {
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToFavouriteVC), userInfo: nil, repeats: false)
    }
    func swipeToRightVC(_ recognizer: UISwipeGestureRecognizer) {
        if self.revealViewController().frontViewPosition == FrontViewPosition.right { self.revealViewController().setFrontViewPosition(FrontViewPosition.left, animated: true) }
    }
    func switchToFavouriteVC(){
        tabBarController?.selectedIndex = 1
    }
    
    
    // conver hex value to UIColor
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
        if(noFavFlag){
            message.isHidden = false
        }
        return eventsList.count
    }
    
    // configure each row in the table and display it
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegEventCell", for: indexPath) as! RegEventCell
        if eventsList.count != 0{
            self.message.isHidden = true
            sortEvents()
            //DataService.instance.increEventViewNumberByOne(eventID: eventsList[indexPath.row].eventID)
            cell.eventTitle.text = eventsList[indexPath.row].eventName
            cell.eventTag.text = eventsList[indexPath.row].eventTags.joined(separator: " ")
            cell.eventStatus.text = ""
            if let userID = FIRAuth.auth()?.currentUser?.uid{
                if eventsList[indexPath.row].getAttendees().contains(userID) {
                    cell.eventStatus.text = "Joined"    // if joined, then show joined
                    cell.eventStatus.textColor = uicolorFromHex(rgbValue: 0xFF9500)
                }
            }
            cell.eventViewNumber.text = "\(eventsList[indexPath.row].eventViewNumber)"
            cell.eventDate.text = eventsList[indexPath.row].eventDate
            cell.eventImage.image = eventsList[indexPath.row].eventPoster
        }
        return cell
    }
    
    // load events function from database
    func loadEvents(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        // get eventlist from database
        ref.child("events").child("eventsList").observe(.value) { (snapshot: FIRDataSnapshot) in
            // Get event details
            self.eventsList.removeAll()
            self.spinner.startAnimating()
            self.noFavFlag = false
            if let eventList = snapshot.value as? Dictionary<String, AnyObject>{
                for (key, value) in eventList {
                    if value is Dictionary<String, AnyObject>{
                        
                        let eventID = key
                        
                        var eventCategoryArray: [String] = [String]()
                        if let eventCategory = value["eventCategory"] as? NSArray{
                            for i in 0..<eventCategory.count {
                                eventCategoryArray.append(eventCategory[i] as! String)
                            }
                        }
                        
                        var eventTagsArray: [String] = [String]()
                        if let eventTags = value["eventTags"] as? NSArray{
                            for i in 0..<eventTags.count {
                                eventTagsArray.append(eventTags[i] as! String)
                            }
                        }
                        var likedByArray: [String] = [String]()
                        if let likedBy = value["likedBy"] as? NSArray{
                            for i in 0..<likedBy.count {
                                likedByArray.append(likedBy[i] as! String)
                            }
                        }
                        var eventAttendeeArray: [String] = [String]()
                        if let eventAttendees = value["eventAttendees"] as? NSArray{
                            for i in 0..<eventAttendees.count {
                                eventAttendeeArray.append(eventAttendees[i] as! String)
                            }
                        }
                        let eventCreator = value["eventCreator"] as? String ?? ""
                        let eventName = value["eventName"] as? String ?? ""
                        let eventDate = value["eventDate"] as? String ?? ""
                        let eventDetail = value["eventDetail"] as? String ?? ""
                        let eventStatus = value["eventStatus"] as? String ?? ""
                        let eventLocation = value["eventLocation"] as? String ?? ""
                        let eventViewNumber = value["eventViewNumber"] as? Int ?? 0
                        let storageRef: FIRStorageReference! = DataService.instance.storageRef
                        let currentEvent = Event(category: eventCategoryArray, date: eventDate, detail: eventDetail, location: eventLocation, name: eventName, poster: UIImage(named: "imagePlaceholder")!, status: eventStatus, tags: eventTagsArray, creator: eventCreator, id: eventID)
                        currentEvent.setEventViewNumber(viewNumber: eventViewNumber)
                        currentEvent.setEventLikedBy(likedBy: likedByArray)
                        currentEvent.setAttendees(attendees: eventAttendeeArray)
                        
                        // **** filter for different events *** //
                        let currentDate = Date()
                        if (currentEvent.eventStatus != "draft") && (self.stringToDate(dateString: currentEvent.eventDate) > currentDate){
                            if (currentEvent.eventDate.substring(0..<3) == "Sat") || (currentEvent.eventDate.substring(0..<3) == "Sun"){
                                self.eventsList.append(currentEvent)
                            }
                        }
                        
                        // create path for user image
                        let imagePath = "eventImage\(key)/eventPoster.jpg"
                        
                        // create image reference
                        let imageRef = storageRef.child(imagePath)
                        imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            if let error = error {
                                print("this error" + error.localizedDescription)
                            }else{
                                if let data = data {
                                    let eventImage = UIImage(data: data)!
                                    currentEvent.setPoster(poster: eventImage)
                                    self.tableView.reloadData()
                                    self.spinner.stopAnimating()
                                }
                            }
                        })
                        //self.tableView.reloadData()
                    }
                }
            }
            else{
                // handle no item exception
                self.tableView.reloadData()
                self.spinner.stopAnimating()
                let message: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 170, height:40))
                message.text = "No Weekend Events"
                message.textColor = UIColor.gray
                message.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:20)
                self.view.addSubview(message)
            }
            if self.eventsList.count == 0{
                self.noFavFlag = true
            }
        }
        
    }
    
    // setup spinner
    func setupSpinner(){
        self.spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        self.spinner.color = UIColor.darkGray
        self.spinner.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2 - 60)
        self.view.addSubview(spinner)
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
    }
    
    // sort event by date
    func sortEvents(){
        eventsList.sort(by: sorterForDateASC)
    }
    func sorterForDateASC(this:Event, that:Event) -> Bool {
        return stringToDate(dateString: this.eventDate) < stringToDate(dateString: that.eventDate)
    }
    
    // convert date String to date
    func stringToDate(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMMM dd yyyy', 'h:mm a"
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 250.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = self.tableView.indexPath(for: cell)!.row
            if segue.identifier == "ViewFromWeekendSegue" {
                // add one view to this event
                let currentEvent = self.eventsList[i]
                DataService.instance.increEventViewNumberByOne(eventID: currentEvent.eventID)
                
                let vc = segue.destination as! ViewEventTVC
                vc.currentEvent = currentEvent as Event
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
// substring of a string
public extension String {
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
}
