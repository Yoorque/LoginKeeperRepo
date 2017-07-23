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
    @IBOutlet var accountName: UITextField!
    @IBOutlet var name: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var comment: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.loadBannerView(forViewController: self, andOrientation: UIDevice.current.orientation)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        appDelegate.loadBannerView(forViewController: self, andOrientation: UIDevice.current.orientation)
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer ) {
        activeTextField?.resignFirstResponder()
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        let navigationBar = navigationController?.navigationBar.frame.height
        //print("NavBar: \(navigationBar!)")
        if let userInfo = notification.userInfo {
            let keyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            //  print("KeyboardFrame: \(keyBoardFrame.height)")
            let totalHeights = (activeTextField?.frame.maxY)! + navigationBar! + topStackConstraint.constant
            //print("TotalHeights: \(totalHeights)")
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            //print("isShowing: \(isKeyboardShowing)")
            let difference = totalHeights - keyBoardFrame.size.height
            //print("Diff: \(difference)")
            //print("kbFrameOriginY\(keyBoardFrame.origin.y)")
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
