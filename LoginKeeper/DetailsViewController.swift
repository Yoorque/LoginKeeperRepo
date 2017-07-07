//
//  DetailsViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var stackView: UIStackView!

    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    var entryDetails: Entry?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField: UITextField?
    @IBOutlet var name: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var comment: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        name.text = entryDetails?.name
        username.text = entryDetails?.username
        password.text = entryDetails?.password
        comment.text = entryDetails?.comment
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer ) {
        activeTextField?.resignFirstResponder()
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        let navigationBar = navigationController?.navigationBar.frame.height
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let totalHeights = (activeTextField?.frame.maxY)! + navigationBar!
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            let difference = totalHeights - keyBoardFrame.origin.y
            if keyBoardFrame.origin.y < totalHeights {
                self.topStackConstraint.constant -= isKeyboardShowing ? difference + 30 : 0
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            } else {
                topStackConstraint.constant = 8
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    @IBAction func saveChangesButton(_ sender: UIBarButtonItem) {
        saveChanges()
    }
    
    func saveChanges() {
        let context = appDelegate.persistentContainer.viewContext
        entryDetails?.name = name.text
        entryDetails?.username = username.text
        entryDetails?.password = password.text
        entryDetails?.comment = comment.text
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Unable to save: \(error)")
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
            comment.becomeFirstResponder()
        } else if textField == comment {
            comment.resignFirstResponder()
            saveChanges()
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
}
