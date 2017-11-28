//
//  AddNewAccountViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AddNewAccountViewController: UIViewController {
    
    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    @IBOutlet var stackView: UIStackView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField: UITextField? {
        didSet {
            addToolBarTo(textField: activeTextField!)
        }
    }
    @IBOutlet var accountTitle: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var comment: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        if let activeTF = activeTextField {
            activeTF.inputAccessoryView = UIView()
            activeTF.inputAccessoryView?.backgroundColor = .red
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        let navigationBar = navigationController?.navigationBar.frame.height
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            let totalHeights = (activeTextField?.frame.maxY)! + navigationBar! + topStackConstraint.constant
            let difference = totalHeights - keyBoardFrame.size.height
            if keyBoardFrame.origin.y < totalHeights {
                self.topStackConstraint.constant -= isKeyboardShowing ? difference + 30 : 0
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            } else {
                topStackConstraint.constant = 10
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer ) {
        //activeTextField?.resignFirstResponder()
        view.endEditing(true)
    }
    
    @IBAction func saveAccountButton(_ sender: UIBarButtonItem) {
        saveAccount()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
    }

    
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func saveAccount() {
        if password.text == confirmPassword.text {
            if password.text != "" {
                if accountTitle.text != "" {
                    let context = appDelegate.persistentContainer.viewContext
                    let accountEntity = NSEntityDescription.insertNewObject(forEntityName: "Account", into: context) as! Account
                    accountEntity.name = accountTitle.text
                    accountEntity.image = accountTitle.text?.lowercased()
                    
                    let entryEntity = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context) as! Entry
                    entryEntity.name = accountTitle.text
                    entryEntity.username = username.text
                    entryEntity.password = password.text
                    entryEntity.comment = comment.text
                    
                    accountEntity.addToEntries(entryEntity)
                    do {
                        try context.save()
                        
                        navigationController?.popViewController(animated: true)
                        
                    } catch {
                        displayAlert(title: "Error!", msg: "Oops! Unable to save at this time, please try again.")
                    }
                } else {
                    displayAlert(title: "No Account name!", msg: "Account name is required.")
                }
            } else {
                displayAlert(title: "Empty password", msg: "Please enter your password.")
            }
        } else {
            displayAlert(title: "Passwords do not match!", msg: "Please enter your password again.")
        }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}
