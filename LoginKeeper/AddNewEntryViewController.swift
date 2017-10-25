//
//  AddNewEntryViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AddNewEntryViewController: UIViewController {
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    var account: Account?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField: UITextField? {
        didSet {
            addToolBarTo(textField: activeTextField!)
        }
    }
    @IBOutlet var name: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var comment: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.loadBannerView(forViewController: self, andOrientation: UIDevice.current.orientation)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    @IBAction func saveEntryButton(_ sender: UIBarButtonItem) {
        saveEntry()
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer ) {
        //activeTextField?.resignFirstResponder()
        view.endEditing(true)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        appDelegate.loadBannerView(forViewController: self, andOrientation: UIDevice.current.orientation)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        let navigationBar = navigationController?.navigationBar.frame.height
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let totalHeights = (activeTextField?.frame.maxY)! + navigationBar!  + topStackConstraint.constant
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
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
    
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func saveEntry() {
        if password.text == confirmPassword.text {
            if password.text != "" {
                if name.text != "" {
                    let context = appDelegate.persistentContainer.viewContext
                    let entryEntity = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context) as! Entry
                    entryEntity.name = name.text
                    entryEntity.username = username.text
                    entryEntity.password = password.text
                    entryEntity.comment = comment.text
                    
                    account?.addToEntries(entryEntity)
                    
                    do {
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    } catch {
                        print("Unable to save: \(error)")
                        displayAlert(title: "Error!", msg: "Oops! Unable to save at this time, please try again.")
                    }
                } else {
                    displayAlert(title: "No Entry name!", msg: "New Entry name is required.")
                }
            } else {
                displayAlert(title: "Empty password", msg: "Please enter your password.")
            }
        } else {
            displayAlert(title: "Passwords do not match!", msg: "Please enter your password again.")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == name {
            name.resignFirstResponder()
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
            saveEntry()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
}
