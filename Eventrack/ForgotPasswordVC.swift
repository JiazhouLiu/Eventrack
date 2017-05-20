//
//  ForgotPasswordVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 21/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTF: CustomizableTextField!
    var exist: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetBtnPressed(_ sender: Any) {
        
        
        DataService.instance.usersRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            if let users = snapshot.value as? Dictionary<String, AnyObject>{
                for (_, value) in users {
                    if let dict = value as? Dictionary<String, AnyObject>{
                        if let profile = dict["profile"] as? Dictionary<String, AnyObject>{
                            if let email = profile["email"] as? String{
                                if email.lowercased() == self.emailTF.text!.lowercased(){
                                    self.exist = true
                                }
                            }
                        }
                    }
                }
                if self.exist{
                    AuthService.instance.resetPassword(email: self.emailTF.text!)
                    let alertController = UIAlertController(title: "Success", message: "You have successfully requested for password reset. Please check your email to see further instructions.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        self.performSegue(withIdentifier: "forgotToLogin", sender: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alert = UIAlertController(title: "No such a user", message: "The user with the email you enterred does not exist", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        
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
