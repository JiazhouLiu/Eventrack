//
//  CreateTVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 22/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CreateTVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate{

    @IBOutlet weak var eventTitleTF: UITextField!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventTagsTF: CustomizableTextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var eventDetailsTF: UITextView!
    @IBOutlet weak var saveDraftBtn: CustomizableButton!
    @IBOutlet weak var publishBtn: CustomizableButton!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    var event: Event?
    
    var dateString: String?
 
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

        
    }
    
    func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "E, MMMM dd, yyyy', 'h:mm a"
        
        
        self.dateString = dateFormatter.string(from: sender.date)
    }
    
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        height = 50
        if indexPath.row == 1 {
            height = 195
        }else if indexPath.row == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! categoryCell
            height = cell.contentView.subviews[0].frame.height
            print(height)
        }else if indexPath.row == 6{
            height = 300
        }else if indexPath.row == 7 || indexPath.row == 8{
            height = 60
        }
        
        return height
    }
    
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveDraftBtnPressed(_ sender: Any) {
        let imgData = UIImageJPEGRepresentation(self.eventImage.image!, 0.8)
        
        if let title = eventTitleTF.text, let date = self.dateString, let location = eventLocation.text, let tagString = eventTagsTF.text, let categoryString = categoryTF.text, let detail = eventDetailsTF.text ,(title.characters.count > 0 && date.characters.count > 0){
            //call the dataService
            let categoryRaw = categoryString.components(separatedBy: ";")
            var category = [String]()
            for singleCat in categoryRaw{
                category.append(singleCat.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
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
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: imgData! as NSData, status: "draft", tags: tags, creator: eventCreator, id: dataServiceInstance.eventAutoId)
                print(self.event!.getID())
                let alertController = UIAlertController(title: "Success", message: "You have successfully saved a draft of an event!", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    /*if let storyboard = self.storyboard {
                        let vc = storyboard.instantiateInitialViewController()
                        self.present(vc!, animated: true, completion: nil)
                    }*/
                    self.saveDraftBtn.setTitle("Update", for: .normal)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let eventCreator = (FIRAuth.auth()?.currentUser?.uid)!
                let dataServiceInstance = DataService.instance
                let currentEventId = self.event?.getID()
                dataServiceInstance.updateEvent(eventId: currentEventId!, eventCategory: category, eventDate: date, eventDetail: detail, eventLocation: location, eventName: title, eventPoster: imgData! as NSData, eventStaus: "draft", eventTags: tags, eventCreator: eventCreator)
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: imgData! as NSData, status: "draft", tags: tags, creator: eventCreator, id: currentEventId!)
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
    
    @IBAction func publishBtnPressed(_ sender: Any) {
        let imgData = UIImageJPEGRepresentation(self.eventImage.image!, 0.8)
        
        if let title = eventTitleTF.text, let date = self.dateString, let location = eventLocation.text, let tagString = eventTagsTF.text, let categoryString = categoryTF.text, let detail = eventDetailsTF.text ,(title.characters.count > 0 && date.characters.count > 0){
            //call the dataService
            let categoryRaw = categoryString.components(separatedBy: ";")
            var category = [String]()
            for singleCat in categoryRaw{
                category.append(singleCat.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
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
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: imgData! as NSData, status: "published", tags: tags, creator: eventCreator, id: dataServiceInstance.eventAutoId)
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
                let eventCreator = (FIRAuth.auth()?.currentUser?.uid)!
                let dataServiceInstance = DataService.instance
                let currentEventId = self.event?.getID()
                dataServiceInstance.updateEvent(eventId: currentEventId!, eventCategory: category, eventDate: date, eventDetail: detail, eventLocation: location, eventName: title, eventPoster: imgData! as NSData, eventStaus: "published", eventTags: tags, eventCreator: eventCreator)
                self.event = Event(category: category, date: date, detail: detail, location: location, name: title, poster: imgData! as NSData, status: "published", tags: tags, creator: eventCreator, id: currentEventId!)
                let alertController = UIAlertController(title: "Success", message: "You have successfully updated a draft of an event!", preferredStyle: UIAlertControllerStyle.alert)
                
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
    

    // MARK: - Table view data source
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

}
