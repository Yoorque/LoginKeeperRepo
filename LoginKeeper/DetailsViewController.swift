//
//  DetailsViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var favoritedStar: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet var accountName: UITextField! {
        didSet {
            accountName.textContentType = UITextContentType("")
            accountName.layer.cornerRadius = 15
            accountName.addLine()
            accountName.layoutSubviews()
        }
    }
    
    @IBOutlet var entryName: UITextField! {
        didSet {
            entryName.textContentType = UITextContentType("")
            entryName.layer.cornerRadius = 15
            entryName.addLine()
            accountName.layoutSubviews()
        }
    }
    
    @IBOutlet var username: UITextField! {
        didSet {
            username.textContentType = UITextContentType("")
            username.layer.cornerRadius = 15
            username.addLine()
            accountName.layoutSubviews()
        }
    }
    
    @IBOutlet var password: UITextField! {
        didSet {
            password.textContentType = UITextContentType("")
            password.layer.cornerRadius = 15
            password.addLine()
            accountName.layoutSubviews()
        }
    }
    
    @IBOutlet var comment: UITextField! {
        didSet {
            comment.textContentType = UITextContentType("")
            comment.layer.cornerRadius = 15
            comment.addLine()
            accountName.layoutSubviews()
        }
    }
    
    //MARK: - Properties
    var entryDetails: Entry?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var activeTextField: UITextField?
    let titleTextLabel = UILabel()
    let imageViewForTitle = UIImageView()
    var originalBottomConstraint: CGFloat = 0.0
    
    override var previewActionItems: [UIPreviewActionItem] {
        let copyAll = UIPreviewAction(title: "Copy All", style: .default, handler: {_,_  in
            let copyText = "\(accountTextLocalized): \(self.entryDetails!.account!.name!)\n\(entryNameTextLocalized): \(self.entryDetails!.name!)\n\(usernameTextLocalized): \(self.entryDetails!.username!)\n\(passwordTextLocalized): \(self.entryDetails!.password!)\n\(commentTextLocalized): \(self.entryDetails!.comment!)"
            self.copyPaste(text: copyText)
        })
        return [copyAll]
    }
    
    //MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGradient()
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.loadAd(forViewController: self)
        } else {
            appDelegate.removeBannerView()
        }
       
        logoImage.image = UIImage(named: "\(entryDetails!.account!.image!)")?.resizedImage(newSize: CGSize(width: 60, height: 60))
        imageViewForTitle.image = UIImage(named: "\(entryDetails!.account!.image!)")?.resizedImage(newSize: CGSize(width: 30, height: 30))
        logoImage.contentMode = .scaleAspectFit
        imageViewForTitle.contentMode = .scaleAspectFit
        navigationItem.titleView = imageViewForTitle
        navigationItem.titleView?.isHidden = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        originalBottomConstraint = bottomContraint.constant
        undoButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        
        accountName.text = entryDetails?.account?.name
        entryName.text = entryDetails?.name
        username.text = entryDetails?.username
        password.text = entryDetails?.password
        comment.text = entryDetails?.comment
        
        if entryDetails?.favorited == true {
            favoritedStar.image = UIImage(named: "star")
        } else {
            favoritedStar.image = UIImage(named: "emptyStar")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveChanges()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            loadAd()
        }
    }
    
    override func viewWillLayoutSubviews() {
        for v in view.layer.sublayers! {
            if v .isKind(of: CAGradientLayer.self) {
                v.frame = view.bounds
            }
        }
    }
    
    //MARK: - Helper functions
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    func loadAd() {
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
    }
    
    func textEditEnabled() {
        print("Enabled")
        
        accountName.isEnabled = true
        accountName.textColor = .white
        
        entryName.isEnabled = true
        entryName.textColor = .white
        
        username.isEnabled = true
        username.textColor = .white
        
        password.isEnabled = true
        password.textColor = .white
        
        comment.isEnabled = true
        comment.textColor = .white
    }
    
    func textEditDisabled() {
        print("Disabled")
        undoButton.isEnabled = false
        accountName.isEnabled = false
        accountName.textColor = .lightText
        
        entryName.isEnabled = false
        entryName.textColor = .lightText
        
        username.isEnabled = false
        username.textColor = .lightText
        
        password.isEnabled = false
        password.textColor = .lightText
        
        comment.isEnabled = false
        comment.textColor = .lightText
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
                textField.backgroundColor = UIColor(red: 190/255, green: 60/255, blue: 255/255, alpha: 1)
                textField.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                textField.text = NSLocalizedString("COPIED", comment: "copy notification")
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, animations: {
                    textField.backgroundColor = .clear
                    textField.textColor = textColor
                    textField.text = text
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                })
            })
        }
    }
    
    func emptyTextAlert() {
        let alert = UIAlertController(title: "Warning!", message: "Nothing to copy here.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Actions
    @IBAction func copyButton(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            if accountName.text != "" {
                copyPaste(text: accountName.text!)
                animateClipboardTextFor(textField: accountName, with: entryDetails!.account!.name!)
            } else {
                emptyTextAlert()
            }
        case 2:
            if entryName.text != ""{
                copyPaste(text: entryName.text!)
                animateClipboardTextFor(textField: entryName, with: entryDetails!.name!)
            } else {
                emptyTextAlert()
            }
        case 3:
            if username.text != ""{
                copyPaste(text: username.text!)
                animateClipboardTextFor(textField: username, with: entryDetails!.username!)
            } else {
                emptyTextAlert()
            }
        case 4:
            if password.text != ""{
                copyPaste(text: password.text!)
                animateClipboardTextFor(textField: password, with: entryDetails!.password!)
            } else {
                emptyTextAlert()
            }
        case 5:
            if comment.text != ""{
                copyPaste(text: comment.text!)
                animateClipboardTextFor(textField: comment, with: entryDetails!.comment!)
            } else {
                emptyTextAlert()
            }
            
        default:
            print("No such case")
        }
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
    
    @IBAction func copyAllButton(_ sender: Any) {
        
        let copyText = "\(accountTextLocalized): \(entryDetails!.account!.name!)\n\(entryNameTextLocalized): \(entryDetails!.name!)\n\(usernameTextLocalized): \(entryDetails!.username!)\n\(passwordTextLocalized): \(entryDetails!.password!)\n\(commentTextLocalized): \(entryDetails!.comment!)"
        copyPaste(text: copyText)
        animateClipboardTextFor(textField: accountName, with: entryDetails?.account?.name ?? "")
        animateClipboardTextFor(textField: entryName, with: entryDetails?.name ?? "")
        animateClipboardTextFor(textField: username, with: entryDetails?.username ?? "")
        animateClipboardTextFor(textField: password, with: entryDetails?.password ?? "")
        animateClipboardTextFor(textField: comment, with: entryDetails?.comment ?? "")
    }
    
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        NotificationCenter.default.removeObserver(self)
        
        let textToShare = "LoginKeeper \n\(accountTextLocalized): \(entryDetails!.account!.name!)\n\(entryNameTextLocalized): \(entryDetails!.name!)\n\(usernameTextLocalized): \(entryDetails!.username!)\n\(passwordTextLocalized): \(entryDetails!.password!)\n\(commentTextLocalized): \(entryDetails!.comment!)"
        
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender.customView
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        activeTextField?.undoManager?.undo()
    }
    
    //MARK: - Keyboard
    @objc func dismissKeyboard(sender: UITapGestureRecognizer ) {
        activeTextField?.resignFirstResponder()
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
                    bottomContraint.constant = 0
                } else {
                    let contentInsets = UIEdgeInsets.zero
                    scrollView.contentInset = contentInsets
                    scrollView.scrollIndicatorInsets = contentInsets
                    bottomContraint.constant = originalBottomConstraint
                }
            }
        }
    }
    
    //MARK: - CoreData functions
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
            
            let alert = UIAlertController(title: errorLocalized, message: unableToSaveMessageLocalized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - TextField functions
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
    
    @objc func textChange() {
        if let textField = activeTextField {
            if let manager = textField.undoManager {
                if manager.canUndo {
                    undoButton.isEnabled = true
                } else {
                    undoButton.isEnabled = false
                }
                
            }
        }
    }
    
    //MARK: - ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        let scale = 1 - scrollView.contentOffset.y / 200
        logoImage.transform = CGAffineTransform(scaleX: min(scale, 1.2) , y: min(scale, 1.2))
        if let navController = navigationController {
            if scrollView.contentOffset.y > navController.navigationBar.frame.height {
                logoImage.isHidden = true
                imageViewForTitle.isHidden = false
                imageViewForTitle.addShadow()
            } else {
                logoImage.isHidden = false
                imageViewForTitle.isHidden = true
            }
        }
    }
}




