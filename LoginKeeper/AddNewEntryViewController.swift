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
    
    //MARK: - Outlets
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var addNewEntryLabel: UILabel!
   
    @IBOutlet var name: UITextField! {
        didSet {
            name.textContentType = UITextContentType("")
            name.addLine()
        }
    }
    @IBOutlet var username: UITextField! {
        didSet {
            username.textContentType = UITextContentType("")
            username.addLine()
        }
    }
    @IBOutlet var password: UITextField! {
        didSet {
            password.textContentType = UITextContentType("")
            password.addLine()
        }
    }
    @IBOutlet var confirmPassword: UITextField! {
        didSet {
            confirmPassword.textContentType = UITextContentType("")
            confirmPassword.addLine()
        }
    }
    @IBOutlet var comment: UITextField! {
        didSet {
            comment.textContentType = UITextContentType("")
            comment.addLine()
        }
    }
    
    //MARK: - Properties
    var titleTextLabel = UILabel()
    var account: Account?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var activeTextField: UITextField?
    var originalBottomConstraint: CGFloat = 0.0
    
    //MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient()
        titleTextLabel.contentMode = .center
        titleTextLabel.font = UIFont(name: "Lato-Black", size: 17)
        titleTextLabel.textColor = .white
        addNewEntryLabel.text = titleTextLabel.text
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        } else {
            appDelegate.removeBannerView()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        originalBottomConstraint = bottomConstraint.constant
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
    
    override func viewWillLayoutSubviews() {
        for v in view.layer.sublayers! {
            if v .isKind(of: CAGradientLayer.self) {
                v.frame = view.bounds
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func saveEntryButton(_ sender: UIBarButtonItem) {
        saveEntry()
    }
    
    //MARK: - Keyboard
    @objc func dismissKeyboard(sender: UITapGestureRecognizer ) {
        //activeTextField?.resignFirstResponder()
        view.endEditing(true)
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
                    bottomConstraint.constant = 0
                } else {
                    let contentInsets = UIEdgeInsets.zero
                    scrollView.contentInset = contentInsets
                    scrollView.scrollIndicatorInsets = contentInsets
                    bottomConstraint.constant = originalBottomConstraint
                }
            }
        }
    }
    
    //MARK: - Alerts
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CoreData
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
    
    //MARK: - TextFields
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
    
    //MARK: - ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scale = 1 - scrollView.contentOffset.y / 200
        addNewEntryLabel.transform = CGAffineTransform(scaleX: min(scale, 1.2) , y: min(scale, 1.2))
        
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
