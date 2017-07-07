//
//  AccountsViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var index: Int?
    var accounts = [Account]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchFromCoreData()
    }
    
    func fetchFromCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Account>(entityName: "Account")
        
        do {
            accounts = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Unable to fetch: \(error)")
        }
    }
    
    func saveToCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Unable to save: \(error)")
        }
    }
    
    //MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AccountsCell
        cell.accountNameLabel.text = accounts[indexPath.row].name
        cell.entriesCountForAccountLabel.text = "\(accounts[indexPath.row].entries!.count)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        if accounts[indexPath.row].entries!.allObjects.count > 1 {
            performSegue(withIdentifier: "showEntriesSegue", sender: self)
        } else {
            performSegue(withIdentifier: "showDetailsSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        index = indexPath.row
        let delete = UITableViewRowAction(style: .destructive, title: "Delete Account", handler: {_ in
            
            self.appDelegate.persistentContainer.viewContext.delete(self.accounts[indexPath.row])
            self.accounts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveToCoreData()

        })
        
        let insert = UITableViewRowAction(style: .normal, title: "Insert Entry", handler: {_ in
            self.performSegue(withIdentifier: "addNewEntrySegue", sender: self)
        })
        insert.backgroundColor = UIColor.green
        return [delete, insert]
    }
    
    // MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEntriesSegue" {
            let controller = segue.destination as? EntriesViewController
            if let destinationVC = controller {
                destinationVC.entries = accounts[index!].entries?.allObjects as? [Entry]
                destinationVC.account = accounts[index!]
                destinationVC.title = accounts[index!].name
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
            }

        }
    }
}

