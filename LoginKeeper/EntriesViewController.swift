//
//  EntriesViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class EntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var index: Int?
    var account: Account?
    var entries: [Entry]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchFromCoreData()
    }

    func fetchFromCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Entry>(entityName: "Entry")
        fetchRequest.predicate = NSPredicate(format: "account.name == %@", (account?.name)!)
        
        do {
            entries = try context.fetch(fetchRequest)
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

    
    @IBAction func addNewEntryButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addNewEntrySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewEntrySegue" {
            let controller = segue.destination as? AddNewEntryViewController
            if let destinationVC = controller {
                destinationVC.account = account
                destinationVC.title = "Add new entry for \(account!.name!)"
            }
        } else if segue.identifier == "showDetailsSegue" {
            let controller = segue.destination as? DetailsViewController
            if let destinationVC = controller {
                destinationVC.entryDetails = entries?[index!]
                destinationVC.title = "\(entries![index!].name!) details"
            }
        }
    }
    
    
   
    
    //MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EntriesCell
        cell.entryName.text = entries![indexPath.row].name
        cell.entryComment.text = entries![indexPath.row].comment
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "showDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete Entry", handler: {_ in
            
            self.appDelegate.persistentContainer.viewContext.delete(self.entries![indexPath.row])
            self.entries?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveToCoreData()
            
        })
        
        return [delete]
    }
}
