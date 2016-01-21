//
//  UserAccountController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-18.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit

class UserAccountController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signOutView: UIView!
    
    @IBOutlet weak var emailTextFieldForSignUp: UITextField!
    @IBOutlet weak var passwordTextFieldForSignUp: UITextField!
    @IBOutlet weak var confirmPasswordTextFieldForSignUp: UITextField!
    
    @IBOutlet weak var emailTextFieldForSignIn: UITextField!
    @IBOutlet weak var passwordTextFieldForSignIn: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil{
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let userInfo : NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKey.UserInfo) as? NSDictionary{
            signOutView.hidden = false
        }else{
            signInView.hidden = false
        }
    }
    
    @IBAction func showSignUpView(sender: AnyObject) {
        signInView.hidden = true
        signUpView.hidden = false
        resetSignInFields()
    }
    
    @IBAction func showSignInView(sender: AnyObject) {
        signInView.hidden = false
        signUpView.hidden = true
        resetSignUpFields()
    }
    
    @IBAction func signUp(sender: AnyObject) {
        guard emailTextFieldForSignUp.text != nil && !emailTextFieldForSignUp.text!.isEmpty else{
            let errorMessage = "Please enter a email address"
            showAlert(errorMessage)
            return
        }
        
        guard passwordTextFieldForSignUp.text != nil  && !passwordTextFieldForSignUp.text!.isEmpty else{
            let errorMessage = "Please enter a password in Password field"
            showAlert(errorMessage)
            return
        }
        
        guard confirmPasswordTextFieldForSignUp.text != nil && !confirmPasswordTextFieldForSignUp.text!.isEmpty else{
            let errorMessage = "Please enter a password in Confirm Password field"
            showAlert(errorMessage)
            return
        }
        
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        guard passwordTextFieldForSignUp.text!.rangeOfCharacterFromSet(whitespace) == nil && confirmPasswordTextFieldForSignUp.text!.rangeOfCharacterFromSet(whitespace) == nil else{
            let errorMessage = "Password can't contain space"
            showAlert(errorMessage)
            return
        }
        
        guard passwordTextFieldForSignUp.text?.characters.count >= 8 && confirmPasswordTextFieldForSignUp.text?.characters.count >= 8 else{
            let errorMessage = "Minimum password length is 8"
            showAlert(errorMessage)
            return
        }
        
        guard confirmPasswordTextFieldForSignUp.text == passwordTextFieldForSignUp.text else{
            let errorMessage = "Passwords entered are not same"
            showAlert(errorMessage)
            return
        }
    }
    
    @IBAction func signIn(sender: AnyObject) {
        print("Email: \(emailTextFieldForSignIn.text), Password: \(passwordTextFieldForSignIn.text)")
        guard emailTextFieldForSignIn.text != nil && !emailTextFieldForSignIn.text!.isEmpty else{
            let errorMessage = "Please enter a email address"
            showAlert(errorMessage)
            return
        }
        
        guard passwordTextFieldForSignIn.text != nil && !passwordTextFieldForSignIn.text!.isEmpty else{
            let errorMessage = "Please enter a password in Password field"
            showAlert(errorMessage)
            return
        }

    }
    
    @IBAction func signOut(sender: AnyObject) {
        
    }
    
    func showAlert(message: String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
            action in
            if self.signInView.hidden != false{
                self.resetSignUpFields()
            }else if self.signUpView.hidden != false{
                self.resetSignInFields()
            }
        })
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func resetSignUpFields(){
        emailTextFieldForSignUp.text = ""
        passwordTextFieldForSignUp.text = ""
        confirmPasswordTextFieldForSignUp.text = ""
    }
    
    func resetSignInFields(){
        emailTextFieldForSignIn.text = ""
        passwordTextFieldForSignIn.text = ""
    }
    
}
