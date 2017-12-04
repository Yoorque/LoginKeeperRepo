//
//  DetailsViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var favoritedStar: UIImageView!

    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    var entryDetails: Entry?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField: UITextField?
    @IBOutlet var accountName: UITextField!
    @IBOutlet var name: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var comment: UITextField!
    let titleTextLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        accountName.text = entryDetails?.account?.name
        name.text = entryDetails?.name
        username.text = entryDetails?.username
        password.text = entryDetails?.password
        comment.text = entryDetails?.comment
        
        if entryDetails!.account!.entries!.count > 1 {
            if entryDetails?.favorited == true {
                favoritedStar.image = UIImage(named: "star")
            } else {
                favoritedStar.image = UIImage(named: "emptyStar")
            }
        } else {
            if entryDetails?.account?.favorited == true {
                favoritedStar.image = UIImage(named: "star")
            } else {
                favoritedStar.image = UIImage(named: "emptyStar")
            }
        }
    }
    
    func textEditEnabled() {
        print("Enabled")
       
        name.isEnabled = true
        name.textColor = UIColor(displayP3Red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        name.setNeedsLayout()
       
        username.isEnabled = true
        username.textColor = UIColor(displayP3Red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        username.setNeedsLayout()
       
        password.isEnabled = true
        password.textColor = UIColor(displayP3Red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        password.setNeedsLayout()
       
        comment.isEnabled = true
        comment.textColor = UIColor(displayP3Red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        comment.setNeedsLayout()
    }
    
    func textEditDisabled() {
        print("Disabled")
        
        name.isEnabled = false
        name.textColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
        name.setNeedsLayout()
        
        username.isEnabled = false
        username.textColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
        username.setNeedsLayout()
        
        password.isEnabled = false
        password.textColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
        password.setNeedsLayout()
        
        comment.isEnabled = false
        comment.textColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
        comment.setNeedsLayout()
    }
    @IBAction func editButton(_ sender: Any) {
        let button = sender as! UIBarButtonItem
        if name.isEnabled {
            textEditDisabled()
            button.style = .plain
            button.title = "Edit"
            saveChanges()
        } else {
            textEditEnabled()
            button.style = .done
            button.title = "Save"
        }
    }
    func copyPaste(text: String) {
        let copyPaste = UIPasteboard.general
        copyPaste.string = text
    }
    func animateClipboardTextFor(textField: UITextField, with text: String) {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            let textColor = textField.textColor
            UIView.animate(withDuration: 0.5, animations: {
                textField.backgroundColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
                textField.textColor = UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
                textField.text = "COPIED TO CLIPBOARD"
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, animations: {
                    textField.backgroundColor = UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
                    textField.textColor = textColor
                    textField.text = text
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                })
            })
        }
    }
    @IBAction func copyAccountButton(_ sender: Any) {
        if let text = accountName.text {
            copyPaste(text: text)
            animateClipboardTextFor(textField: accountName, with: entryDetails?.account?.name ?? "")
        }
    }
    @IBAction func copyEntryButton(_ sender: Any) {
        if let text = name.text {
            copyPaste(text: text)
            animateClipboardTextFor(textField: name, with: entryDetails?.name ?? "")
        }
    }
    @IBAction func copyUsernameButton(_ sender: Any) {
        if let text = username.text {
            copyPaste(text: text)
            animateClipboardTextFor(textField: username, with: entryDetails?.username ?? "")
        }
    }
    @IBAction func copyPasswordButton(_ sender: Any) {
        if let text = password.text {
            copyPaste(text: text)
            animateClipboardTextFor(textField: password, with: entryDetails?.password ?? "")
        }
    }
    @IBAction func copyCommentButton(_ sender: Any) {
        if let text = comment.text {
            copyPaste(text: text)
            animateClipboardTextFor(textField: comment, with: entryDetails?.comment ?? "")
        }
    }
    @IBAction func copyAllButton(_ sender: Any) {
        let copyText = "Account\(entryDetails!.account!.name!)\nEntry name: \(entryDetails!.name!)\nUsername: \(entryDetails!.username!)\nPassword: \(entryDetails!.password!)\nComment: \(entryDetails!.comment!)"
            copyPaste(text: copyText)
        animateClipboardTextFor(textField: accountName, with: entryDetails?.account?.name ?? "")
        animateClipboardTextFor(textField: name, with: entryDetails?.name ?? "")
        animateClipboardTextFor(textField: username, with: entryDetails?.username ?? "")
        animateClipboardTextFor(textField: password, with: entryDetails?.password ?? "")
        animateClipboardTextFor(textField: comment, with: entryDetails?.comment ?? "")
    }
    
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        NotificationCenter.default.removeObserver(self)
        
        let textToShare = "LoginKeeper \nAccount name: \(entryDetails!.account!.name!)\nEntry name: \(entryDetails!.name!)\nUsername: \(entryDetails!.username!)\nPassword: \(entryDetails!.password!)\nComment: \(entryDetails!.comment!)"
        
            let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            activityVC.popoverPresentationController?.sourceView = sender.customView
            self.present(activityVC, animated: true, completion: nil)
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer ) {
        activeTextField?.resignFirstResponder()
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        guard let navigationBar = navigationController?.navigationBar.frame.height else {
            return
        }
        
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            
            let totalHeights = (activeTextField?.frame.maxY)! + navigationBar + topStackConstraint.constant
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            
            let difference = totalHeights - keyBoardFrame.size.height
            
            
            if keyBoardFrame.origin.y < totalHeights {
                self.topStackConstraint.constant -= isKeyboardShowing ? difference + 30 : 0
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            } else {
                topStackConstraint.constant = 40
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func saveChanges() {
        let context = appDelegate.persistentContainer.viewContext
        entryDetails?.name = name.text
        entryDetails?.username = username.text
        entryDetails?.password = password.text
        entryDetails?.comment = comment.text
        do {
            try context.save()
        } catch {
            print("Unable to save: \(error)")
            let alert = UIAlertController(title: "Error!", message: "Oops! Unable to save changes at this time, please try again!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveChanges()
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
