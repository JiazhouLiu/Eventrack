//
//  DataService.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 6/5/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

// User constant
let FIR_CHILD_USERS = "users"


import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DataService{
    
    // private variable for internal use
    private static let _instance = DataService()
    private var _eventAutoId = ""
    
    // class initializor
    static var instance: DataService{
        return _instance
    }
    
    var eventAutoId: String{
        return _eventAutoId
    }
    
    // References shortcut
    var mainRef: FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    var usersRef: FIRDatabaseReference{
        return mainRef.child(FIR_CHILD_USERS)
    }
    var categoryRef: FIRDatabaseReference{
        return mainRef.child("events").child("eventCategoryList")
    }
    var eventsRef: FIRDatabaseReference{
        return mainRef.child("events").child("eventsList")
        //return mainRef.child("events").child("eventsList").childByAutoId()
    }
    var storageRef: FIRStorageReference{
        return FIRStorage.storage().reference()
    }
    
    // save Event method, save all parameters to database
    func saveEvent(eventCategory: [String], eventDate: String, eventDetail: String, eventLocation: String, eventName: String, eventPoster: NSData!, eventStaus: String, eventTags: [String], eventCreator: String){
        
        let event: Dictionary<String, AnyObject> = ["eventCategory": eventCategory as AnyObject,  "eventDate": eventDate as AnyObject, "eventDetail": eventDetail as AnyObject, "eventLocation": eventLocation as AnyObject, "eventName": eventName as AnyObject, "eventStatus": eventStaus as AnyObject, "eventTags": eventTags as AnyObject, "eventCreator": eventCreator as AnyObject, "eventViewNumber": 0 as AnyObject]
        let currentEventAutoID = self.eventsRef.childByAutoId()
        currentEventAutoID.setValue(event)
        let currentEventAutoIDKey = currentEventAutoID.key
        self._eventAutoId = currentEventAutoIDKey
        
        // create path for user image
        var imageURL: String = ""
        let imagePath = "eventImage\(currentEventAutoIDKey)/eventPoster.jpg"
        
        // create image reference
        let imageRef = storageRef.child(imagePath)
        
        // create metadata for the image
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image.jpeg"
        
        // save the user image in the Firebase storage
        imageRef.put(eventPoster as Data, metadata: metadata) { (metaData, error) in
            if error == nil{
                imageURL = String(describing: metaData!.downloadURL()!)
                self.eventsRef.child(currentEventAutoIDKey).child("eventPoster").setValue(imageURL)
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    // update event by given parameters and event id
    func updateEvent(eventId: String, eventCategory: [String], eventDate: String, eventDetail: String, eventLocation: String, eventName: String, eventPoster: NSData!, eventStaus: String, eventTags: [String], eventCreator: String){
        
        let event: Dictionary<String, AnyObject> = ["eventCategory": eventCategory as AnyObject,  "eventDate": eventDate as AnyObject, "eventDetail": eventDetail as AnyObject, "eventLocation": eventLocation as AnyObject, "eventName": eventName as AnyObject, "eventStatus": eventStaus as AnyObject, "eventTags": eventTags as AnyObject, "eventCreator": eventCreator as AnyObject]
        let currentEventAutoID = self.eventsRef.child(eventId)
        currentEventAutoID.setValue(event)
        let currentEventAutoIDKey = currentEventAutoID.key
        self._eventAutoId = currentEventAutoIDKey
        
        // create path for user image
        var imageURL: String = ""
        let imagePath = "eventImage\(currentEventAutoIDKey)/eventPoster.jpg"
        
        // create image reference
        let imageRef = storageRef.child(imagePath)
        
        
        // create metadata for the image
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image.jpeg"
        
        // save the user image in the Firebase storage
        imageRef.put(eventPoster as Data, metadata: metadata) { (metaData, error) in
            if error == nil{
                imageURL = String(describing: metaData!.downloadURL()!)
                self.eventsRef.child(currentEventAutoIDKey).child("eventPoster").setValue(imageURL)
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    // increase event view number by 1, sync database
    func increEventViewNumberByOne(eventID: String){
        self.eventsRef.child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var currentViewNumber = value?["eventViewNumber"] as? Int ?? 0
            currentViewNumber = currentViewNumber + 1
            self.eventsRef.child(eventID).child("eventViewNumber").setValue(currentViewNumber)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // join event by specific user
    func joinEvent(eventID: String, userID: String){
        self.eventsRef.child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var currentAttendees = value?["eventAttendees"] as? [String] ?? []
            currentAttendees.append(userID)
            self.eventsRef.child(eventID).child("eventAttendees").setValue(currentAttendees)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    // quit event by specific user
    func quitEvent(eventID: String, userID: String){
        self.eventsRef.child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var currentAttendees = value?["eventAttendees"] as? [String] ?? []
            if let index = currentAttendees.index(of: userID) {
                currentAttendees.remove(at: index)
            }
            self.eventsRef.child(eventID).child("eventAttendees").setValue(currentAttendees)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // like event by specific user
    func likeEvent(eventID: String, userID: String){
        self.eventsRef.child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var currentLikedBy = value?["likedBy"] as? [String] ?? []
            currentLikedBy.append(userID)
            self.eventsRef.child(eventID).child("likedBy").setValue(currentLikedBy)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    // dislike event by specific user
    func dislikeEvent(eventID: String, userID: String){
        self.eventsRef.child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var currentLikedBy = value?["likedBy"] as? [String] ?? []
            if let index = currentLikedBy.index(of: userID) {
                currentLikedBy.remove(at: index)
            }
            self.eventsRef.child(eventID).child("likedBy").setValue(currentLikedBy)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // remove event from database
    func removeEvent(eventID: String){
        self.eventsRef.child(eventID).removeValue()
    }

    // save comment into database
    func saveComment(eventID: String, userName: String, date: String, content: String){
        mainRef.child("events").child("eventComments").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var currentCommentArray = value?[eventID] as? [Dictionary<String, String>] ?? []
            let comment: Dictionary<String, String> = ["author": userName, "date": date, "content": content]
            currentCommentArray.append(comment)
            self.mainRef.child("events").child("eventComments").child(eventID).setValue(currentCommentArray)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // save user into database
    func saveUser(user: FIRUser!, username: String, password: String, country: String){
        let profile: Dictionary<String, AnyObject> = ["email": user.email! as AnyObject, "username": username as AnyObject, "country": country as AnyObject, "uid": user.uid as AnyObject, "photoURL": String(describing: user.photoURL!) as AnyObject]
        mainRef.child(FIR_CHILD_USERS).child(user.uid).child("profile").setValue(profile)
    }
    
    // pretrim user info and pass to save user method
    func setUserInfo(user: FIRUser!, username: String, password: String, country: String, data: NSData!){
        
        // create path for user image
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        
        // create image reference
        let imageRef = storageRef.child(imagePath)
        
        // create metadata for the image
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image.jpeg"
        
        // save the user image in the Firebase storage
        imageRef.put(data as Data, metadata: metadata) { (metaData, error) in
            if error == nil{
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                changeRequest.photoURL = metaData!.downloadURL()
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil{
                        self.saveUser(user: user, username: username, password: password, country: country)
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    // save event category into database
    func saveEventCategory(cat: String){
        let profile: Dictionary<String, String> = ["Value": cat]
        mainRef.child("events").child("eventCategoryList").child(cat).setValue(profile)
    }
    
}

// extension to trim white spaces for string
extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
