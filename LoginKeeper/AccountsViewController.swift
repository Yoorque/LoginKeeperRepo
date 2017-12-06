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


class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AccountsDisplayAlertDelegate, BWWalkthroughViewControllerDelegate {
    
    //MARK: - Properties
   
    let accountLogos = ["mashreq", "weibo", "stackoverflow","nbd", "amazon", "apple", "badoo", "baidu", "balkaniyum", "bing", "blogger", "classmates", "couchsurfing", "crunchyroll", "ebay", "etoro", "facebook", "firebase", "flickr", "flixster", "foursquare", "friendster", "github", "gmail", "google+", "google", "grindr", "instagram", "line", "linkedin", "meetup", "mts", "myheritage", "myspace", "mytaxi", "netflix", "openstreetmaps", "opera", "orkut", "overpass", "pinterest", "qq", "quora", "qzone", "reddit", "renren", "shazam", "skype", "snapchat", "soundcloud", "soundhound", "stumbleupon", "tagged", "taringa", "telegram", "telenor", "thedots", "tinder", "tumblr", "twitter", "uber", "upwork", "viber", "vimeo", "vine", "vip", "vkontakte", "wechat", "weibo", "whatsapp", "wikipedia", "yahoo", "yelp", "youtube", "yy"]
    
    @IBOutlet var lockButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.returnKeyType = .search
            self.searchBar.delegate = self
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    //var authenticated: Bool?
    var index: Int?
    var accounts = [Account]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var passwordSetShownBefore = false
    var tutorialShown = false
    
    //MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.set(false, forKey: "authenticated")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil, using: {_ in
            DispatchQueue.main.async {
                
            self.navigationController?.popToRootViewController(animated: true)
            self.accounts = []
            self.tableView.reloadData()
            self.authenticateUser()
            self.defaults.set(false, forKey: "authenticated")
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        if let tutShown = defaults.value(forKey: "tutorialShown") as? Bool {
            tutorialShown = tutShown
        }
        
        if tutorialShown == false {
            playTutorial()
        } else {
            if let shown = defaults.value(forKey: "shownBefore") as? Bool {
                passwordSetShownBefore = shown
            }
            if passwordSetShownBefore == false {
                setPassword()
            } else {
                authenticateUser()
            }
        }
        addToolBarTo(searchBar: searchBar)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        if defaults.bool(forKey: "authenticated") == true {
            fetchFromCoreData()
            tableView.reloadData()
        }
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        
        updateTableViewBottomInset()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        updateTableViewBottomInset()
    }
    //MARK: - Tutorial Functions
    
    func playTutorial() {
        defaults.setValue(true, forKey: "tutorialShown")
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "Screen0") as! BWWalkthroughViewController
        let pageOne = stb.instantiateViewController(withIdentifier: "Screen1")
        let pageTwo = stb.instantiateViewController(withIdentifier: "Screen2")
        let pageThree = stb.instantiateViewController(withIdentifier: "Screen3")
        let pageFour = stb.instantiateViewController(withIdentifier: "Screen4")
        let pageFive = stb.instantiateViewController(withIdentifier: "Screen5")
        
        walkthrough.delegate = self
        walkthrough.add(viewController: pageOne)
        walkthrough.add(viewController: pageTwo)
        walkthrough.add(viewController: pageThree)
        walkthrough.add(viewController: pageFour)
        walkthrough.add(viewController: pageFive)
        
