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
    
    //MARK: - Outlets
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewScrollView: UIScrollView!
    @IBOutlet weak var logosScrollView: UIScrollView!
    @IBOutlet weak var addNewAccLabel: UILabel!
    
    @IBOutlet var accountTitle: UITextField! {
        didSet {
            accountTitle.textContentType = UITextContentType("")
            accountTitle.addLine()
        }
    }
    
    @IBOutlet var entryName: UITextField! {
        didSet {
            entryName.textContentType = UITextContentType("")
            entryName.addLine()
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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var index = 0
    var i = 0
    var y = 0
    var t = 0
    var activeTextField: UITextField?
    var originalBottomConstraint: CGFloat = 0.0
    
    //MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradient()
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        } else {
            appDelegate.removeBannerView()
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
        
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
    
    //MARK: - Gesture
    @objc func logoTapped(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIImageView {
            if let textField = activeTextField {
                textField.resignFirstResponder()
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: {_ in
                if view.tag == 0 {
                    view.layer.borderColor = UIColor.purple.cgColor
                    view.layer.borderWidth = 2
                    view.layer.cornerRadius = view.bounds.size.width / 8
                    view.clipsToBounds = true
                } else {
                    view.image = view.image!.withRenderingMode(.alwaysTemplate)
                    view.tintColor = UIColor.purple
                }
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = .identity
                }, completion: {_ in
                })
            })
            
            for logo in logosScrollView.subviews {
                if logo is UIImageView {
                    let logoImageView = logo as! UIImageView
                    logoImageView.image = logoImageView.image!.withRenderingMode(.alwaysOriginal)
                    logo.layer.borderWidth = 0
                }
            }
            
            index = view.tag
        }
    }
    
    //MARK: - Keyboard
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            if let textField = activeTextField {
                if isKeyboardShowing {
                    let contentInsets = UIEdgeInsetsMake(0, 0, keyBoardFrame.size.height, 0)
                    viewScrollView.contentInset = contentInsets
                    viewScrollView.scrollIndicatorInsets = contentInsets
                    viewScrollView.scrollRectToVisible(textField.frame, animated: true)
                    bottomConstraint.constant = 0
                } else {
                    let contentInsets = UIEdgeInsets.zero
                    viewScrollView.contentInset = contentInsets
                    viewScrollView.scrollIndicatorInsets = contentInsets
                    bottomConstraint.constant = originalBottomConstraint
                }
            }
        }
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer ) {
        //activeTextField?.resignFirstResponder()
        view.endEditing(true)
    }
    
    //MARK: - Actions
    @IBAction func saveAccountButton(_ sender: UIBarButtonItem) {
        saveAccount()
    }
    
    //MARK: - CoreData
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
                            displayAlert(title: errorLocalized, msg: unableToSaveMessageLocalized)
                        }
                    }
                    else {
                        displayAlert(title: noEntryLocalized, msg: noEntryMessageLocalized)
                    }
                } else {
                    displayAlert(title: noAccountLocalized, msg: noAccountMessageLocalized)
                }
            } else {
                displayAlert(title: emptyPasswordLocalized, msg: emptyPasswordMessageLocalized)
            }
        } else {
            displayAlert(title: passNotMatchLocalized, msg: passNotMatchMessageLocalized)
        }
        logoImagesPNG.remove(at: 0)
        logoImagesPNG.insert("pngloginkeeper", at: 0)
    }
    
    //MARK: - TextFields
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
        for logo in accountLogos {
            if accountTitle.text!.lowercased().replacingOccurrences(of: " ", with: "") == logo || accountTitle.text!.lowercased().replacingOccurrences(of: " ", with: "").contains(logo) {
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
                imageView.contentMode = .scaleAspectFit
                imageView.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
                imageView.addGestureRecognizer(tapGesture)
                logosScrollView.addSubview(imageView)
                break
            } else {
                for logo in logoImagesPNG {
                    if logo.contains(accountTitle.text!.lowercased().replacingOccurrences(of: " ", with: "")) && accountTitle.text!.count > 3 {
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
                        imageView.contentMode = .scaleAspectFit
                        imageView.isUserInteractionEnabled = true
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoTapped))
                        imageView.addGestureRecognizer(tapGesture)
                        logosScrollView.addSubview(imageView)
                        break
                    }
                }
            }
        }
    }
    
    //MARK: - ScrollView Delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == logosScrollView {
            if let textField = activeTextField {
                textField.resignFirstResponder()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == viewScrollView {
        
            let scale = 1 - viewScrollView.contentOffset.y / 200
            
            addNewAccLabel.transform = CGAffineTransform(scaleX: min(scale, 1.5) , y: min(scale, 1.5))
        }
        if let navController = navigationController {
            if viewScrollView.contentOffset.y > navController.navigationBar.frame.height {
                addNewAccLabel.isHidden = true
                title = "Add New Account"
            } else {
                addNewAccLabel.isHidden = false
                title = ""
            }
        }
    }
    
    //MARK: - Alerts
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
