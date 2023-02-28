//
//  PMCloudDevice+CoreDataProperties.swift
//  W2STApp
//
//  Created by Giuseppe Paris on 19/02/22.
//  Copyright © 2022 STMicroelectronics. All rights reserved.
//
//

import Foundation
import CoreData


extension PMCloudDevice {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<PMCloudDevice> {
        return NSFetchRequest<PMCloudDevice>(entityName: "PMCloudDevice")
    }

    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var certificate: String?
    @NSManaged public var key: String?

}
