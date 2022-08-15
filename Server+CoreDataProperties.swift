//
//  Server+CoreDataProperties.swift
//  hasChanges
//
//  Created by Kyrylo Onyshchuk on 15.08.2022.
//
//

import Foundation
import CoreData


extension Server {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Server> {
        return NSFetchRequest<Server>(entityName: "Server")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var url: URL?
    @NSManaged public var content: Data?
    @NSManaged public var lastChange: Date?
    @NSManaged public var hasChange: Bool
    
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var wrappedUrl: URL {
        url ?? URL(string: "https://example.com")
    }
    
    public var wrappedLastChange: Date {
        lastChange ?? .now
    }

}

extension Server : Identifiable {

}
