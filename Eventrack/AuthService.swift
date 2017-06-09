//
//  AuthService.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  version: 3.0 9/6/2017
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit


typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    // private variable to initialize authservice class
    private static let _instance = AuthService()
    
    // initialize this class
    static var instance: AuthService {
        return _instance
    }
    
    // login method, use firebase auth signIn method to login to the system
    func login(email: String, password: String, onComplete: Completion?){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            }else {
                // logged in
                onComplete?(nil, user)
            }
        })
    }
    
    // signup method, create user first and use login method to login after sign up
    func signup(email: String, username: String, password: String, country: String, data: NSData!, onComplete: Completion?){
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            }else { // no error
                if user?.uid != nil {
                    DataService.instance.setUserInfo(user: user, username: username, password: password, country: country, data: data)
                    self.login(email: email, password: password, onComplete: onComplete)
                }
            }
        })
    }
    
    // logout method, use Firebase auth signout method
    func logout(){
        do {
        	try FIRAuth.auth()?.signOut()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    
    // change Email method, update user auth info: email
    func changeEmail(email: String){
        FIRAuth.auth()?.currentUser?.updateEmail(email) { (error) in
            if error == nil {
                print("Your email has been changed! Thank you")
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    
    // change password method, update user auth info: password
    func changePassword(password: String){
        FIRAuth.auth()?.currentUser?.updatePassword(password) { (error) in
            if error == nil {
                print("Your password has been changed! Thank you")
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    
    // reset Password method, use this method when user clicks on the forgot password button
    func resetPassword(email: String){
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                print("An email about how to reset password has been sent to you! Thank you")
            }else{
                print(error!.localizedDescription)
            }
            
        })
    }
    
    
    // integrated place to handle errors using firebase auth service
    func handleFirebaseError(error: NSError, onComplete: Completion?){
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error._code){
            switch (errorCode){
            case .errorCodeInvalidEmail:    // invalid email
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:   // invalid password
                onComplete?("Invalid password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential: // email exist and duplicated register error
                onComplete?("Could not create account. Email already in use", nil)
                break
            case .errorCodeUserNotFound:    // user email not in the system
                onComplete?("Email cannot be found, please sign up first", nil)
                break
            default:    // default error
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
}
