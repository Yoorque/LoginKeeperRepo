//
//  EntriesCell.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

protocol EntriesDisplayAlertDelegate {
    func alert(message: String)
}

class EntriesCell: UITableViewCell {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: EntriesDisplayAlertDelegate?
    
    @IBOutlet var favoriteImageView: UIImageView! {
        didSet {
            favoriteImageView.image = UIImage(named: "emptyStar")
            let gesture = UITapGestureRecognizer(target: self, action: #selector(starGesture))
            favoriteImageView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet var entryName: UILabel!
    @IBOutlet var entryComment: UILabel!
    var entryForCell: Entry!
    
    @objc func starGesture(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIImageView{
        
            fetch(entry: entryName.text!)
            
            if view.image == UIImage(named: "star") {
                view.image = UIImage(named: "emptyStar")
                entryForCell.favorited = false
            } else {
                view.image = UIImage(named: "star")
                entryForCell.favorited = true
            }
            do {
                try context.save()
            } catch {
                print("Can't save favorites")
                delegate?.alert(message: "Can't save favorites.")
            }
        }
    }
    func fetch(entry: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        let predicate = NSPredicate(format: "name == %@", entry)
        fetchRequest.predicate = predicate
        
        do {
            entryForCell = try context.fetch(fetchRequest).first as! Entry
        } catch {
            print("Unable to fetch: \(error)")
            delegate?.alert(message: "Unable to fetch data.")
        }
    }
    
}
