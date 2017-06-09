//
//  Comment.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 9/6/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import Foundation


// comment class
class Comment{
    
    // comment class attribute
    var author: String
    var date: String
    var content: String
    
    // initiators
    init(author: String, date: String, content: String){
        self.author = author
        self.date = date
        self.content = content
    }
    
    // getters
    func getAuthor() -> String{ return self.author}
    func getDate() -> String{ return self.date}
    func getContent() -> String{   return self.content}
    
    // setters
    func setAuthor(author: String){
        self.author = author
    }
    func setDate(date: String){
        self.date = date
    }
    func setContent(content: String){
        self.content = content
    }
    
    
}
