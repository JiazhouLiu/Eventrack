//
//  CreateCommentTVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 9/6/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CreateCommentTVC: UITableViewController {

    // variables
    @IBOutlet weak var commentContent: CustomizableTextView!
    var currentEvent: Event?
    
    // submit a comment and save it into database
    @IBAction func submitBtnPressed(_ sender: Any) {
        let content: String = commentContent.text ?? ""
        let userID: String = FIRAuth.auth()?.currentUser?.uid ?? ""
        let eventID: String = currentEvent?.eventID ?? ""
        
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        ref.child("users").child(userID).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            
            let date = Date()
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "E, MMMM dd yyyy', 'h:mm a"
            
            let dateString = dateFormatter.string(from: date)
            DataService.instance.saveComment(eventID: eventID, userName: username, date: dateString, content: content)  // save comment into databse
            
            let alert = UIAlertController(title: "Comment Added", message: "You have successfully added a comment", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                self.performSegue(withIdentifier: "CommentsFromAddSegue", sender: nil)  // navigate to comment screen
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentsFromAddSegue" {
            // add one view to this event
            let currentEvent = self.currentEvent
            
            let vc = segue.destination as! CommentsTVC
            vc.currentEvent = currentEvent!
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
