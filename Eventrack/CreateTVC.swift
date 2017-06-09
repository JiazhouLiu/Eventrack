//
//  CreateTVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 22/5/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CreateTVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate{

    // variables
    @IBOutlet weak var eventTitleTF: UITextField!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventTagsTF: CustomizableTextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var eventDetailsTF: UITextView!
    @IBOutlet weak var saveDraftBtn: CustomizableButton!
    @IBOutlet weak var publishBtn: CustomizableButton!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    @IBOutlet weak var removeBtn: UIBarButtonItem!
    var event: Event?
    var currentEvent: Event?
    
    var dateString: String?
    
    // remove event button pressed
    @IBAction func removeBtnPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Remove Event Draft", message: "Are you sure to remove the draft?", preferredStyle: UIAlertControllerStyle.alert)
        
        let removeAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            DataService.instance.removeEvent(eventID: (self.event?.eventID)!)
            let alert = UIAlertController(title: "Event Draft Removed", message: "You have successfully removed the draft", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                self.navigationController?.popViewController(animated: true)
                self.tabBarController?.tabBar.isHidden = false
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // back button based on from screen
    @IBAction func backButtonPressed(_ sender: Any) {
        if currentEvent == nil{
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateInitialViewController()
                self.present(vc!, animated: true, completion: nil)
            }
        }else{
            navigationController?.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
        }
    }
 
        // Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myColor : UIColor = UIColor.lightGray
        eventDetailsTF.layer.borderColor = myColor.cgColor
        saveDraftBtn.layer.borderColor = uicolorFromHex(rgbValue: 0x2B8A36).cgColor
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "E, MMMM dd yyyy', 'h:mm a"
        
        self.dateString = dateFormatter.string(from: date)
        eventDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        if currentEvent != nil{
            assignValue()
            self.event = self.currentEvent
            self.saveDraftBtn.setTitle("Update", for: .normal)
        }
        if self.event != nil{
            self.removeBtn.isEnabled = true
        }else{
            self.removeBtn.isEnabled = false
        }
        
    }
    
    // if navigate from draft, then assign original value
    func assignValue(){
        eventTitleTF.text = currentEvent?.eventName
        eventDetailsTF.text = currentEvent?.eventDetail
        eventTagsTF.text = currentEvent?.eventTags.joined(separator: ";")
        eventImage.image = currentEvent?.eventPoster
        eventDatePicker.date = stringToDate(dateString: (currentEvent?.eventDate)!)
        self.dateString = currentEvent?.eventDate
        eventLocation.text = currentEvent?.eventLocation
        categoryTF.text = currentEvent?.eventCategory.joined(separator: ";")
        
    }
    
    // convert date string to date
    func stringToDate(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMMM dd yyyy', 'h:mm a"
        let date = dateFormatter.date(from: dateString)
        return date!
    }
    
    // detect date picker changed
    func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "E, MMMM dd yyyy', 'h:mm a"
        
        
        self.dateString = dateFormatter.string(from: sender.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // save draft button pressed and check saved or not
    @IBAction func saveDraftBtnPressed(_ sender: Any) {
        let imgData = UIImageJPEGRepresentation(self.eventImage.image!, 0.8)
        let UIImgData = UIImage(data: imgData!)
        
        if let title = eventTitleTF.text, let date = self.dateString, let location = eventLocation.text, let tagString = eventTagsTF.text, let categoryString = categoryTF.text, let detail = eventDetailsTF.text ,(title.characters.count > 0 && date.characters.count > 0){
            //call the dataService
            let categoryRaw = categoryString.components(separatedBy: ";")
            var category = [String]()
            for singleCat in categoryRaw{
                let trimmedCat = singleCat.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                DataService.instance.saveEventCategory(cat: trimmedCat)
                category.append(trimmedCat)
            }
            let tagsRaw = tagString.components(separatedBy: ";")
            var tags = [String]()
            for singleTag in tagsRaw{
                tags.append(singleTag.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
            
            // check saved or not
            if self.event == nil{
                let eventCreator = (FIRAuth.auth()?.currentUser?.uid)!
                let dataServiceInstance = DataService.instance
                dataServiceInstance.saveEvent(eventCategory: category, eventDate: date, eventDetail: detail, eventLocation: location, eventName: title, eventPoster: imgData! as NSData, eventStaus: "draft", eventTags: tags, eventCreator: eventCreator)
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: UIImgData!, status: "draft", tags: tags, creator: eventCreator, id: dataServiceInstance.eventAutoId)
                let alertController = UIAlertController(title: "Success", message: "You have successfully saved a draft of an event!", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    /*if let storyboard = self.storyboard {
                        let vc = storyboard.instantiateInitialViewController()
                        self.present(vc!, animated: true, completion: nil)
                    }*/
                    self.saveDraftBtn.setTitle("Update", for: .normal)
                    self.removeBtn.isEnabled = true
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let eventCreator = (FIRAuth.auth()?.currentUser?.uid)!
                let dataServiceInstance = DataService.instance
                let currentEventId = self.event?.getID()
                dataServiceInstance.updateEvent(eventId: currentEventId!, eventCategory: category, eventDate: date, eventDetail: detail, eventLocation: location, eventName: title, eventPoster: imgData! as NSData, eventStaus: "draft", eventTags: tags, eventCreator: eventCreator)
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: UIImgData!, status: "draft", tags: tags, creator: eventCreator, id: currentEventId!)
                print(self.event!.getID())
                let alertController = UIAlertController(title: "Success", message: "You have successfully updated a draft of an event!", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    /*if let storyboard = self.storyboard {
                     let vc = storyboard.instantiateInitialViewController()
                     self.present(vc!, animated: true, completion: nil)
                     }*/
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }else {
            let alert = UIAlertController(title: "Event Title Required", message: "You must enter a title for the event", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // publish button pressed and check if pressed save draft or not
    @IBAction func publishBtnPressed(_ sender: Any) {
        let imgData = UIImageJPEGRepresentation(self.eventImage.image!, 0.8)
        let UIImgData = UIImage(data: imgData!)
        
        if let title = eventTitleTF.text, let date = self.dateString, let location = eventLocation.text, let tagString = eventTagsTF.text, let categoryString = categoryTF.text, let detail = eventDetailsTF.text ,(title.characters.count > 0 && date.characters.count > 0){
            //call the dataService
            let categoryRaw = categoryString.components(separatedBy: ";")
            var category = [String]()
            for singleCat in categoryRaw{
                let trimmedCat = singleCat.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if trimmedCat != ""{
                    DataService.instance.saveEventCategory(cat: trimmedCat)
                }
                category.append(trimmedCat)
            }
            let tagsRaw = tagString.components(separatedBy: ";")
            var tags = [String]()
            for singleTag in tagsRaw{
                tags.append(singleTag.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
            
            // check saved or not
            if self.event == nil{
                
                let eventCreator = (FIRAuth.auth()?.currentUser?.uid)!
                let dataServiceInstance = DataService.instance
                dataServiceInstance.saveEvent(eventCategory: category, eventDate: date, eventDetail: detail, eventLocation: location, eventName: title, eventPoster: imgData! as NSData, eventStaus: "published", eventTags: tags, eventCreator: eventCreator)
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: UIImgData!, status: "published", tags: tags, creator: eventCreator, id: dataServiceInstance.eventAutoId)
                let alertController = UIAlertController(title: "Success", message: "You have successfully published an event!", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    if let storyboard = self.storyboard {
                        let vc = storyboard.instantiateInitialViewController()
                        self.present(vc!, animated: true, completion: nil)
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                print("published an update version")
                let eventCreator = (FIRAuth.auth()?.currentUser?.uid)!
                let dataServiceInstance = DataService.instance
                let currentEventId = self.event?.getID()
                dataServiceInstance.updateEvent(eventId: currentEventId!, eventCategory: category, eventDate: date, eventDetail: detail, eventLocation: location, eventName: title, eventPoster: imgData! as NSData, eventStaus: "published", eventTags: tags, eventCreator: eventCreator)
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: UIImgData!, status: "published", tags: tags, creator: eventCreator, id: currentEventId!)
                let alertController = UIAlertController(title: "Success", message: "You have successfully published a draft of an event!", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    if let storyboard = self.storyboard {
                     let vc = storyboard.instantiateInitialViewController()
                     self.present(vc!, animated: true, completion: nil)
                     }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }else {
            let alert = UIAlertController(title: "Event Title Required", message: "You must enter a title for the event", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // choose image for event
    @IBAction func chooseImage(_ sender: Any) {
        let pickerController = UIImagePickerController();
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From ", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                pickerController.sourceType = UIImagePickerControllerSourceType.camera
                self.present(pickerController, animated: true, completion: nil)
            }
        }
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(pickerController, animated: true, completion: nil)
            }
        }
        
        let savedPhotoAction = UIAlertAction(title: "Saved Photo Album", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                pickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.present(pickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            self.eventImage.image = pickedImage
        }
    }
    
    // convert hex value to UIColor
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

}
