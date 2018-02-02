//
//  EntriesViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class EntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EntriesDisplayAlertDelegate, UIViewControllerPreviewingDelegate {

    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var index: Int?
    var account: Account?
    var entries: [Entry]?
    let titleTextLabel = UILabel()
    let logoNavImage = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoNavImage.frame.size = CGSize(width: 30, height: 30)
        logoNavImage.image = UIImage(named: account!.image!)?.resizedImage(newSize: CGSize(width: 30, height: 30))
        navigationItem.titleView = logoNavImage
        logoNavImage.addShadow()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.loadAd(forViewController: self)
            updateTableViewBottomInset()
        } else {
            appDelegate.removeBannerView()
        }
        fetchFromCoreData()
    }
    
    func updateTableViewBottomInset() {
        if let banner = appDelegate.adBannerView {
            tableView.contentInset.bottom = banner.frame.size.height
        }
    }
    
    //MARK: - Preview Delegates
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            let destVC = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            
                destVC.entryDetails = entries?[indexPath.row]
                destVC.preferredContentSize = CGSize(width: 0, height: 300)
                destVC.appDelegate.removeBannerView() //not working
                return destVC
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func fetchFromCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Entry>(entityName: "Entry")
        fetchRequest.predicate = NSPredicate(format: "account.name == %@", (account?.name)!)
        
        do {
            entries = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            
            let alert = UIAlertController(title: errorLocalized, message: unableToFetchMessageLocalized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveToCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            
            let alert = UIAlertController(title: errorLocalized, message: unableToSaveMessageLocalized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        appDelegate.removeBannerView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if !UserDefaults.standard.bool(forKey: "premiumPurchased") {
            appDelegate.loadAd(forViewController: self)
            updateTableViewBottomInset()            
        } else {
            appDelegate.removeBannerView()
        }
    }

    
    @IBAction func addNewEntryButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "addNewEntrySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewEntrySegue" {
            let controller = segue.destination as? AddNewEntryViewController
            if let destinationVC = controller {
                destinationVC.account = account
                destinationVC.titleTextLabel.text = "\(addNewEntryLocalized) \(account!.name!)"
            }
        } else if segue.identifier == "showDetailsSegue" {
            let controller = segue.destination as? DetailsViewController
            if let destinationVC = controller {
                destinationVC.entryDetails = entries?[index!]
                destinationVC.titleTextLabel.text = "\(entries![index!].name!) \(detailsLocalized)"
            }
        }
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: errorLocalized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
   
    
    //MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EntriesCell
        cell.delegate = self
        cell.entryName.text = entries![indexPath.row].name
        cell.entryComment.text = entries![indexPath.row].comment
        cell.favoriteImageView.image = entries?[indexPath.row].favorited == true ? UIImage(named: "star") : UIImage(named: "emptyStar")
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 211/255, green: 220/255, blue: 251/255, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "showDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: deleteEntryLocalized, handler: {_,_  in
            
            self.appDelegate.persistentContainer.viewContext.delete(self.entries![indexPath.row])
            self.entries?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveToCoreData()
            
        })
        
        return [delete]
    }
}

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIView {
    func addShadow() {
        self.contentMode = .scaleAspectFit
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.5
        self.layer.cornerRadius = self.frame.size.width / 4
    }
}
