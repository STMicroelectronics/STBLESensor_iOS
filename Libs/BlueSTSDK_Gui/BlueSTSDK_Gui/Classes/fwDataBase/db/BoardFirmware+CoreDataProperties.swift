//
//  BoardFirmware+CoreDataProperties.swift

import Foundation
import CoreData


extension BoardFirmware {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<BoardFirmware> {
        return NSFetchRequest<BoardFirmware>(entityName: "BoardFirmware")
    }

    @NSManaged public var firmwares: NSObject?

}

extension BoardFirmware : Identifiable {

}


public class Firmwares: NSObject, NSCoding {

    public var firmwares: [Catalog] = []

    enum Key:String {
        case firmwares = "firmwares"
    }

    init(firmwares: [Catalog]) {
        self.firmwares = firmwares
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(firmwares, forKey: Key.firmwares.rawValue)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let mFirmwares = aDecoder.decodeObject(forKey: Key.firmwares.rawValue) as! [Catalog]

        self.init(firmwares: mFirmwares)
    }

}
