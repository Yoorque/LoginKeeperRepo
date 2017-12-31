//
//  EntriesViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class EntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EntriesDisplayAlertDelegate {

    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var index: Int?
    var account: Account?
    var entries: [Entry]?
    let titleTextLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextLabel.frame.size.height = 25
        titleTextLabel.textAlignment = .center
        titleTextLabel.textColor = UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        titleTextLabel.font = UIFont(name: "Zapf Dingbats", size: 15)
        //titleTextLabel.text = title
        navigationItem.titleView = titleTextLabel
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        fetchFromCoreData()
        tableView.setNeedsLayout()
    }
    //MARK: - Localization
    
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
        appDelegate.load(bannerView: appDelegate.adBannerView,forViewController: self, andOrientation: UIDevice.current.orientation)
        
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
