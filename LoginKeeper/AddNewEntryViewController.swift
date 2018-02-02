//
//  AddNewEntryViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AddNewEntryViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var addNewEntryLabel: UILabel!
    var titleTextLabel = UILabel()
    
    var account: Account?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField: UITextField?
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextLabel.contentMode = .center
        titleTextLabel.font = UIFont(name: "Lato-Black", size: 17)
        titleTextLabel.textColor = UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        addNewEntryLabel.text = titleTextLabel.text
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        } else {
            appDelegate.removeBannerView()
        }
        
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
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        } else {
            appDelegate.removeBannerView()
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            if let textField = activeTextField {
                if isKeyboardShowing {
                    let contentInsets = UIEdgeInsetsMake(0, 0, keyBoardFrame.size.height, 0)
                    scrollView.scrollRectToVisible(textField.frame, animated: true)
                    scrollView.contentInset = contentInsets
                    scrollView.scrollIndicatorInsets = contentInsets
                } else {
                    let contentInsets = UIEdgeInsets.zero
                    scrollView.contentInset = contentInsets
                    scrollView.scrollIndicatorInsets = contentInsets
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scaleX = 1 - scrollView.contentOffset.y / 100
        let scaleY = 1 - scrollView.contentOffset.y / 100
        addNewEntryLabel.transform = CGAffineTransform(scaleX: min(scaleX, 1.2) , y: min(scaleY, 1.2))
        
        if let navController = navigationController {
            if scrollView.contentOffset.y > navController.navigationBar.frame.height {
                addNewEntryLabel.isHidden = true
                navigationItem.titleView = titleTextLabel
                titleTextLabel.isHidden = false
            } else {
                addNewEntryLabel.isHidden = false
                addNewEntryLabel.text = titleTextLabel.text
                titleTextLabel.isHidden = true
            }
        }
    }
}
