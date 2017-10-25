//
//  Entry+CoreDataProperties.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 10/9/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var comment: String?
    @NSManaged public var favorited: Bool
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var username: String?
    @NSManaged public var account: Account?

}
