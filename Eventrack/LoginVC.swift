//
//  LoginVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var changePwdBtn: UIButton!
    @IBOutlet weak var forgotPwdBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.white

        loginBtn.layer.cornerRadius = 10
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.borderColor = UIColor.white.cgColor
        
        signupBtn.layer.cornerRadius = 10
        
        var userFrameRect: CGRect = usernameTF.frame
        userFrameRect.size.height = 50
        usernameTF.frame = userFrameRect
        var passwordFrameRect: CGRect = passwordTF.frame
        passwordFrameRect.size.height = 50
        passwordTF.frame = passwordFrameRect
        
//        let swipeBackGesture = UISwipeGestureRecognizer(target: self, action: #selector(loginCancel(_:)))
//        swipeBackGesture.direction = .up
//        self.view.addGestureRecognizer(swipeBackGesture)
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginCancelled(_ sender: Any) {
        self.performSegue(withIdentifier: "loginCancel", sender: nil)
    }

    @IBAction func loginCancelledByX(_ sender: Any) {
        self.performSegue(withIdentifier: "loginCancel", sender: nil)
    }
    
    

//    func loginCancel(_ recognizer: UISwipeGestureRecognizer){
//        self.performSegue(withIdentifier: "loginCancel", sender: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if let email = usernameTF.text, let pass = passwordTF.text, (email.characters.count > 0 && pass.characters.count > 0){
            //call the login service
            AuthService.instance.login(email: email, password: pass, onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    let alert = UIAlertController(title: "Error Authentication", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                    self.present(alert, animated:true, completion: nil)
                    return
                }
                
                self.showToast(message: "Successfully Logged In")
                if let storyboard = self.storyboard {
                    let vc = storyboard.instantiateInitialViewController()
                    self.present(vc!, animated: true, completion: nil)
                }
            })
        }
        else {
            let alert = UIAlertController(title: "Username and Password Required", message: "You must enter both a username and a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    @IBAction func signupPressed(_ sender: Any) {
        var displayName: String?
        if let email = usernameTF.text, let pass = passwordTF.text, (email.characters.count > 0 && pass.characters.count > 0){
            //call the login service
            AuthService.instance.signup(email: email, password: pass, onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    let alert = UIAlertController(title: "Error Authentication", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                    self.present(alert, animated:true, completion: nil)
                    return
                }

                let alert = UIAlertController(title: "Display Name", message: "You have successfully created a new account. Please enter a display name:", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Display name"
                }
                
                alert.addAction(UIAlertAction(title: "Enter Eventrack", style: .default, handler: { [weak alert] (_) in
                    if let usernameTextField: UITextField = alert!.textFields?[0] {
                        if let uid = FIRAuth.auth()?.currentUser?.uid{
                            displayName = usernameTextField.text!
                            DataService.instance.saveUser(uid: uid, displayName: displayName!)

                            if let storyboard = self.storyboard {
                                let vc = storyboard.instantiateInitialViewController()
                                self.present(vc!, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                
            })
        }
        else {
            let alert = UIAlertController(title: "Username and Password Required", message: "You must enter both a username and a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    @IBAction func changePwdPressed(_ sender: Any) {
        
        
    }
    @IBAction func forgotPwdPressed(_ sender: Any) {
        
        
    }
    
    
    // toast function for notification
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2, width: 300, height: 100))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.numberOfLines = 3
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
