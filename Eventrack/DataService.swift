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
    
    func saveUser(uid: String, displayName: String){
        let profile: Dictionary<String, AnyObject> = ["Display name": displayName as AnyObject, "firstname": "" as AnyObject, "lastname": "" as AnyObject]
        mainRef.child(FIR_CHILD_USERS).child(uid).child("profile").setValue(profile)
    }
    func saveEventCategory(cat: String){
        let profile: Dictionary<String, String> = ["Value": cat]
        mainRef.child("events").child("eventCategoryList").child(cat).setValue(profile)
    }
    
}