        self.present(walkthrough, animated: true, completion: nil)
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        if passwordSetShownBefore == false {
            setPassword()
        } else {
            authenticateUser()
        }
    }
    
    //MARK: - Helper functions
    func updateTableViewBottomInset() {
        if let banner = appDelegate.adBannerView {
            tableView.contentInset.bottom = banner.frame.size.height
        }
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            if !searchBar.frame.contains(view.frame) {
                view.resignFirstResponder()
            }
        }
    }
    
    func setPassword() {
        let alert = UIAlertController(title: "Password", message: "Set your backup password for LoginKeeper", preferredStyle: .alert)
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
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        let reason = "Identify yourself"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {success, error in
                // Touch ID
                DispatchQueue.main.async {
                    if success {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.searchBar.isUserInteractionEnabled = true
                        self.fetchFromCoreData()
                        self.defaults.set(true, forKey: "authenticated")
                        print("Success: TouchID")
                    } else {
                        self.defaults.set(false, forKey: "authenticated")
                        self.accounts = []
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.searchBar.isUserInteractionEnabled = false
                        self.lockButton.title = "Unlock"
                        self.tableView.reloadData()
                        
                        switch error!._code {
                        case Int(kLAErrorAuthenticationFailed):
                            self.loginAlert(message: error!.localizedDescription)
                            print("AuthFailed1")
                        case Int(kLAErrorUserCancel):
                            self.loginAlert(message: error!.localizedDescription)
                            print("UserCanceled1")
                        case Int(kLAErrorBiometryNotEnrolled):
                            self.loginAlert(message: error!.localizedDescription)
                            print("biometry1")
                        case Int(kLAErrorPasscodeNotSet):
                            self.userFallbackPasswordAlertWith(error: error!)
                            print("PassNotSet1")
                        case Int(kLAErrorSystemCancel):
                            self.loginAlert(message: error!.localizedDescription)
                              print("SystemCancel1")
                        case Int(kLAErrorUserFallback):
                            self.userFallbackPasswordAlertWith(error: error!)
                              print("UserFallback1")
                        default:
                            self.userFallbackPasswordAlertWith(error: error!)
                              print("default1")
                        }
                    }
                }
            })
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: {success, error in
                //No Touch ID
                DispatchQueue.main.async {
                    
                    if success {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.searchBar.isUserInteractionEnabled = true
                        self.lockButton.title = "Lock"
                        self.fetchFromCoreData()
                        self.defaults.set(true, forKey: "authenticated")
                        
                    } else {
                        self.defaults.set(false, forKey: "authenticated")
                        self.accounts = []
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.searchBar.isUserInteractionEnabled = false
                        self.lockButton.title = "Unlock"
                        self.tableView.reloadData()
                        switch error!._code{
                        case Int(kLAErrorAuthenticationFailed):
                            self.loginAlert(message: error!.localizedDescription)
                            print("AuthFailed2")
                        case Int(kLAErrorUserCancel):
                            self.loginAlert(message: error!.localizedDescription)
                            print("UserCanceled2")
                        case Int(kLAErrorBiometryNotEnrolled):
                            self.loginAlert(message: error!.localizedDescription)
                            print("biometry2")
                        case Int(kLAErrorPasscodeNotSet):
                            self.userFallbackPasswordAlertWith(error: error!)
                            print("PassNotSet2")
                        case Int(kLAErrorSystemCancel):
                            self.loginAlert(message: error!.localizedDescription)
                            print("SystemCancel2")
                        case Int(kLAErrorUserFallback):
                            self.userFallbackPasswordAlertWith(error: error!)
                            print("UserFallback2")
                        default:
                            self.userFallbackPasswordAlertWith(error: error!)
                            print("default2")
                        }
                    }
                }
            })
        }
    }
    //MARK: - Alerts
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func loginAlert(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.authenticateUser()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func userFallbackPasswordAlertWith(error: Error) {
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
                    self.defaults.set(true, forKey: "authenticated")
                    print("Success")
                } else {
                    self.alert(message: error.localizedDescription)
                    self.searchBar.isUserInteractionEnabled = false
                    self.defaults.set(false, forKey: "authenticated")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - Button Actions
    @IBAction func showInfoButon(_ sender: Any) {
        performSegue(withIdentifier: "showInfoSegue", sender: self)
    }
    @IBAction func addAccountButton(_ sender: Any) {
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "addNewAccountSegue", sender: self)
    }
    @IBAction func lockButton(_ sender: UIBarButtonItem) {
        accounts = []
        tableView.reloadData()
        if lockButton.title == "Unlock" {
            authenticateUser()
        }
        if lockButton.title == "Lock" {
            lockButton.title = "Unlock"
        }
        defaults.set(false, forKey: "authenticated")
    }
    
    //MARK: - CoreData Requests
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
        for logo in accountLogos {
            if accounts[indexPath.row].name?.lowercased().replacingOccurrences(of: " ", with: "") == logo {
                cell.accountImageView.image = UIImage(named: logo)
                break
            } else if (accounts[indexPath.row].name?.lowercased().replacingOccurrences(of: " ", with: "").contains(logo))! {
                cell.accountImageView.image = UIImage(named: logo)
                break
            } else {
                cell.accountImageView.image = UIImage(named: "loginKeeper")
            }
        }
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
                destinationVC.title = "Entries of \(accounts[index!].name!)"
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
                destinationVC.title = "\(accounts[index!].name!) details"
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


