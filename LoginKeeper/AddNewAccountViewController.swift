//
//  AddNewAccountViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AddNewAccountViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var logosScrollView: UIScrollView!
    @IBOutlet var topStackConstraint: NSLayoutConstraint!
    @IBOutlet var stackView: UIStackView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var index = 0
    var i = 0
    var activeTextField: UITextField?
    
    @IBOutlet var accountTitle: UITextField! {
        didSet {
            accountTitle.textContentType = UITextContentType("")
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
        
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        
        var y = 0
        var t = 0
        for logo in logoImagesPNG {
            if i > logoImagesPNG.count / 2 {
                y = 55
                i = 0
            }
            let logoImageView = UIImageView()
            logoImageView.frame.size = CGSize(width: 50, height: 50)
            logoImageView.frame.origin = CGPoint(x: i * 55, y: y)
            logoImageView.image = UIImage(named: logo)
            logoImageView.tag = t
            logoImageView.isUserInteractionEnabled = true
            logosScrollView.addSubview(logoImageView)
            i += 1
            t += 1
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
            logoImageView.addGestureRecognizer(tapGesture)
        
        }
        logosScrollView.contentSize.width = 55 * (CGFloat(logoImagesPNG.count / 2) + 1)
        print(logosScrollView.contentSize.width)
    }
    
    //MARK: - NEEDS WORK
    //image view tint for selected logo
    @objc func logoTapped(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIImageView {
            if let textField = activeTextField {
                textField.resignFirstResponder()
            }
            for logo in logosScrollView.subviews {
                if logo is UIImageView {
                let logoImageView = logo as! UIImageView
                    logoImageView.image = logoImageView.image!.withRenderingMode(.alwaysOriginal)
                    logo.layer.borderWidth = 0
                    logo.layer.cornerRadius = logo.bounds.size.width / 8
                }
            }
            
            if view.tag == 0 {
                view.layer.borderColor = UIColor.white.cgColor
                view.layer.borderWidth = 2
            } else {
                view.image = view.image!.withRenderingMode(.alwaysTemplate)
                view.tintColor = .white
            }
            index = view.tag
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        let navigationBar = navigationController?.navigationBar.frame.height
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            let totalHeights = activeTextField!.frame.maxY + navigationBar! + topStackConstraint.constant
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
                    if entryName.text != "" {
                        let context = appDelegate.persistentContainer.viewContext
                        let accountEntity = NSEntityDescription.insertNewObject(forEntityName: "Account", into: context) as! Account
                        accountEntity.name = accountTitle.text
                        accountEntity.image = logoImagesPNG[index]
                        
                        let entryEntity = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context) as! Entry
                        entryEntity.name = entryName.text
                        entryEntity.username = username.text
                        entryEntity.password = password.text
                        entryEntity.comment = comment.text
                        
                        accountEntity.addToEntries(entryEntity)
                        do {
                            try context.save()
                            
                            navigationController?.popViewController(animated: true)
                            
                        } catch {
                            displayAlert(title: errorLoc, msg: unableToSaveMessageLoc)
                        }
                    }
                    else {
                        displayAlert(title: noEntryLoc, msg: noEntryMessageLoc)
                    }
                } else {
                    displayAlert(title: noAccountLoc, msg: noAccountMessageLoc)
                }
            } else {
                displayAlert(title: emptyPasswordLoc, msg: emptyPasswordMessageLoc)
            }
        } else {
            displayAlert(title: passNotMatchLoc, msg: passNotMatchMessageLoc)
        }
        logoImagesPNG.remove(at: 0)
        logoImagesPNG.insert("pngloginkeeper", at: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == accountTitle {
            accountTitle.resignFirstResponder()
            entryName.becomeFirstResponder()
        } else if textField == entryName {
            entryName.resignFirstResponder()
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == accountTitle {
            for logo in accountLogos {
                if accountTitle.text!.lowercased().replacingOccurrences(of: " ", with: "") == logo {
                    for imageView in logosScrollView.subviews {
                        if imageView.tag == 0 {
                            imageView.removeFromSuperview()
                        }
                    }
                    logoImagesPNG.remove(at: 0)
                    logoImagesPNG.insert(logo, at: 0)
                    let imageView = UIImageView()
                    imageView.image = UIImage(named: logo)
                    
                    imageView.frame.size = CGSize(width: 50, height: 50)
                    imageView.frame.origin = CGPoint(x:0, y: 0)
                    imageView.image = UIImage(named: logo)
                    imageView.tag = 0
                    imageView.isUserInteractionEnabled = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
                    imageView.addGestureRecognizer(tapGesture)
                    logosScrollView.addSubview(imageView)
                    break
                } else if accountTitle.text!.lowercased().replacingOccurrences(of: " ", with: "").contains(logo) {
                    logoImagesPNG.insert(logo, at: 1)
                    break
                }
            }
        }
    }
    //MARK: - ScrollView Delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let textField = activeTextField {
            textField.resignFirstResponder()
        }
    }
}
