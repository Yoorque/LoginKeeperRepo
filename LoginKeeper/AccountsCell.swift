//
//  AccountsCell.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class AccountsCell: UITableViewCell {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var favoriteImageView: UIImageView! {
        didSet {
            favoriteImageView.image = UIImage(named: "emptyStar")
            let gesture = UITapGestureRecognizer(target: self, action: #selector(starGesture))
            favoriteImageView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var entriesCountForAccountLabel: UILabel!
    var accountForCell: Account!
    
    func starGesture(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIImageView{
            
            fetch(account: accountNameLabel.text!)
            
            if view.image == UIImage(named: "star") {
                view.image = UIImage(named: "emptyStar")
                accountForCell.favorited = false
            } else {
                view.image = UIImage(named: "star")
                accountForCell.favorited = true
            }
            do {
                try context.save()
            } catch {
                print("Can't save favorites")
            }
        }
    }
    
    func fetch(account: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "name == %@", account)
        fetchRequest.predicate = predicate
        
        do {
            accountForCell = try context.fetch(fetchRequest).first as! Account
        } catch {
            print("Unable to fetch: \(error)")
        }
    }
}
