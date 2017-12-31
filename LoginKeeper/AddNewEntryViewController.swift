//
//  AddNewEntryViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AddNewEntryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    var account: Account?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField = UITextField()
    @IBOutlet var name: UITextField! {
        didSet {
            name.textContentType = UITextContentType("")
        }
    }
    @IBOutlet var username: UITextField! {
        didSet {
            username.textContentType = UITextContentType("")
        }
    }
    @IBOutlet var password: UITextField! {
        didSet {
            password.textContentType = UITextContentType("")
        }
    }
    @IBOutlet var confirmPassword: UITextField! {
        didSet {
            confirmPassword.textContentType = UITextContentType("")
        }
    }
    @IBOutlet var comment: UITextField! {
        didSet {
            comment.textContentType = UITextContentType("")
        }
    }
    
    var titleTextLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleTextLabel.frame.size.height = 25
        titleTextLabel.textAlignment = .center
        titleTextLabel.textColor = UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        titleTextLabel.font = UIFont(name: "Zapf Dingbats", size: 15)
        //titleTextLabel.text = title
        navigationItem.titleView = titleTextLabel
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
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        let navigationBar = navigationController?.navigationBar.frame.height
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let totalHeights = activeTextField.frame.maxY + navigationBar!  + topStackConstraint.constant
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
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
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
                        displayAlert(title: errorLocalized, msg: unableToSaveMessageLocalized)
                    }
                } else {
                    displayAlert(title: noEntryLocalized, msg: noEntryMessageLocalized)
                }
            } else {
                displayAlert(title: emptyPasswordLocalized, msg: emptyPasswordMessageLocalized)
            }
        } else {
            displayAlert(title: passNotMatchLocalized, msg: passNotMatchMessageLocalized)
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
