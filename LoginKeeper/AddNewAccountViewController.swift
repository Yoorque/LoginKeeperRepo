//
//  AddNewAccountViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class AddNewAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var accountTitle: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var comment: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveAccountButton(_ sender: UIBarButtonItem) {
        saveAccount()
    }
    
    func saveAccount() {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == accountTitle {
            accountTitle.resignFirstResponder()
            username.becomeFirstResponder()
        } else if textField == username {
            username.resignFirstResponder()
            password.becomeFirstResponder()
        } else if textField == password {
            password.resignFirstResponder()
            confirmPassword.becomeFirstResponder()
        } else if textField == confirmPassword {
            confirmPassword.resignFirstResponder()
            comment.becomeFirstResponder()
        } else if textField == comment {
            comment.resignFirstResponder()
            saveAccount()
        }
        
        return true
    }
}
