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
    @IBOutlet var favoritedStar: UIImageView!

    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    var entryDetails: Entry?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activeTextField: UITextField?
    @IBOutlet var accountName: UITextField! {
        didSet {
            accountName.textContentType = UITextContentType("")
        }
    }
    @IBOutlet var entryName: UITextField! {
        didSet {
            entryName.textContentType = UITextContentType("")
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
    @IBOutlet var comment: UITextField! {
        didSet {
            comment.textContentType = UITextContentType("")
        }
    }
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
        entryName.text = entryDetails?.name
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
        accountName.isEnabled = true
        accountName.textColor = UIColor(displayP3Red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        accountName.setNeedsLayout()
        
        entryName.isEnabled = true
        entryName.textColor = UIColor(displayP3Red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        entryName.setNeedsLayout()
       
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
        
        accountName.isEnabled = false
        accountName.textColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
        accountName.setNeedsLayout()
        
        entryName.isEnabled = false
        entryName.textColor = UIColor(displayP3Red: 135/255, green: 140/255, blue: 154/255, alpha: 1)
        entryName.setNeedsLayout()
        
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
        if accountName.isEnabled {
            textEditDisabled()
            button.style = .plain
            button.title = NSLocalizedString("Edit", comment: "")
            saveChanges()
        } else {
            textEditEnabled()
            button.style = .done
            button.title = NSLocalizedString("Save", comment: "")
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
                textField.text = NSLocalizedString("COPIED", comment: "copy notification")
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
        if let text = entryName.text {
            copyPaste(text: text)
            animateClipboardTextFor(textField: entryName, with: entryDetails?.name ?? "")
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
        
        let copyText = "\(accountTextLoc): \(entryDetails!.account!.name!)\n\(entryNameTextLoc): \(entryDetails!.name!)\n\(usernameTextLoc): \(entryDetails!.username!)\n\(passwordTextLoc): \(entryDetails!.password!)\n\(commentTextLoc): \(entryDetails!.comment!)"
            copyPaste(text: copyText)
        animateClipboardTextFor(textField: accountName, with: entryDetails?.account?.name ?? "")
        animateClipboardTextFor(textField: entryName, with: entryDetails?.name ?? "")
        animateClipboardTextFor(textField: username, with: entryDetails?.username ?? "")
        animateClipboardTextFor(textField: password, with: entryDetails?.password ?? "")
        animateClipboardTextFor(textField: comment, with: entryDetails?.comment ?? "")
    }
    
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        NotificationCenter.default.removeObserver(self)
        
        let textToShare = "LoginKeeper \n\(accountTextLoc): \(entryDetails!.account!.name!)\n\(entryNameTextLoc): \(entryDetails!.name!)\n\(usernameTextLoc): \(entryDetails!.username!)\n\(passwordTextLoc): \(entryDetails!.password!)\n\(commentTextLoc): \(entryDetails!.comment!)"
        
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
        entryDetails?.account?.name = accountName.text
        entryDetails?.name = entryName.text
        entryDetails?.username = username.text
        entryDetails?.password = password.text
        entryDetails?.comment = comment.text
        do {
            try context.save()
        } catch {
            
            let alert = UIAlertController(title: errorLoc, message: unableToSaveMessageLoc, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okLoc, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveChanges()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountName {
            accountName.resignFirstResponder()
            entryName.becomeFirstResponder()
        } else if textField == entryName {
            entryName.resignFirstResponder()
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
