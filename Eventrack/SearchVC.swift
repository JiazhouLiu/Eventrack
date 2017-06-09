//
//  SearchVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variables
    @IBOutlet weak var serchBtn: CustomizableButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var TV: UITableView!
    var categories = [String]()
    var searchCategories: Array<String> = []
    var eventsList = [Event]()
    var spinner: UIActivityIndicatorView!
    var message: UILabel!
    var noEventFlag = false

    // search button pressed
    @IBAction func searchBtnPressed(_ sender: Any) {
        self.view.endEditing(true)
        loadEvents()
        self.spinner.startAnimating()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get categories from database for tokenView
        DataService.instance.categoryRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            if let cat = snapshot.value as? Dictionary<String, AnyObject>{
                for (key, _) in cat{
                    self.categories.append(key)
                }
            }
            self.self.tokenView.delegate = self
            self.tokenView.promptText = "Categories: "
            self.tokenView.placeholder = "Type to add categories"
            self.tokenView.descriptionText = "Selected"
            self.tokenView.maxTokenLimit = -1 //default is -1 for unlimited number of tokens
            self.tokenView.minimumCharactersToSearch = 0 // Show all results without without typing anything
            self.tokenView.style = .squared
            self.tokenView.direction = .horizontal
            self.tokenView.shouldAddTokenFromTextInput = false
            self.tokenView.paddingY = 12.0
            self.tokenView.marginX = 8.0
            self.view.bringSubview(toFront: self.tokenView)
            self.view.sendSubview(toBack: self.TV)
            self.view.sendSubview(toBack: self.searchBar)
        }
        
        
        // Do any additional setup after loading the view.
        
        //self.TV.register(RegEventCell.self, forCellReuseIdentifier: "RegEventCell")
        
        TV.delegate = self
        TV.dataSource = self
        
        message = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height:40))
        message.text = "No Matching Events"
        message.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:20)
        self.TV.addSubview(message)
        message.isHidden = true
        
        setupSpinner()
    }
    
    // setup spinner to show progress
    func setupSpinner(){
        self.spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        self.spinner.color = UIColor.darkGray
        self.spinner.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2 - 60)
        self.TV.addSubview(spinner)
        self.spinner.hidesWhenStopped = true
    }
    
    // load events based on filters
    func loadEvents(){
        self.eventsList.removeAll()
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        ref.child("events").child("eventsList").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get event details
            self.eventsList.removeAll()
            self.spinner.startAnimating()
            self.noEventFlag = false
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
                        var eventAttendeeArray: [String] = [String]()
                        if let eventAttendees = value["eventAttendees"] as? NSArray{
                            for i in 0..<eventAttendees.count {
                                eventAttendeeArray.append(eventAttendees[i] as! String)
                            }
                        }
                        var likedByArray: [String] = [String]()
                        if let likedBy = value["likedBy"] as? NSArray{
                            for i in 0..<likedBy.count {
                                likedByArray.append(likedBy[i] as! String)
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
                        
                        let currentDate = Date()
                        
                        // filter
                        if currentEvent.eventStatus != "draft"{
                            if self.stringToDate(dateString: currentEvent.eventDate) < currentDate{
                                currentEvent.eventStatus = "expired"
                            }
                            if (self.searchCategories.count != 0){  // category filtter
                                if (self.searchBar.text != ""){
                                    if (currentEvent.eventName.lowercased().contains(self.searchBar.text!.lowercased())){
                                        for cat in currentEvent.eventCategory{
                                            if self.searchCategories.contains(cat.lowercased()){
                                                var existFlag = false
                                                for event in self.eventsList{
                                                    if event.eventID == currentEvent.eventID {
                                                        existFlag = true
                                                    }
                                                }
                                                if (!existFlag){
                                                    self.eventsList.append(currentEvent)
                                                }
                                            }
                                        }
                                    }
                                }
                                else{
                                    for cat in currentEvent.eventCategory{  // category filter
                                        if self.searchCategories.contains(cat.lowercased()){
                                            var existFlag = false
                                            for event in self.eventsList{
                                                if event.eventID == currentEvent.eventID {
                                                    existFlag = true
                                                }
                                            }
                                            if (!existFlag){
                                                self.eventsList.append(currentEvent)
                                            }
                                        }
                                    }
                                }

                            }else{
                                if self.searchBar.text! != ""{  // search bar content filter
                                    if currentEvent.eventName.lowercased().contains(self.searchBar.text!.lowercased()){
                                        var existFlag = false
                                        for event in self.eventsList{
                                            if event.eventID == currentEvent.eventID {
                                                existFlag = true
                                            }
                                        }
                                        if (!existFlag){
                                            self.eventsList.append(currentEvent)
                                        }
                                    }
                                }
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
                                    self.TV.reloadData()
                                    self.spinner.stopAnimating()
                                    
                                }
                            }
                        })
                    }
                }
            }
            else{
                // no item exception
                print("no item")
                self.TV.reloadData()
                self.spinner.stopAnimating()
                let message: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height:40))
                message.text = "No Matching Events"
                message.textColor = UIColor.gray
                message.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:20)
                self.TV.addSubview(message)
            }
            if self.eventsList.count == 0{
                self.noEventFlag = true
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.TV.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // navigate to root screen
    @IBAction func backToHomePressed(_ sender: Any) {
        performSegue(withIdentifier: "SearchToHomeSegue", sender: sender)
    }
    
    // hex value to UIcolor
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in TV: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ TV: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(noEventFlag){
            message.isHidden = false
        }
        return eventsList.count
    }
    
    // configure each row and display event on the row
    func tableView(_ TV: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TV.dequeueReusableCell(withIdentifier: "RegEventCell", for: indexPath) as! RegEventCell
        if eventsList.count != 0{
            self.message.isHidden = true
            sortEvents()

            cell.eventTitle.text = eventsList[indexPath.row].eventName 
            cell.eventTag.text = eventsList[indexPath.row].eventTags.joined(separator: " ")
            let status: String  = eventsList[indexPath.row].eventStatus
            if status == "expired"{
                cell.eventStatus.text = "Expired"
                cell.eventStatus.textColor = uicolorFromHex(rgbValue: 0xFF3B30)
                if let userID = FIRAuth.auth()?.currentUser?.uid{
                    if eventsList[indexPath.row].getAttendees().contains(userID) {
                        cell.eventStatus.text = "Joined"
                        cell.eventStatus.textColor = uicolorFromHex(rgbValue: 0xFF3B30)
                    }
                }
            }else{
                cell.eventStatus.text = ""
                if let userID = FIRAuth.auth()?.currentUser?.uid{
                    if eventsList[indexPath.row].getAttendees().contains(userID) {
                        cell.eventStatus.text = "Joined"
                        cell.eventStatus.textColor = uicolorFromHex(rgbValue: 0xFF9500)
                    }
                }
            }
            cell.eventViewNumber.text = "\(eventsList[indexPath.row].eventViewNumber)"
            cell.eventDate.text = eventsList[indexPath.row].eventDate
            cell.eventImage.image = eventsList[indexPath.row].eventPoster
        }
        return cell
    }
    
    // sort row by date
    func sortEvents(){
        eventsList.sort(by: sorterForDateASC)
        //eventsList.sort(by: sorterForPopularDES)
    }
    func sorterForDateASC(this:Event, that:Event) -> Bool {
        return stringToDate(dateString: this.eventDate) < stringToDate(dateString: that.eventDate)
    }
    func sorterForPopularDES(this:Event, that:Event) -> Bool {
        return this.eventViewNumber > that.eventViewNumber
    }
    
    // convert date string to date
    func stringToDate(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMMM dd yyyy', 'h:mm a"
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    
    // row height
    func tableView(_ TV: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 250.0
    }
    func tableView(_ TV: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.TV.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = self.TV.indexPath(for: cell)!.row
            if segue.identifier == "ViewFromSearchSegue" {
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

// KS token view functions
extension SearchVC: KSTokenViewDelegate {
    func tokenView(_ token: KSTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        if (string.characters.isEmpty){
            completion!(categories as Array<AnyObject>)
            return
        }
        var data: Array<String> = []
        for value: String in categories {
            if value.lowercased().range(of: string.lowercased()) != nil {
                data.append(value)  // put category from database into token view
            }
        }
        completion!(data as Array<AnyObject>)
    }
    
    func tokenViewDidEndEditing(_ tokenView: KSTokenView) {
        self.searchCategories.removeAll()

        if let array: Array<KSToken> = tokenView.tokens(){
            for token in array{
                searchCategories.append(token.title)    // save all selected category into local list
                //print("\(token.title) ")
            }
        }
    }
    
    func tokenView(_ token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
}
