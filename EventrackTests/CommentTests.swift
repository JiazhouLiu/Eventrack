//
//  CommentTests.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 9/6/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import XCTest
//import FirebaseAuth
//import Firebase
//import FirebaseDatabase

//@testable import Eventrack

class CommentTests: XCTestCase {
    
    //var currentComment: Comment!
    //var eventID: String!
    
    override func setUp() {
        super.setUp()
       // eventID = "12345"
        //currentComment = Comment(author: "Joe", date: "Sun, June 11 2017, 10:56 am", content: "test comments")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        //eventID = ""
        //currentComment = nil
    }
    
    func testExample() {
        /*
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        ref.child("events").child("eventComments").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            var commentNo = 0
            let value = snapshot.value as? NSDictionary
            for (key, value) in value {
               commentNo = commentNo + 1
            }
            DataService.instance.saveComment()
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
*/
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
