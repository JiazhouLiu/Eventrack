//
//  MyProfileVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 21/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    var urlImage: String!
    var pickerView: UIPickerView!
    var countryArray = [String]()

    

    override func viewDidLoad() {
        super.viewDidLoad()

        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
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
                    }
                }
            })
            let countryD = value?["country"] as? String ?? ""
            self.country.text = countryD

        }) { (error) in
            print(error.localizedDescription)
        }

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
    @IBAction func choosePicture(_ sender: Any) {
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
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            self.userImageView.image = pickedImage
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        let imgData = UIImageJPEGRepresentation(self.userImageView.image!, 0.8)
        
        if let email = email.text, let country = country.text, let username = username.text, email.characters.count > 0 {
            
            if let password = newPasswordTF.text, password.characters.count > 0{
                DataService.instance.setUserInfo(user: FIRAuth.auth()?.currentUser, username: username, password: password, country: country, data: imgData! as NSData)
                AuthService.instance.changeEmail(email: email)
                AuthService.instance.changePassword(password: password)
                
            }else{
                DataService.instance.setUserInfo(user: FIRAuth.auth()?.currentUser, username: username, password: "", country: country, data: imgData! as NSData)
                AuthService.instance.changeEmail(email: email)
                
            }
            let alertController = UIAlertController(title: "Success", message: "You have successfully updated your profile", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                self.performSegue(withIdentifier: "profileToHome", sender: nil)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: "User email Required", message: "You must enter an email for the login", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func logOutBtnPressed(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil{
            AuthService.instance.logout()
            
        }
        let alertController = UIAlertController(title: "Success", message: "You have successfully updated your profile", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "profileToHome", sender: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
