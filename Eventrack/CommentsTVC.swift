//
//  CommentsTVC.swift
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

class CommentsTVC: UITableViewController {
    
    
    // variables
    var currentEvent: Event?
    var currentEventID: String?
    var commentList = [Comment]()
    var spinner: UIActivityIndicatorView!
    var message: UILabel!
    var noCommentFlag = false

    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBAction func backBtnPressed(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        //self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if FIRAuth.auth()?.currentUser == nil{
            addBtn.isEnabled = false;
        }else{
            addBtn.isEnabled = true;
        }
        
        currentEventID = currentEvent?.eventID ?? ""
        
        message = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height:40))
        message.text = "No Comment"
        message.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:20)
        self.view.addSubview(message)
        message.isHidden = true
        
        loadComments()
        setupSpinner()
    }
    
    // setup spinners
    func setupSpinner(){
        self.spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height:60))
        self.spinner.color = UIColor.darkGray
        self.spinner.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2 - 60)
        self.view.addSubview(spinner)
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
    }
    
    // load comments from database and create new comment object
    func loadComments(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        ref.child("events").child("eventComments").observe(.value) { (snapshot: FIRDataSnapshot) in
            // Get event details
            self.commentList.removeAll()
            self.spinner.startAnimating()
            self.noCommentFlag = false
            if let commentDatabase = snapshot.value as? Dictionary<String, AnyObject>{
                for (key, value) in commentDatabase {
                    if key == self.currentEventID{
                        if let commentArrayDB: [Dictionary<String, String>] = value as? [Dictionary<String, String>] {
                            print("value: \(commentArrayDB)")
                            
                            for val in commentArrayDB{
                                //let eventID = key
                                let author = val["author"] ?? ""
                                let date = val["date"] ?? ""
                                let content = val["content"] ?? ""
                                
                                let currentComment = Comment(author: author, date: date, content: content) // create new comment object
                                self.commentList.append(currentComment) // append new object to local array
                            }

                            self.tableView.reloadData()
                            self.spinner.stopAnimating()
                        }
                    }else{
                        self.message.isHidden = false
                        self.spinner.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
            else{
                // handle no comments exception
                self.tableView.reloadData()
                self.spinner.stopAnimating()
                let message: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height:40))
                message.text = "No Comment"
                message.textColor = UIColor.gray
                message.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:20)
                self.view.addSubview(message)
            }
            if self.commentList.count == 0{
                self.noCommentFlag = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // convert hex value to UICOlor
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
        if(noCommentFlag){
            message.isHidden = false
        }
        return commentList.count
    }

    // configure each row in the table and display comments
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        if commentList.count != 0{
            self.message.isHidden = true
            cell.nameLabel.text = commentList[indexPath.row].author
            cell.dateLabel.text = commentList[indexPath.row].date
            cell.contentLabel.text = commentList[indexPath.row].content
        }
        return cell
    }
    
    // comment row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddFromCommentsSegue" {
            // add one view to this event
            let currentEvent = self.currentEvent
            
            let vc = segue.destination as! CreateCommentTVC
            vc.currentEvent = currentEvent!
        }
        if segue.identifier == "ViewFromCommentsSegue" {
            // add one view to this event
            let currentEvent = self.currentEvent
            
            let vc = segue.destination as! ViewEventTVC
            vc.fromVC = "comments"
            vc.currentEvent = currentEvent!
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
