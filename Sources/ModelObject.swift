//
//  ModelObject.swift
//  GoogleyEyesCore
//
//  Created by Matthew Wyskiel on 4/17/17.
//
//

import Foundation
import SwiftyJSON

public protocol FromJSON {
    init(json: JSON)
    
    func toJSON() -> JSON
}

public protocol ObjectType: FromJSON { }

public protocol ModelObject: ObjectType {
    var kind: String { get }
}

public protocol ListType: ObjectType, Sequence {
    associatedtype ItemType: ObjectType
    var items: [ItemType] { get }
}

extension ListType {
    public func makeIterator() -> IndexingIterator<[ItemType]> {
        let objects = items as [ItemType]
        return objects.makeIterator()
    }
    
    public subscript(position: Int) -> ItemType {
        return items[position]
    }
}

public protocol ModelObjectList: ModelObject, ListType { }
