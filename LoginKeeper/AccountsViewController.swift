//
//  AccountsViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication
import GoogleMobileAds

var authenticated = false

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AccountsDisplayAlertDelegate {
    @IBOutlet var lockButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.returnKeyType = .search
            self.searchBar.delegate = self
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    var index: Int?
    var accounts = [Account]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var passwordSetShownBefore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil, using: {_ in
            self.navigationController?.popToViewController(self, animated: true)
            self.accounts = []
            self.tableView.reloadData()
            self.authenticateUser()
            authenticated = false
            
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        if let shown = defaults.value(forKey: "shownBefore") as? Bool {
            passwordSetShownBefore = shown
        }
        if passwordSetShownBefore == false {
            setPassword()
        } else {
            authenticateUser()
        }
        
        addToolBarTo(searchBar: searchBar)
    }
    
    func appDidEnterForeground() {
        authenticateUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        appDelegate.loadBannerView(forViewController: self, andOrientation: UIDevice.current.orientation)
        if authenticated {
            fetchFromCoreData()
        }
        updateTableViewBottomInset()
    }
    
    @IBAction func showInfoButon(_ sender: Any) {
        performSegue(withIdentifier: "showInfoSegue", sender: self)
    }
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            if !searchBar.frame.contains(view.frame) {
                view.resignFirstResponder()
            }
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        appDelegate.loadBannerView(forViewController: self, andOrientation: UIDevice.current.orientation)
        updateTableViewBottomInset()
    }
    
    func updateTableViewBottomInset() {
        if let banner = appDelegate.adBannerView {
            tableView.contentInset.bottom = banner.frame.size.height
        }

    }
    
    func setPassword() {
        let alert = UIAlertController(title: "Password", message: "Set your backup password for LoginKeepr", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let password = alert.textFields?.first?.text!
            
            self.defaults.set(password, forKey: "userPassword")
            self.defaults.set(true, forKey: "shownBefore")
            self.authenticateUser()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.defaults.set(false, forKey: "shownBefore")
            let alert = UIAlertController(title: "Password is required", message: "Please set your password to continue.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.setPassword()
            }))
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder = "Enter password"
        })
        present(alert, animated: true, completion: nil)
    }
    
    
    func loginAlert(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.authenticateUser()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        let message = "Identify yourself"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: message, reply: {success, error in
                // Touch ID
                DispatchQueue.main.async {
                if success {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.searchBar.isUserInteractionEnabled = true
                    self.fetchFromCoreData()
                    authenticated = true
                    print("Success: TouchID")
                } else {
                    authenticated = false
                    self.accounts = []
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.searchBar.isUserInteractionEnabled = false
                    self.lockButton.title = "Unlock"
                    self.tableView.reloadData()
                    
                    switch error!._code {
                    case Int(kLAErrorAuthenticationFailed):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorUserCancel):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorBiometryNotEnrolled):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorPasscodeNotSet):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorSystemCancel):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorUserFallback):
                        let alert = UIAlertController(title: "Password", message: "Enter your password", preferredStyle: .alert)
                        alert.addTextField(configurationHandler: {textField in
                            textField.placeholder = "Enter your password"
                        })
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            let defaults = UserDefaults.standard
                            if let pass = defaults.value(forKey: "userPassword") as? String {
                                if pass == alert.textFields?.first?.text {
                                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                                    self.searchBar.isUserInteractionEnabled = true
                                    self.lockButton.title = "Lock"
                                    self.fetchFromCoreData()
                                    authenticated = true
                                    print("Success")
                                } else {
                                    self.alert(message: error!.localizedDescription)
                                    self.searchBar.isUserInteractionEnabled = false
                                    authenticated = false
                                }
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        self.loginAlert(message: error!.localizedDescription)
                    }
                }
                }
            })
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: message, reply: {success, error in
                //No Touch ID
                DispatchQueue.main.async {
                    
                if success {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.searchBar.isUserInteractionEnabled = true
                    self.lockButton.title = "Lock"
                    self.fetchFromCoreData()
                    authenticated = true
            
                } else {
                    authenticated = false
                    self.accounts = []
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.searchBar.isUserInteractionEnabled = false
                    self.lockButton.title = "Unlock"
                    self.tableView.reloadData()
                    switch error!._code{
                    case Int(kLAErrorAuthenticationFailed):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorUserCancel):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorBiometryNotEnrolled):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorPasscodeNotSet):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorSystemCancel):
                        self.loginAlert(message: error!.localizedDescription)
                    case Int(kLAErrorUserFallback):
                        self.loginAlert(message: error!.localizedDescription)
                    default:
                        self.loginAlert(message: error!.localizedDescription)
                    }
                }
                }
            })
        }
    }
    
    @IBAction func addAccountButton(_ sender: Any) {
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "addNewAccountSegue", sender: self)
    }
    @IBAction func lockButton(_ sender: UIBarButtonItem) {
        accounts = []
        tableView.reloadData()
        authenticateUser()
        authenticated = false
    }
    
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func alert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func fetchFromCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Account>(entityName: "Account")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            accounts = try context.fetch(fetchRequest)
            lockButton.title = "Lock"
            tableView.reloadData()
        } catch {
            print("Unable to fetch: \(error)")
            alert(message: "Oops! Unable to fetch data at this time, please try again.")
        }
    }
    
    func saveToCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Unable to save: \(error)")
            alert(message: "Oops! Unable to save at this time, please try again.")
        }
    }
    
    func searchCoreDataWith(text: String) {
        if text != "" {
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<Account>(entityName: "Account")
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", text)
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                accounts = try context.fetch(fetchRequest)
                tableView.reloadData()
            } catch {
                print("Unable to fetch: \(error)")
                alert(message: "Oops! Unable to fetch data at this time, please try again.")
                
            }
        } else {
            fetchFromCoreData()
        }
    }
    
    //MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountsCell
        cell.delegate = self
        cell.accountNameLabel.text = accounts[indexPath.row].name
        cell.entriesCountForAccountLabel.text = "\(accounts[indexPath.row].entries!.count)"
        cell.favoriteImageView.image = accounts[indexPath.row].favorited == true ? UIImage(named: "star") : UIImage(named: "emptyStar")
        cell.accountImageView.image = UIImage(named: accounts[indexPath.row].image!) ?? UIImage(named: "noImage")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        
        if accounts[indexPath.row].entries!.allObjects.count > 1 {
            performSegue(withIdentifier: "showEntriesSegue", sender: self)
        } else {
            performSegue(withIdentifier: "showDetailsSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        index = indexPath.row
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete Acc", handler: {_,_  in
            self.appDelegate.persistentContainer.viewContext.delete(self.accounts[indexPath.row])
            self.accounts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveToCoreData()
        })
        
        let insertAction = UITableViewRowAction(style: .normal, title: "Add Entry", handler: {_,_  in
            self.performSegue(withIdentifier: "addNewEntrySegue", sender: self)
        })
        deleteAction.backgroundColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        insertAction.backgroundColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
        
        return [deleteAction, insertAction]
    }
    
    // MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEntriesSegue" {
            let controller = segue.destination as? EntriesViewController
            if let destinationVC = controller {
                destinationVC.entries = accounts[index!].entries?.allObjects as? [Entry]
                destinationVC.account = accounts[index!]
                destinationVC.titleTextLabel.text = "Entries of \(accounts[index!].name!)"
            }
        } else if segue.identifier == "addNewEntrySegue" {
            let controller = segue.destination as? AddNewEntryViewController
            if let destinationVC = controller {
                destinationVC.account = accounts[index!]
            }
        } else if segue.identifier == "showDetailsSegue" {
            let controller = segue.destination as? DetailsViewController
            if let destinationVC = controller {
                destinationVC.entryDetails = accounts[index!].entries!.allObjects.first as? Entry
                destinationVC.titleTextLabel.text = "\(accounts[index!].name!) details"
            }
        }
    }
    
    //MARK: - SearchBar Delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCoreDataWith(text: searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchCoreDataWith(text: searchBar.text!)
        searchBar.resignFirstResponder()
    }
}

extension UIViewController: UITextFieldDelegate{
    func addToolBarTo(searchBar: UISearchBar){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        searchBar.inputAccessoryView = toolBar
    }
    
    func addToolBarTo(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.inputAccessoryView = toolBar
    }
    @objc func donePressed(){
        view.endEditing(true)
    }
    
}

