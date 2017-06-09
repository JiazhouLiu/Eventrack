//
//  MyProfileVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 21/5/17.
//  Version 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    // variables
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    var urlImage: String!
    var pickerView: UIPickerView!
    var countryArray = [String]()
    var spinner: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // spinner setup
        self.spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        self.spinner.color = UIColor.lightGray
        self.spinner.center = userImageView.center
        self.view.addSubview(spinner)
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
        
        // get user attriute from database
        ref.child("users").child(userID!).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let usernameD = value?["username"] as? String ?? ""
            self.username.text = usernameD
            let emailD = value?["email"] as? String ?? ""
            self.email.text = emailD
            //let photoURL = value?["photoURL"] as? String ?? ""
            let storageRef: FIRStorageReference! = DataService.instance.storageRef
            // create path for user image
            let imagePath = "profileImage\(userID!)/userPic.jpg"
            
            // create image reference
            let imageRef = storageRef.child(imagePath)
            imageRef.data(withMaxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                }else{
                    if let data = data {
                        self.userImageView.image = UIImage(data: data)
                        self.spinner.stopAnimating()
                    }
                }
            })
            let countryD = value?["country"] as? String ?? ""
            self.country.text = countryD

        }) { (error) in
            print(error.localizedDescription)
        }

        // get country code
        for code in NSLocale.isoCountryCodes{
            let locale = Locale(identifier: "en_EN") // Country names in English
            let countryName = locale.localizedString(forRegionCode: code)!
            countryArray.append(countryName)
        }
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        country.inputView = pickerView
    }
    
    // hide keyboard when tap to blank space
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // picker view for country selection
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        country.text = countryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: countryArray[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return title
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // choose image tapped
    @IBAction func choosePicture(_ sender: Any) {
        // setup picker controller for images
        let pickerController = UIImagePickerController();
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        // 3 options for user to choose for iamges
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From ", preferredStyle: .actionSheet)
        
        // choose image from camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                pickerController.sourceType = UIImagePickerControllerSourceType.camera
                self.present(pickerController, animated: true, completion: nil)
            }
        }
        
        // choose image from photos library
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(pickerController, animated: true, completion: nil)
            }
        }
        
        // choose image from save photo albums
        let savedPhotoAction = UIAlertAction(title: "Saved Photo Album", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                pickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.present(pickerController, animated: true, completion: nil)
            }
        }
        
        // cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // manipulate image after chosen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            self.userImageView.image = pickedImage
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // update profile button pressed
    @IBAction func updateBtnPressed(_ sender: Any) {
        let imgData = UIImageJPEGRepresentation(self.userImageView.image!, 0.8)
        
        if let email = email.text, let country = country.text, let username = username.text, email.characters.count > 0 {   // all necessary attribute filled
            var messageString = "You have successfully updated your profile"
            var messageTitle = "Success"
            if let password = newPasswordTF.text, password.characters.count > 0{
                
                if (password.characters.count >= 6){
                    DataService.instance.setUserInfo(user: FIRAuth.auth()?.currentUser, username: username, password: password, country: country, data: imgData! as NSData)
                    
                    // change email
                    FIRAuth.auth()?.currentUser?.updateEmail(email) { (error) in
                        if error == nil {   // email changed successfully
                            print("Your email has been changed! Thank you")
                        }else{
                            print(error!.localizedDescription)
                            messageTitle = "Error"
                            messageString = error!.localizedDescription
                        }
                        let alertController = UIAlertController(title: messageTitle, message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                            if messageTitle != "Error"{ // handle error
                                self.performSegue(withIdentifier: "profileToHome", sender: nil)
                            }
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    AuthService.instance.changePassword(password: password)
                }else{
                    messageTitle = "Error"
                    messageString = "Password must be at least 6 chars"
                    let alertController = UIAlertController(title: messageTitle, message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in

                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }else{
                DataService.instance.setUserInfo(user: FIRAuth.auth()?.currentUser, username: username, password: "", country: country, data: imgData! as NSData)
                
                // change email
                FIRAuth.auth()?.currentUser?.updateEmail(email) { (error) in
                    if error == nil {   // email changed successfully
                        print("Your email has been changed! Thank you")
                    }else{
                        print(error!.localizedDescription)
                        messageTitle = "Error"
                        messageString = error!.localizedDescription
                    }
                    let alertController = UIAlertController(title: messageTitle, message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        if messageTitle != "Error"{ // handle error
                            self.performSegue(withIdentifier: "profileToHome", sender: nil)
                        }
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else {  // user email must be entered
            let alert = UIAlertController(title: "User email Required", message: "You must enter an email for the login", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // loggout button for log out function
    @IBAction func logOutBtnPressed(_ sender: Any) {
        // run logout function from Firebase auth service
        if FIRAuth.auth()?.currentUser != nil{
            AuthService.instance.logout()
            
        }
        
        // show user success message and navigate back to root screen
        let alertController = UIAlertController(title: "Success", message: "You have successfully logged out", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "profileToHome", sender: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
