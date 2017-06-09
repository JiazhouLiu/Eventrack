//
//  ViewEventTVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 8/6/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewEventTVC: UITableViewController {
    
    // variables
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventCategory: UILabel!
    @IBOutlet weak var eventStatus: UILabel!
    @IBOutlet weak var eventDetail: UITextView!
    @IBOutlet weak var eventTags: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    var currentEvent: Event?
    var fromVC: String?
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var removeButton: CustomizableButton!
    @IBOutlet weak var lastCell: UITableViewCell!
    
    // removed button pressed
    @IBAction func removeBtnPressed(_ sender: Any) {
        let eventName = self.currentEvent?.eventName ?? ""
        // let user confirm
        let alertController = UIAlertController(title: "Remove Event", message: "Are you sure to remove event \(eventName)?", preferredStyle: UIAlertControllerStyle.alert)
        
        let removeAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            DataService.instance.removeEvent(eventID: (self.currentEvent?.eventID)!)
            let alert = UIAlertController(title: "Event Removed", message: "You have successfully removed event \(eventName)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                // navigate back depends on from screen
                if self.fromVC != "comments"{
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.tabBar.isHidden = false
                }else{
                    if let storyboard = self.storyboard {
                        let vc = storyboard.instantiateInitialViewController()
                        self.present(vc!, animated: true, completion: nil)
                    }
                }
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // back to root screen or previous screen
    @IBAction func backButtonPressed(_ sender: Any) {
        if self.fromVC != "comments"{
            navigationController?.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
        }else{
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateInitialViewController()
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    // click on the like button and communicate with databse
    @IBAction func likeButtonPressed(_ sender: Any) {
        if let currentUser = FIRAuth.auth()?.currentUser{
            var currentLikedBy = currentEvent?.getEventLikedBy()
            let userID = currentUser.uid
            if (currentLikedBy?.contains(userID))!{
                DataService.instance.dislikeEvent(eventID: (currentEvent?.eventID)!, userID: userID)
                if currentLikedBy != nil{
                    if let index = currentLikedBy?.index(of: userID) {
                        currentLikedBy?.remove(at: index)
                        currentEvent?.setEventLikedBy(likedBy: currentLikedBy!)
                        likeLabel.text = "Like"
                        likeButton.setImage(UIImage(named: "likeEvent"), for: .normal)
                    }
                }else{
                    print("Error, no item in likeBy list, and cannot remove")
                }
            }else{
                DataService.instance.likeEvent(eventID: (currentEvent?.eventID)!, userID: userID)
                if currentLikedBy != nil{
                    currentLikedBy?.append(userID)
                    currentEvent?.setEventLikedBy(likedBy: currentLikedBy!)
                    likeLabel.text = "Dislike"
                    likeButton.setImage(UIImage(named: "dislikeEvent"), for: .normal)
                }else{
                    print("error when like event, nil likedByList")
                }
            }
        }else{
            let alert = UIAlertController(title: "Login Required", message: "You must login first to use event features", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // join event and store in the database
    @IBAction func joinButtonPressed(_ sender: Any) {
        if let currentUser = FIRAuth.auth()?.currentUser{
            var currentAttendees = currentEvent?.getAttendees()
            let userID = currentUser.uid
            if (currentAttendees?.contains(userID))!{
                DataService.instance.quitEvent(eventID: (currentEvent?.eventID)!, userID: userID)
                if currentAttendees != nil{
                    if let index = currentAttendees?.index(of: userID) {
                        currentAttendees?.remove(at: index)
                        currentEvent?.setAttendees(attendees: currentAttendees!)
                        joinLabel.text = "Join"
                        joinButton.setImage(UIImage(named: "joinEvent"), for: .normal)
                        eventStatus.text = ""
                    }
                }else{
                    print("Error, no item in currentAttendees, and cannot remove")
                }
            }else{
                DataService.instance.joinEvent(eventID: (currentEvent?.eventID)!, userID: userID)
                if currentAttendees != nil{
                    currentAttendees?.append(userID)
                    currentEvent?.setAttendees(attendees: currentAttendees!)
                    joinLabel.text = "Quit"
                    joinButton.setImage(UIImage(named: "quitEvent"), for: .normal)
                    eventStatus.text = "Joined"
                    eventStatus.font = eventStatus.font.withSize(18)
                    eventStatus.font = UIFont.boldSystemFont(ofSize: 18)
                    eventStatus.textColor = uicolorFromHex(rgbValue: 0xFF9500)
                }else{
                    print("error when join event, nil attendeeList")
                }
            }
        }else{
            let alert = UIAlertController(title: "Login Required", message: "You must login first to use event features", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // handle view based on current status
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: uicolorFromHex(rgbValue: 0x2B8A36)], for:.selected)
        UINavigationBar.appearance().tintColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = true
        if currentEvent != nil{
            eventStatus.text = ""
            if FIRAuth.auth()?.currentUser != nil{
                if (currentEvent?.getAttendees().contains((FIRAuth.auth()?.currentUser?.uid)!))!{
                    joinLabel.text = "Quit"
                    joinButton.setImage(UIImage(named: "quitEvent"), for: .normal)
                    eventStatus.text = "Joined"
                    eventStatus.font = eventStatus.font.withSize(18)
                    eventStatus.font = UIFont.boldSystemFont(ofSize: 18)
                    eventStatus.textColor = uicolorFromHex(rgbValue: 0xFF9500)
                }else{
                    joinLabel.text = "Join"
                    joinButton.setImage(UIImage(named: "joinEvent"), for: .normal)
                }
                if (currentEvent?.getEventLikedBy().contains((FIRAuth.auth()?.currentUser?.uid)!))!{
                    likeLabel.text = "Dislike"
                    likeButton.setImage(UIImage(named: "dislikeEvent"), for: .normal)
                }else{
                    likeLabel.text = "Like"
                    likeButton.setImage(UIImage(named: "likeEvent"), for: .normal)
                }
            }
            
            eventImg.image = currentEvent?.eventPoster
            eventTitle.text = currentEvent?.eventName
            eventDate.text = currentEvent?.eventDate
            if currentEvent?.eventLocation != ""{
                eventLocation.text = currentEvent?.eventLocation
            }else{
                eventLocation.text = "No Location Information"
                eventLocation.textColor = UIColor.lightGray
            }
            if currentEvent?.eventTags[0] != ""{
                eventTags.text = currentEvent?.eventTags.joined(separator: " ")
            }else{
                eventTags.text = "No Tags Information"
                eventTags.textColor = UIColor.lightGray
            }
            
            if currentEvent?.eventCategory[0] != ""{
                eventCategory.text = currentEvent?.eventCategory.joined(separator: " ")
            }else{
                eventCategory.text = "No Category Information"
                eventCategory.textColor = UIColor.lightGray
            }
            
            if currentEvent?.eventDetail != ""{
                eventDetail.text = currentEvent?.eventDetail
            }else{
                eventDetail.text = "No Event Detail Information"
                eventDetail.textColor = UIColor.lightGray
            }
            
        }
        
        if self.currentEvent?.eventCreator != FIRAuth.auth()?.currentUser?.uid{
            lastCell.isHidden = true
        }else{
            lastCell.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // convert hex value to UIColor
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    // setup height for rows
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 7{
            if self.currentEvent?.eventCreator != FIRAuth.auth()?.currentUser?.uid{
                return 0
            }else{
                return 44
            }
        }else if row == 0{
            return 414
        }else if row == 5{
            return 398
        }else if row == 6{
            return 88
        }
        return 44
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentsFromViewSegue" {
            // add one view to this event
            let currentEvent = self.currentEvent
            
            let vc = segue.destination as! CommentsTVC
            vc.currentEvent = currentEvent!
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
