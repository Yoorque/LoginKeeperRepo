//
//  Account+CoreDataProperties.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/31/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var favorited: Bool
    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension Account {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: Entry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: Entry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}
