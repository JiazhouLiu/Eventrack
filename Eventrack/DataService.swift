//
//  DataService.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 6/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

let FIR_CHILD_USERS = "users"

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DataService{
    private static let _instance = DataService()
    
    static var instance: DataService{
        return _instance
    }
    
    var mainRef: FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    var usersRef: FIRDatabaseReference{
        return mainRef.child(FIR_CHILD_USERS)
    }
    var categoryRef: FIRDatabaseReference{
        return mainRef.child("events").child("eventCategoryList")
    }
    
    var storageRef: FIRStorageReference{
        return FIRStorage.storage().reference()
    }

    func saveUser(user: FIRUser!, username: String, password: String, country: String){
        let profile: Dictionary<String, AnyObject> = ["email": user.email! as AnyObject, "username": username as AnyObject, "country": country as AnyObject, "uid": user.uid as AnyObject, "photoURL": String(describing: user.photoURL!) as AnyObject]
        mainRef.child(FIR_CHILD_USERS).child(user.uid).child("profile").setValue(profile)
    }
    
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
    
    
    func saveEventCategory(cat: String){
        let profile: Dictionary<String, String> = ["Value": cat]
        mainRef.child("events").child("eventCategoryList").child(cat).setValue(profile)
    }
    
}
