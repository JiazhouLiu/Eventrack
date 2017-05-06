//
//  DataService.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 6/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

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
    
    func saveUser(uid: String, displayName: String){
        let profile: Dictionary<String, AnyObject> = ["Display name": displayName as AnyObject, "firstname": "" as AnyObject, "lastname": "" as AnyObject]
        mainRef.child("users").child(uid).child("profile").setValue(profile)
    }
}
