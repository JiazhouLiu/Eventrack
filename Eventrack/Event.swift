//
//  Event.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 31/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import Foundation

class Event {
    
    // event class attribute
    var eventCategory: [String]
    var eventDate: String
    var eventDetail: String
    var eventLocation: String
    var eventName: String
    var eventPoster: UIImage
    var eventStatus: String
    var eventTags: [String]
    var eventCreator: String
    var eventAttendees: [String]?
    var eventCommentsNumber: String?
    var eventID: String
    var eventViewNumber: Int
    var eventLikedBy: [String]?
    
    // initiators
    init(category: [String], date: String, detail: String, location: String, name: String, poster: UIImage, status: String, tags: [String], creator: String, id: String){
        self.eventCategory = category
        self.eventDate = date
        self.eventDetail = detail
        self.eventLocation = location
        self.eventName = name
        self.eventPoster = poster
        self.eventStatus = status
        self.eventTags = tags
        self.eventCreator = creator
        self.eventID = id
        self.eventViewNumber = 0
    }

    // getters
    func getCategory() -> [String]{ return self.eventCategory}
    func getTags() -> [String]{ return self.eventTags}
    func getDate() -> String{   return self.eventDate}
    func getDetail() -> String{   return self.eventDetail}
    func getLocation() -> String{ return self.eventLocation}
    func getName() -> String{ return self.eventName}
    func getPoster() -> UIImage{   return self.eventPoster}
    func getStatus() -> String{ return self.eventStatus}
    func getCreator() -> String{  return self.eventCreator}
    func getID() -> String{ return self.eventID}
    func getEventViewNumber() -> Int{   return self.eventViewNumber}
    func getAttendees() -> [String]{
        if let attendees = self.eventAttendees{
            return attendees
        }
        return []
    }
    func getCommentsNumber() -> String{
        if let commentNumber = self.eventCommentsNumber{
            return commentNumber
        }
        return ""
    }
    func getEventLikedBy() -> [String]{
        if let likedBy = self.eventLikedBy{
            return likedBy
        }
        return []
    }
    
    // setters
    func setCategory(category: [String]){ self.eventCategory = category}
    func setTags(tags: [String]){ self.eventTags = tags}
    func setDate(date: String){   self.eventDate = date}
    func setDetail(detail: String){   self.eventDetail = detail}
    func setLocation(location: String){ self.eventLocation = location}
    func setName(name: String){ self.eventName = name}
    func setPoster(poster: UIImage){   self.eventPoster = poster}
    func setStatus(status: String){ self.eventStatus = status}
    func setCreator(creator: String){  self.eventCreator = creator}
    func setID(id: String){ self.eventID = id}
    func setAttendees(attendees: [String]){ self.eventAttendees = attendees}
    func setCommentsNumber(commentNumber: String){   self.eventCommentsNumber = commentNumber}
    func setEventViewNumber(viewNumber: Int){   self.eventViewNumber = viewNumber}
    func setEventLikedBy(likedBy: [String]){    self.eventLikedBy = likedBy}
    
}
