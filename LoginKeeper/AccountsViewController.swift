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
import UserNotifications


class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AccountsDisplayAlertDelegate, BWWalkthroughViewControllerDelegate, ShowLogoDelegate  {
    
    //MARK: - Properties

    @IBOutlet var lockButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.returnKeyType = .search
            searchBar.placeholder = searchBarPlaceholderLocalized
            searchBar.delegate = self
            searchBar.showsCancelButton = false
        }
    }
    
    @IBOutlet var tableView: UITableView!
    let notificationManager = NotificationManager()
    
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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: .main, using: {_ in
            let random = Int(arc4random_uniform(UInt32(localizedNotificationStrings.count - 1)))
            
            let message = localizedNotificationStrings[random]
            self.notificationManager.notify(with: message)
        })
        //authentication
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: .main, using: {_ in
            self.defaults.set(false, forKey: "authenticated") //sets authentication to false for check in viewWillAppear()
            self.authenticateUser()
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, error) in
            guard error == nil else {return}
                self.defaults.set(true, forKey: "notificationAlertShown")
                if let tutShown = self.defaults.value(forKey: "tutorialShown") as? Bool {
                    self.tutorialShown = tutShown
                }
                
                if self.tutorialShown == false {
                    DispatchQueue.main.async {
                        self.playTutorial()
                    }
                } else {
                    if let shown = self.defaults.value(forKey: "passSetShown") as? Bool {
                        self.passwordSetShownBefore = shown
                    }
                    if self.passwordSetShownBefore == false {
                        self.setPassword()
                    }
                }
            
        })
        
        // addToolBarTo(searchBar: searchBar)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if defaults.bool(forKey: "notificationAlertShown") == true {
            
            if defaults.bool(forKey: "authenticated") == true { // false was set in observer
                if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
                    appDelegate.loadAd(forViewController: self)
                }
                
                updateTableViewBottomInset()
                if searchBar.text == "" {
                    fetchFromCoreData()
                } else {
                    searchCoreDataWith(text: searchBar.text!)
                }
                searchBar.isUserInteractionEnabled = true
                tableView.reloadData()
            } else {
                searchBar.isUserInteractionEnabled = false
                
                if defaults.bool(forKey: "passSetShown") == true {
                    authenticateUser()
                }
            }
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.loadAd(forViewController: self)
        } else {
            appDelegate.removeBannerView()
        }
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
        let pageSix = stb.instantiateViewController(withIdentifier: "Screen6")
        
        walkthrough.delegate = self
        walkthrough.add(viewController: pageOne)
        walkthrough.add(viewController: pageTwo)
        walkthrough.add(viewController: pageThree)
        walkthrough.add(viewController: pageFour)
        walkthrough.add(viewController: pageFive)
        walkthrough.add(viewController: pageSix)
        
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
        let alert = UIAlertController(title: setPasswordLocalized, message: setPasswordMessageLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: doneLocalized, style: .default, handler: { _ in
            let password = alert.textFields?.first?.text!
            alert.textFields?.first?.isSecureTextEntry = true
            self.defaults.set(password, forKey: "userPassword")
            self.defaults.set(true, forKey: "shownBefore")
            self.defaults.set(true, forKey: "passSetShown")
            self.defaults.set(true, forKey: "authenticated")
            self.authenticateUser()
        }))
        
        alert.addAction(UIAlertAction(title: cancelAnswerLocalized, style: .default, handler: { _ in
            self.defaults.set(false, forKey: "shownBefore")
            let alert = UIAlertController(title: passwordIsRequiredLocalized, message: passwordIsRequiredMessageLocalized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: {_ in
                self.setPassword()
            }))
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder = enterPasswordLocalized
        })
        present(alert, animated: true, completion: nil)
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        let reason = identifyLocalized
        context.localizedCancelTitle = cancelAnswerLocalized
        context.localizedFallbackTitle = enterPasscodeAnswerLocalized
        
        BlurBackgroundView.blurCurrent(view: (navigationController?.topViewController?.view)!) //Blur the background
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("canEvaluateWithTouchID")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
                reason, reply: {success, error in
                    // Touch ID
                    
                    DispatchQueue.main.async {
                        if success {
                            print("didEvaluateWithTouchID")
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            self.searchBar.isUserInteractionEnabled = true
                            self.fetchFromCoreData()
                            self.defaults.set(true, forKey: "authenticated")
                            self.lockButton.title = lockLocalized
                            BlurBackgroundView.removeBlurFrom(view: (self.navigationController?.topViewController?.view)!) //Unblur the background
                            if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
                                self.appDelegate.loadAd(forViewController: (self.navigationController?.topViewController)!)
                            } else {
                                self.appDelegate.removeBannerView()
                            }
                            self.updateTableViewBottomInset()
                            print("Success: TouchID")
                        } else {
                            let errorDescriptionLocalized = NSLocalizedString(error!.localizedDescription, comment: "authentication failed message")
                           
                            
                            self.defaults.set(false, forKey: "authenticated")
                            //self.accounts = []
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                            self.searchBar.isUserInteractionEnabled = false
                            self.lockButton.title = unlockLocalized
                            //self.tableView.reloadData()
                            
                            switch error!._code {
                            case Int(kLAErrorAuthenticationFailed):
                                self.loginAlert(message: errorDescriptionLocalized)
                                print("AuthFailed1 \(errorDescriptionLocalized)")
                            case Int(kLAErrorUserCancel):
                                self.loginAlert(message: errorDescriptionLocalized)
                                print("UserCanceled1 \(errorDescriptionLocalized)")
                            case Int(kLAErrorBiometryNotEnrolled):
                                self.loginAlert(message: errorDescriptionLocalized)
                                print("biometry1 \(errorDescriptionLocalized)")
                            case Int(kLAErrorPasscodeNotSet):
                                self.userFallbackPasswordAlert()
                                print("PassNotSet1 \(errorDescriptionLocalized)")
                            case Int(kLAErrorSystemCancel):
                                self.loginAlert(message: errorDescriptionLocalized)
                                print("SystemCancel1 \(errorDescriptionLocalized)")
                            case Int(kLAErrorUserFallback):
                                self.userFallbackPasswordAlert()
                                print("UserFallback1 \(errorDescriptionLocalized)")
                            default:
                               self.userFallbackPasswordAlert()
                                print("default1 \(errorDescriptionLocalized)")
                            }
                        }
                    }
                })
        } else {
            print("canEvaluateWithPasscode")
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: {success, error in
                //No Touch ID
                
                DispatchQueue.main.async {
                    if success {
                        print("didEvaluateWithPasscode")
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.searchBar.isUserInteractionEnabled = true
                        self.lockButton.title = lockLocalized
                        self.fetchFromCoreData()
                        self.defaults.set(true, forKey: "authenticated")
                        BlurBackgroundView.removeBlurFrom(view: (self.navigationController?.topViewController?.view)!) //Unblur the background
                        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
                                self.appDelegate.loadAd(forViewController: (self.navigationController?.topViewController)!)
                            } else {
                                self.appDelegate.removeBannerView()
                            }
                        self.updateTableViewBottomInset()
                        print("Success: Passcode")
                    } else {
                        let errorDescriptionLocalized = NSLocalizedString(error!.localizedDescription, comment: "authentication failed message")
                        self.defaults.set(false, forKey: "authenticated")
                        
                       // self.accounts = []
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.searchBar.isUserInteractionEnabled = false
                        self.lockButton.title = unlockLocalized
                       // self.tableView.reloadData()
                        
                        switch error!._code{
                        case Int(kLAErrorAuthenticationFailed):
                            self.loginAlert(message: errorDescriptionLocalized)
                            print("AuthFailed2 \(errorDescriptionLocalized)")
                        case Int(kLAErrorUserCancel):
                            self.loginAlert(message: errorDescriptionLocalized)
                            print("UserCanceled2 \(errorDescriptionLocalized)")
                        case Int(kLAErrorBiometryNotEnrolled):
                            self.loginAlert(message: errorDescriptionLocalized)
                            print("biometry \(errorDescriptionLocalized)2")
                        case Int(kLAErrorPasscodeNotSet):
                            self.userFallbackPasswordAlert()
                            print("PassNotSet2 \(errorDescriptionLocalized)")
                        case Int(kLAErrorSystemCancel):
                            self.loginAlert(message: errorDescriptionLocalized)
                            print("SystemCancel2 \(errorDescriptionLocalized)")
                        case Int(kLAErrorUserFallback):
                            self.userFallbackPasswordAlert()
                            print("UserFallback2 \(errorDescriptionLocalized)")
                        default:
                            self.userFallbackPasswordAlert()
                            print("default2 \(errorDescriptionLocalized)")
                        }
                    }
                }
            })
        }
    }
    //MARK: - Alerts
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func wrongPassInfoAlert(message: String) {
        let alert = UIAlertController(title: errorLocalized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: {_ in
            self.userFallbackPasswordAlert()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func coreDataAlert(message: String) {
        let alert = UIAlertController(title: errorLocalized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func loginAlert(message: String) {
        let alert = UIAlertController(title: errorLocalized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: {_ in
            self.authenticateUser()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func userFallbackPasswordAlert() {
        
        let alert = UIAlertController(title: passwordTextLocalized, message: enterPasswordLocalized, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder = enterPasswordLocalized
        })
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: { _ in
            let defaults = UserDefaults.standard
            if let pass = defaults.value(forKey: "userPassword") as? String {
                if pass == alert.textFields?.first?.text {
                    alert.textFields?.first?.isSecureTextEntry = true
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.searchBar.isUserInteractionEnabled = true
                    self.lockButton.title = lockLocalized
                    self.fetchFromCoreData()
                    self.defaults.set(true, forKey: "authenticated")
                    BlurBackgroundView.removeBlurFrom(view: (self.navigationController?.topViewController?.view)!) //Unblur the background
                    print("Success")
                } else {
                    self.wrongPassInfoAlert(message: passNotMatchMessageLocalized)
                    
                    self.searchBar.isUserInteractionEnabled = false
                    self.defaults.set(false, forKey: "authenticated")
                    
                }
            }
        }))
        alert.addAction(UIAlertAction(title: cancelAnswerLocalized, style: .default, handler: {_ in
            self.authenticateUser()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - Button Actions
    @IBAction func showInfoButon(_ sender: Any) {
        performSegue(withIdentifier: "showInfoSegue", sender: self)
    }
    @IBAction func addAccountButton(_ sender: Any) {
        searchBar.resignFirstResponder()
        logoImagesPNG.remove(at: 0)
        logoImagesPNG.insert("pngloginkeeper", at: 0)
        performSegue(withIdentifier: "addNewAccountSegue", sender: self)
    }
    @IBAction func lockButton(_ sender: UIBarButtonItem) {
        
        accounts = []
        tableView.reloadData()
        if lockButton.title == unlockLocalized {
            searchBar.isUserInteractionEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
            authenticateUser()
        }
        if lockButton.title == lockLocalized {
            lockButton.title = unlockLocalized
            searchBar.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
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
            lockButton.title = lockLocalized
            tableView.reloadData()
        } catch {
            coreDataAlert(message: unableToFetchMessageLocalized)
        }
    }
    
    func saveToCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            
            coreDataAlert(message: unableToSaveMessageLocalized)
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
                
                coreDataAlert(message: unableToFetchMessageLocalized)
                
            }
        } else {
            fetchFromCoreData()
        }
    }
    func showLogosForRow(at index: Int) {
        self.index = index
        logoImagesPNG.remove(at: 0)
        logoImagesPNG.insert(accounts[index].image!, at: 0)
        for account in accountLogos {
            if account == accounts[index].name!.lowercased().replacingOccurrences(of: " ", with: "") {
                logoImagesPNG.remove(at: 0)
                logoImagesPNG.insert(account.lowercased().replacingOccurrences(of: " ", with: ""), at: 0)
                break
            } else if accounts[index].name!.lowercased().replacingOccurrences(of: " ", with: "").contains(account) {
                logoImagesPNG.remove(at: 0)
                logoImagesPNG.insert(account.lowercased().replacingOccurrences(of: " ", with: ""), at: 0)
            }
        }
        performSegue(withIdentifier: "showLogos", sender: self)
    }
    
    //MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountsCell
        cell.delegate = self
        cell.showLogoDelegate = self
        cell.accountNameLabel.text = accounts[indexPath.row].name
        cell.entriesCountForAccountLabel.text = "\(accounts[indexPath.row].entries!.count)"
        
        if accounts[indexPath.row].entries!.count > 1 {
            cell.favoriteImageView.isHidden = true
        } else {
            cell.favoriteImageView.isHidden = false
            cell.favoriteImageView.image = (accounts[indexPath.row].entries?.allObjects.first as! Entry).favorited == true ? UIImage(named: "star") : UIImage(named: "emptyStar")
        }
        cell.accountImageView.tag = indexPath.row
        cell.accountImageView.image = UIImage(named: accounts[indexPath.row].image!)
        
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
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: deleteAccountLocalized, handler: {_,_  in
            self.appDelegate.persistentContainer.viewContext.delete(self.accounts[indexPath.row])
            self.accounts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.saveToCoreData()
        })
        
        let insertAction = UITableViewRowAction(style: .normal, title: addEntryLocalized, handler: {_,_  in
            self.performSegue(withIdentifier: "addNewEntrySegue", sender: self)
        })
        deleteAction.backgroundColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        insertAction.backgroundColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
    
        return [deleteAction, insertAction]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        index = indexPath.row
        let addAction = UIContextualAction(style: .normal, title: "Add Entry") { (action, view, completionHandler) in
            self.performSegue(withIdentifier: "addNewEntrySegue", sender: self)
        }
        addAction.backgroundColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [addAction])
        
        return swipeConfig
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        index = indexPath.row
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete Acc") { (action, view, completionHandler) in
            self.appDelegate.persistentContainer.viewContext.delete(self.accounts[indexPath.row])
            self.accounts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.saveToCoreData()
        }
        
        deleteAction.backgroundColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfig
    }
   
    // MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEntriesSegue" {
            let controller = segue.destination as? EntriesViewController
            if let destinationVC = controller {
                destinationVC.entries = accounts[index!].entries?.allObjects as? [Entry]
                destinationVC.account = accounts[index!]
                destinationVC.titleTextLabel.text = "\(entriesOfLocalized) \(accounts[index!].name!)"
            }
        } else if segue.identifier == "addNewEntrySegue" {
            let controller = segue.destination as? AddNewEntryViewController
            if let destinationVC = controller {
                destinationVC.account = accounts[index!]
                destinationVC.titleTextLabel.text = "\(addNewEntryLocalized) \(accounts[index!].name!)"
            }
        } else if segue.identifier == "showDetailsSegue" {
            let controller = segue.destination as? DetailsViewController
            if let destinationVC = controller {
                destinationVC.entryDetails = accounts[index!].entries!.allObjects.first as? Entry
                destinationVC.titleTextLabel.text = "\(accounts[index!].name!) \(detailsLocalized)"
            }
        } else if segue.identifier == "showLogos" {
            let controller = segue.destination as? LogosViewController
            if let destinationVC = controller {
                destinationVC.account = accounts[index!]
            }
        }
    }
}
extension AccountsViewController: UISearchBarDelegate {
    //MARK: - SearchBar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("DidBeginEditing")
        searchBar.showsCancelButton = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCoreDataWith(text: searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchCoreDataWith(text: searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchBar.showsCancelButton = false
        }
    }
}

//extension UIViewController: UITextFieldDelegate{
//    func addToolBarTo(searchBar: UISearchBar){
//        let toolBar = UIToolbar()
//        toolBar.barStyle = UIBarStyle.default
//        toolBar.isTranslucent = true
//
//        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
//
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        toolBar.setItems([spaceButton, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        toolBar.sizeToFit()
//
//        searchBar.inputAccessoryView = toolBar
//    }
//
//    func addToolBarTo(textField: UITextField){
//        let toolBar = UIToolbar()
//        toolBar.barStyle = UIBarStyle.default
//        toolBar.isTranslucent = true
//
//        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
//
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        toolBar.setItems([spaceButton, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        toolBar.sizeToFit()
//
//        textField.inputAccessoryView = toolBar
//    }
//    @objc func donePressed(){
//        view.endEditing(true)
//    }
//}


