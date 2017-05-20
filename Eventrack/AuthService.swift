//
//  AuthService.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 5/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit


typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
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
    
    func signup(email: String, username: String, password: String, country: String, data: NSData!, onComplete: Completion?){
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            }else {
                if user?.uid != nil {
                    DataService.instance.setUserInfo(user: user, username: username, password: password, country: country, data: data)
                    self.login(email: email, password: password, onComplete: onComplete)
                }
            }
        })
    }
    
    func logout(){
        do {
        	try FIRAuth.auth()?.signOut()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    func changeEmail(email: String){
        FIRAuth.auth()?.currentUser?.updateEmail(email) { (error) in
            if error == nil {
                print("Your email has been changed! Thank you")
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    func changePassword(password: String){
        FIRAuth.auth()?.currentUser?.updatePassword(password) { (error) in
            if error == nil {
                print("Your password has been changed! Thank you")
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    func resetPassword(email: String){
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                print("An email about how to reset password has been sent to you! Thank you")
            }else{
                print(error!.localizedDescription)
            }
            
        })
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?){
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error._code){
            switch (errorCode){
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use", nil)
                break
            case .errorCodeUserNotFound:
                onComplete?("Email cannot be found, please sign up first", nil)
                break
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
}
